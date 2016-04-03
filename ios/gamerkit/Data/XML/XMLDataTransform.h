//
//  XMLDataLayout.h
//  gamerkit
//
//  Created by Benjamin Taggart on 2/24/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMLDataContent;

#define kXMLTransformKeyAction @"action"
#define kXMLTransformKeySucceeded @"succeeded"
#define kXMLTransformKeyTitle @"title"
#define kXMLTransformKeySubtitle @"subtitle"
#define kXMLTransformKeyImage @"image"
#define kXMLTransformKeyHTML @"html"
#define kXMLTransformKeyFile @"file"
#define kXMLTransformKeyPrintFormatter @"print"

@interface XMLDataTransform : NSObject

+ (XMLDataTransform *)defaultTransform;

- (NSDictionary *)transformContentForPreview:(XMLDataContent*)content;
- (NSDictionary *)transformContentForSharing:(XMLDataContent*)content;
- (NSDictionary *)transformContentForPrinting:(XMLDataContent*)content;
- (NSDictionary *)transformContentForWebView:(XMLDataContent*)content readOnly:(BOOL)readOnly;
- (NSDictionary *)transformContentForExportToPDF:(XMLDataContent*)content;

@end
