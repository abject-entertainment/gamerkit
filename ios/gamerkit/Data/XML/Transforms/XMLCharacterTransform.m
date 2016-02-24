//
//  XMLCharacterTransform.m
//  gamerkit
//
//  Created by Benjamin Taggart on 2/24/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "XMLCharacterTransform.h"
#import "XMLDataContent.h"
#import "ContentObject.h"

#include <libxml/parser.h>
#include <libxml/tree.h>
#include <libxslt/xslt.h>

@interface XMLDataContent (friend_XMLCharacterTransform)

- (xmlDocPtr)getXmlDocPtr;

@end

@implementation XMLCharacterTransform

- (NSDictionary *)transformContentForPreview:(XMLDataContent*)content
{
	return nil;
}

- (NSDictionary *)transformContentForSharing:(XMLDataContent*)content
{
	return nil;
}

- (NSDictionary *)transformContentForPrinting:(XMLDataContent*)content
{
	return nil;
}

- (NSDictionary *)transformContentForWebView:(XMLDataContent*)content readOnly:(BOOL)readOnly
{
	xmlDocPtr xml = [content getXmlDocPtr];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	
	NSNumber *action = [NSNumber numberWithUnsignedInteger:readOnly?ContentObjectActionReadOnlyWebView:ContentObjectActionWebView];
	[result setObject:action forKey:kXMLTransformKeyAction];
	[result setObject:@NO forKey:kXMLTransformKeySucceeded];
	[result setObject:[NSNull null] forKey:kXMLTransformKeyHTML];
	
	if (xml)
	{
	}
	
	return result;
}

- (NSDictionary *)transformContentForExportToPDF:(XMLDataContent*)content
{
	return nil;
}

@end
