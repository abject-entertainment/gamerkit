//
//  ShareableContent.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/25/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "ContentObject.h"
#import "ContentTransform.h"
#import "ContentTransformResult.h"
#import "XMLDataContent.h"

@interface ContentObject()
{
	dispatch_semaphore_t _pdfSemaphore;
	__block NSData *_expectedPdfData;
	
	NSMutableArray *_transforms;
	ContentTransformResult *_preview;
}
@end

@implementation ContentObject

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_fileName = nil;
		_data = nil;
		_transforms = [NSMutableArray arrayWithCapacity:ContentObjectActionMAX];
		
		for (int i = 0; i < ContentObjectActionMAX; ++i)
		{
			[_transforms addObject:[NSNull null]];
		}
		
		[self setTransform:[ContentTransform defaultTransform] forAction:ContentObjectActionDefault];
	}
	return self;
}

- (instancetype)initWithFile:(NSString *)fileName
{
	self = [self init];
	if (self)
	{
		_fileName = fileName;
		
	}
	return self;
}

- (BOOL)dataIsLoaded
{ return (_data != nil) && (_data.valid); }

- (void)loadData
{
	if (_data) return;
	if (_fileName)
	{
		_data = [[XMLDataContent alloc] initWithFileAtPath:_fileName];
	}
}

- (void)unloadData
{
	_data = nil;
}

- (NSString *)contentPath
{ return @"Media"; }

- (void)saveFile
{
	if (_fileName == nil)
	{
		NSString *format = [NSString stringWithFormat:@"%@/%%08X", self.contentPath];
		
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *fileName = nil;
		
		do
		{
			fileName = [NSString stringWithFormat:format, random()];
		} while ([fm fileExistsAtPath:fileName]);
		
		_fileName = fileName;
	}

	[_data saveToFile:_fileName];
}

- (ContentTransformResult *)getPreview
{
	if (_preview == nil)
	{
		BOOL unload = _data == nil;
		[self loadData];
		_preview = [self applyTransformForAction:ContentObjectActionPreview];
		if (unload)
		{	[self unloadData]; }
	}
	
	return _preview;
}

- (void)refreshPreview
{
	_preview = nil;
	[self getPreview];
}

- (void)setTransform:(ContentTransform*)transform forAction:(ContentObjectAction)action
{
	if (transform)
	{ _transforms[action] = transform; }
	else
	{ _transforms[action] = [NSNull null]; }
}

- (ContentTransformResult *)applyTransformForAction:(ContentObjectAction)action
{
	ContentTransform *xform = nil;
	
	id obj = _transforms[action];
	if (obj == [NSNull null])
	{ obj = _transforms[ContentObjectActionDefault]; }
	if (obj != [NSNull null])
	{ xform = (ContentTransform*)obj; }
	
	return [self applyTransform:xform forAction:action];
}

- (ContentTransformResult *)applyTransform:(ContentTransform *)transform forAction:(ContentObjectAction)action
{
	if (_data == nil)
	{ [self loadData]; }
	
	ContentTransformResult *result;
	if (transform)
	{
		switch (action)
		{
			case ContentObjectActionWebView:
				result = [transform transformContentForWebView:self readOnly:NO];
				break;
			case ContentObjectActionReadOnlyWebView:
				result = [transform transformContentForWebView:self readOnly:YES];
				break;
			case ContentObjectActionPreview:
				result = [transform transformContentForPreview:self];
				break;
			case ContentObjectActionShare:
				result = [transform transformContentForSharing:self];
				break;
			case ContentObjectActionPrint:
				result = [transform transformContentForPrinting:self];
				break;
			case ContentObjectActionExportToPDF:
				result = [transform transformContentForExportToPDF:self];
				break;
			default:
				result = [[ContentTransformResult alloc] initWithAction:action];
		}
	}
	
	return result;
}

- (void)shareFromViewController:(UIViewController *)viewController
{
	UIActivityViewController *act = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
	
	act.excludedActivityTypes = @[ UIActivityTypeAddToReadingList,
								   UIActivityTypeAssignToContact,
								   UIActivityTypeMessage,
								   UIActivityTypePostToFacebook,
								   UIActivityTypePostToFlickr,
								   UIActivityTypePostToTencentWeibo,
								   UIActivityTypePostToTwitter,
								   UIActivityTypePostToVimeo,
								   UIActivityTypePostToWeibo,
								   UIActivityTypeSaveToCameraRoll
								   ];
	
	[viewController presentViewController:act animated:YES completion:nil];
}

- (id)initWithSharedData:(NSData*)data
{ return nil; }


- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return [NSURL URLWithString:self.fileName];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	ContentTransformResult *result = [self applyTransformForAction:ContentObjectActionPreview];
	if (result.succeeded)
	{
		return result.title;
	}
	return nil;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType
{
	// Not using NSData objects.
	return nil;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	ContentTransformResult *result = nil;
	if ([activityType compare:UIActivityTypeAirDrop] == NSOrderedSame)
	{ // air drop!
		result = [self applyTransformForAction:ContentObjectActionShare];
		if (result && result.succeeded)
		{ return result.file; }
	}
	else if ([activityType compare:UIActivityTypePrint] == NSOrderedSame)
	{
		result = [self applyTransformForAction:ContentObjectActionPrint];
		if (result && result.succeeded)
		{ return result.printFormatter; }
	}
	else if ([activityType compare:UIActivityTypeOpenInIBooks] == NSOrderedSame)
	{
		result = [self applyTransformForAction:ContentObjectActionExportToPDF];
		if (result && result.succeeded)
		{ return result.file; }
	}
	
	return nil;
}

@end
