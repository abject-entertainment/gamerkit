//
//  ContentJSContext.h
//  gamerkit
//
//  Created by Benjamin Taggart on 4/1/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentObject.h"

@class Character;
@class Token;
@class ContentJSContext;

@interface ContentJSContext : NSObject

+ (ContentJSContext*)contentContext;

- (NSString*)generateHTMLForCharacter:(Character*)character withAction:(ContentObjectAction)action;

- (NSDictionary*)getPreviewData:(ContentObject*)object;

@end
