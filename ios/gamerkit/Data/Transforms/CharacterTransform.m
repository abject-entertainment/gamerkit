//
//  CharacterTransform.m
//  gamerkit
//
//  Created by Benjamin Taggart on 4/1/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharacterTransform.h"
#import "ContentTransformResult.h"
#import "ContentObject.h"
#import "ContentJSContext.h"

@interface ContentTransformResult (friend_ContentTransform)
- (instancetype)initWithAction:(ContentObjectAction)action;
- (void)setSucceeded:(BOOL)succeeded;
- (void)setTitle:(NSString*)title;
- (void)setSubtitle:(NSString *)subtitle;
- (void)setImage:(UIImage *)image;
- (void)setHtml:(NSString *)html;
- (void)setFile:(NSURL *)file;
- (void)setPrintFormatter:(UIPrintFormatter *)printFormatter;
@end

@interface CharacterTransform ()
{
}

@end

@implementation CharacterTransform

+ (CharacterTransform *)defaultTransform
{
	static CharacterTransform *_default;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_default = [[CharacterTransform alloc] init];
	});
	return _default;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
	}
	return self;
}

- (ContentTransformResult *)transformContentForPreview:(ContentObject*)content
{
	ContentTransformResult *result = [[ContentTransformResult alloc] initWithAction:ContentObjectActionPreview];
	
	ContentJSContext *js = [ContentJSContext contentContext];
	
	NSDictionary *preview = [js getPreviewData:content];
	
	result.title = preview[@"name"];
	result.subtitle = @"";
	result.image = [UIImage imageWithData: [[NSData alloc] initWithBase64EncodedString:preview[@"token"] options:0]];
	
	result.succeeded = result.html != nil;

	return result;
}

- (ContentTransformResult *)transformContentForSharing:(ContentObject*)content
{
	ContentTransformResult *result = [[ContentTransformResult alloc] initWithAction:ContentObjectActionShare];
	
	return result;
}

- (ContentTransformResult *)transformContentForPrinting:(ContentObject*)content
{
	ContentTransformResult *result = [[ContentTransformResult alloc] initWithAction:ContentObjectActionPrint];
	
	return result;
}

- (ContentTransformResult *)transformContentForWebView:(ContentObject*)content readOnly:(BOOL)readOnly
{
	ContentTransformResult *result = [[ContentTransformResult alloc] initWithAction:readOnly?ContentObjectActionReadOnlyWebView:ContentObjectActionWebView];
	
	ContentJSContext *js = [ContentJSContext contentContext];
	
	result.html = [js generateHTMLForCharacter:(Character*)content withAction:result.action];
	
	result.succeeded = result.html != nil;
	
	return result;
}

- (ContentTransformResult *)transformContentForExportToPDF:(ContentObject*)content
{
	ContentTransformResult *result = [[ContentTransformResult alloc] initWithAction:ContentObjectActionExportToPDF];
	
	return result;
}


@end
