//
//  ShareableContent.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/25/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "ContentObject.h"
#import "XMLDataLayout.h"

@implementation ContentTransformResult

- (instancetype)initWithXMLDataLayoutResult:(NSDictionary*)result
{
	self = [self init];
	if (self)
	{
		_action = [[result objectForKey:kXMLTransformKeyAction] unsignedIntegerValue];
		if ([[result objectForKey:kXMLTransformKeySucceeded] boolValue] == NO)
		{
			_succeeded = NO;
		}
		else
		{
			if (_action == ContentObjectActionPreview)
			{
				_title = [[result objectForKey:kXMLTransformKeyTitle] stringValue];
				_subtitle = [[result objectForKey:kXMLTransformKeySubtitle] stringValue];
				_image = [result objectForKey:kXMLTransformKeyImage];
			}
			else if (_action == ContentObjectActionShare ||
					 _action == ContentObjectActionExportToPDF)
			{
				_file = [result objectForKey:kXMLTransformKeyFile];
			}
			else if (_action == ContentObjectActionWebView ||
					 _action == ContentObjectActionReadOnlyWebView)
			{
				_html = [[result objectForKey:kXMLTransformKeyHTML] stringValue];
			}
			else if (_action == ContentObjectActionPrint)
			{
				_printFormatter = [result objectForKey:kXMLTransformKeyPrintFormatter];
			}
		}
	}
	return self;
}

- (instancetype)initWithFailureForAction:(ContentObjectAction)action
{
	self = [self init];
	if (self)
	{
		_action = action;
		_succeeded = NO;
	}
	return self;
}

@end

@interface ContentObject()
{
	dispatch_semaphore_t _pdfSemaphore;
	__block NSData *_expectedPdfData;
	
	NSMutableArray *_transforms;
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
	if (_fileName)
	{
		_data = [[XMLDataContent alloc] initWithFileAtPath:_fileName];
	}
}

- (void)unloadData
{
	_data = nil;
}

- (void)setTransform:(XMLDataTransform*)transform forAction:(ContentObjectAction)action
{
	if (transform)
	{ _transforms[action] = layout; }
	else
	{ _transforms[action] = [NSNull null]; }
}

- (ContentTransformResult *)layoutForAction:(ContentObjectAction)action
{
	XMLDataTransform *xform = nil;
	
	id obj = _transforms[action];
	if (obj == [NSNull null])
	{ obj = _transforms[ContentObjectActionDefault]; }
	if (obj != [NSNull null])
	{ xform = (XMLDataTransform*)obj; }
	
	NSDictionary *result;
	if (xform)
	{
		switch (action)
		{
			case ContentObjectActionWebView:
				result = [xform transformContentForWebView:_data readOnly:NO];
				break;
			case ContentObjectActionReadOnlyWebView:
				result = [xform transformContentForWebView:_data readOnly:YES];
				break;
			case ContentObjectActionPreview:
				result = [xform transformContentForPreview:_data];
				break;
			case ContentObjectActionShare:
				result = [xform transformContentForSharing:_data];
				break;
			case ContentObjectActionPrint:
				result = [xform transformContentForPrinting:_data];
				break;
			case ContentObjectActionExportToPDF:
				result = [xform transformContentForExportToPDF:_data];
				break;
			default:
				result = nil;
		}
	}
	
	if (result)
	{ return [[ContentTransformResult alloc] initWithXMLDataLayoutResult:result]; }
	else
	{ return [[ContentTransformResult alloc] initWithFailureForAction:action]; }
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
	return [self placeholderImage];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	if ([activityType compare:UIActivityTypeAirDrop] == NSOrderedSame)
	{
		return [self placeholderName];
	}
	return [self placeholderName];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType
{
	if ([activityType compare:UIActivityTypeAirDrop] == NSOrderedSame)
	{
		return [NSString stringWithFormat:@"com.abject-entertainment.toolkit.%@", [self contentType]];
	}
	else if ([activityType compare:UIActivityTypeOpenInIBooks] == NSOrderedSame)
	{
		return @"com.adobe.pdf";
	}
	return nil;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	if ([activityType compare:UIActivityTypeAirDrop] == NSOrderedSame)
	{ // air drop!
		return [self dataForSharing];
	}
	else if ([activityType compare:UIActivityTypePrint] == NSOrderedSame)
	{
		return [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:[self htmlForPrinting]];
	}
	else if ([activityType compare:UIActivityTypeOpenInIBooks] == NSOrderedSame)
	{
		BNHtmlPdfKit *toPdf = [[BNHtmlPdfKit alloc] initWithPageSize:[BNHtmlPdfKit defaultPageSize]];
		toPdf.delegate = self;
		
		_expectedPdfData = nil;
		_pdfSemaphore = dispatch_semaphore_create(0);
		
		NSString *html = [self htmlForPrinting];
		[toPdf saveHtmlAsPdf:html];
		
		dispatch_semaphore_wait(_pdfSemaphore, DISPATCH_TIME_FOREVER);
		_pdfSemaphore = nil;
		
		NSData *pdfData = _expectedPdfData;
		_expectedPdfData = nil;
		
		return pdfData;
	}
	
	return nil;
}

- (void)htmlPdfKit:(BNHtmlPdfKit *)htmlPdfKit didFailWithError:(NSError *)error
{
	_expectedPdfData = nil;
	dispatch_semaphore_signal(_pdfSemaphore);
}

- (void)htmlPdfKit:(BNHtmlPdfKit *)htmlPdfKit didSavePdfData:(NSData *)data
{
	_expectedPdfData = data;
	dispatch_semaphore_signal(_pdfSemaphore);
}

@end
