//
//  XMLDataLayout.m
//  gamerkit
//
//  Created by Benjamin Taggart on 2/24/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "XMLDataTransform.h"

static XMLDataTransform *s_defaultTransform = nil;

@implementation XMLDataTransform

+ (XMLDataTransform *)defaultTransform
{
	if (s_defaultTransform == nil)
	{
		s_defaultTransform = [[XMLDataTransform alloc] init];
	}
	return s_defaultTransform;
}

- (NSDictionary *)transformContentForPreview:(XMLDataContent*)content
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	return result;
}

- (NSDictionary *)transformContentForSharing:(XMLDataContent*)content
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	return result;
}

- (NSDictionary *)transformContentForPrinting:(XMLDataContent*)content
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	return result;
}

- (NSDictionary *)transformContentForWebView:(XMLDataContent*)content readOnly:(BOOL)readOnly
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	return result;
}

- (NSDictionary *)transformContentForExportToPDF:(XMLDataContent*)content
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	return result;
}

@end
