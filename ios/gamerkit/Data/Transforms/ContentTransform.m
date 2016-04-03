//
//  ContentTransform.m
//  gamerkit
//
//  Created by Benjamin Taggart on 4/1/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "ContentTransform.h"
#import "ContentTransformResult.h"
#import "ContentObject.h"

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

@interface ContentTransform ()

@end

static ContentTransform *_defaultTransform = nil;

@implementation ContentTransform

+ (ContentTransform *)defaultTransform
{
	static dispatch_once_t _1;
	dispatch_once(&_1, ^{
		_defaultTransform = [[ContentTransform alloc] init];
	});
	return _defaultTransform;
}

- (ContentTransformResult *)transformContentForPreview:(ContentObject*)content
{
	return [[ContentTransformResult alloc] initWithAction:ContentObjectActionPreview];
}

- (ContentTransformResult *)transformContentForSharing:(ContentObject*)content
{
	return [[ContentTransformResult alloc] initWithAction:ContentObjectActionShare];
}

- (ContentTransformResult *)transformContentForPrinting:(ContentObject*)content
{
	return [[ContentTransformResult alloc] initWithAction:ContentObjectActionPrint];
}

- (ContentTransformResult *)transformContentForWebView:(ContentObject*)content readOnly:(BOOL)readOnly
{
	return [[ContentTransformResult alloc] initWithAction:readOnly?ContentObjectActionReadOnlyWebView:ContentObjectActionWebView];
}

- (ContentTransformResult *)transformContentForExportToPDF:(ContentObject*)content
{
	return [[ContentTransformResult alloc] initWithAction:ContentObjectActionExportToPDF];
}

@end
