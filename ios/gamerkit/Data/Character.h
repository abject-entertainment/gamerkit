//
//  Character.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 2/19/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharacterLayout.h"
#import "ContentObject.h"

@class Token;
@class UIImage;
@class Import;

@interface Character : ContentObject {
	NSMutableDictionary *attributeValues;
}

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *system;
@property (nonatomic, readonly, copy) NSString *charType;
@property (nonatomic, readonly, strong) UIImage *miniImage;
@property (nonatomic) UIImage *token;

- (id)initForSystem:(NSString*)system andType:(NSString*)type;

@end
