//
//  CharacterLayout.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 5/22/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "CharacterLayout.h"


@implementation CharacterLayout

- (id)init {
	self = [super init];
	
	_name = nil;
	_charType = nil;
	_displayName = nil;
	_file = [[NSMutableDictionary alloc] initWithCapacity:2];
	
	return self;
}

@end
