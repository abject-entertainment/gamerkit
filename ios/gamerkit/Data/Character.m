//
//  Character.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 2/19/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "Character.h"
#import "ContentManager.h"
#import "ContentTransformResult.h"
#import "Ruleset.h"
#import "CharacterTransform.h"

#import "XMLDataContent.h"
#import "XMLCharacterUpgrader.h"

extern uint miniTokenSize;

extern const NSString *kXPath_Character_Name;
extern const NSString *kXPath_Character_System;
extern const NSString *kXPath_Character_Type;
extern const NSString *kXPath_Character_Token;

@interface Character()
{
}
@end

@implementation Character

- (NSString*)name
{ return [self getPreview].title; }

- (UIImage*)token
{ return [self getPreview].image; }

- (void)setToken:(UIImage *)token
{ [self.data setImage:token atPath:kXPath_Character_Token]; }

- (NSString*)contentPath
{ return @"Characters"; }

- (instancetype)initForSystem:(NSString*)inSystem andType:(NSString*)inType{
	self = [super init];
	if (self)
	{
		Ruleset *rules = [[ContentManager contentManager] systemForId:inSystem];
		if (rules)
		{
			[rules addCharacter:self];
		}
	}
	return self;
}

- (instancetype)initWithFile:(NSString *)fileName
{
	self = [super initWithFile:fileName];
	if (self)
	{
		[self setTransform:[CharacterTransform defaultTransform] forAction:ContentObjectActionDefault];
		
		[self loadData];
		
		if ([XMLCharacterUpgrader upgradeCharacterData:self.data])
		{
			NSLog(@"Upgraded character \"%@\" to v2", self.name);
			//NSLog(@"%@", [self.data saveToString]);
			[self saveFile];
		}
		
		_system = [self.data valueAtPath:kXPath_Character_System];
		_charType = [self.data valueAtPath:kXPath_Character_Type];
		
		[self unloadData];
	}
	return self;
}

@end
