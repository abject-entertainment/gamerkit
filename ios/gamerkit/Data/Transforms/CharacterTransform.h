//
//  CharacterTransform.h
//  gamerkit
//
//  Created by Benjamin Taggart on 4/1/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentTransform.h"

@interface CharacterTransform : ContentTransform

+ (CharacterTransform *)defaultTransform;

- (ContentTransformResult *)transformContentForPreview:(ContentObject*)content;
- (ContentTransformResult *)transformContentForSharing:(ContentObject*)content;
- (ContentTransformResult *)transformContentForPrinting:(ContentObject*)content;
- (ContentTransformResult *)transformContentForWebView:(ContentObject*)content readOnly:(BOOL)readOnly;
- (ContentTransformResult *)transformContentForExportToPDF:(ContentObject*)content;

@end
