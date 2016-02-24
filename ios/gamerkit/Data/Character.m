//
//  Character.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 2/19/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "Character.h"
#import "Import.h"
#import "CharacterDefinition.h"
#import "DataManager.h"
#import "CharacterListController.h"
#import "Attribute.h"
#import "DataSet.h"
#import "Ruleset.h"
#import "Token.h"

#import "XMLDataContent.h"

static const NSString *kXPath_Character_Name = @"/attribute[@name=\"Name\"]";
static const NSString *kXPath_Character_System = @"/@system";
static const NSString *kXPath_Character_Type = @"/@type";
static const NSString *kXPath_Character_Token = @"/attribute[@name=\"Token\"]";

@implementation Character

- (NSString*)name
{ return [self.data valueAtPath:kXPath_Character_Name]; }

- (NSString*)system
{ return [self.data valueAtPath:kXPath_Character_System]; }

- (NSString*)charType
{ return [self.data valueAtPath:kXPath_Character_Type]; }

- (UIImage*)token
{ return [self.data imageAtPath:kXPath_Character_Token]; }

- (void)setToken:(UIImage *)token
{ [self.data setImage:token atPath:kXPath_Character_Token]; }

- (void)createMiniImage
{
	_miniImage = nil;
	
	UIImage *img = self.token;
	if (img)
	{
		UIGraphicsBeginImageContext(CGSizeMake(miniSize, miniSize));
		[img drawInRect:CGRectMake(0,0,miniSize,miniSize)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		_miniImage = img;
		UIGraphicsEndImageContext();
	}
}

- (id)initForSystem:(NSString*)inSystem andType:(NSString*)inType{
	self = [super init];
	if (self) {
		Ruleset *rules = [[DataManager getDataManager] rulesetForName:inSystem];
		if (rules)
		{
			[rules addCharacter:self];
		}
		
	}
	return self;
}

- (NSString *)generateFileName {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *path = [[DataManager getDataManager] docsPath];
	path = [path stringByAppendingPathComponent:@"Characters/%08x.char"];
	NSString *fileName = nil;
	
	do
	{
		fileName = [NSString stringWithFormat:path, random()];
	} while ([fm fileExistsAtPath:fileName]);
	
	return fileName;
}

@end
