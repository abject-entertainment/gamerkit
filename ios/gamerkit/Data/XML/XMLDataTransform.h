//
//  XMLDataLayout.h
//  gamerkit
//
//  Created by Benjamin Taggart on 2/24/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMLDataContent;

const NSString* kXMLTransformKeyAction = @"action";
const NSString* kXMLTransformKeySucceeded = @"succeeded";
const NSString* kXMLTransformKeyTitle = @"title";
const NSString* kXMLTransformKeySubtitle = @"subtitle";
const NSString* kXMLTransformKeyImage = @"image";
const NSString* kXMLTransformKeyHTML = @"html";
const NSString* kXMLTransformKeyFile = @"file";
const NSString* kXMLTransformKeyPrintFormatter = @"print";

@interface XMLDataTransform : NSObject

+ (XMLDataTransform *)defaultLayout;

- (NSDictionary *)transformContentForPreview:(XMLDataContent*)content;
- (NSDictionary *)transformContentForSharing:(XMLDataContent*)content;
- (NSDictionary *)transformContentForPrinting:(XMLDataContent*)content;
- (NSDictionary *)transformContentForWebView:(XMLDataContent*)content readOnly:(BOOL)readOnly;
- (NSDictionary *)transformContentForExportToPDF:(XMLDataContent*)content;

@end
