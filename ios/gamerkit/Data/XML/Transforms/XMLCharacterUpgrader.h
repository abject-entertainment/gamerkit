//
//  XMLCharacterUpgrader.h
//  gamerkit
//
//  Created by Benjamin Taggart on 2/24/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMLDataContent;

@interface XMLCharacterUpgrader : NSObject

+ (BOOL)upgradeCharacterData:(XMLDataContent*)data;

@end
