//
//  CharacterLayout.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 5/22/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CharacterLayout : NSObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* charType;
@property (nonatomic, copy) NSString* displayName;
@property (nonatomic, copy) NSString* file;

- (id)init;

@end
