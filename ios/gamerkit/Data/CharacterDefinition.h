//
//  CharacterDefinition.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 5/22/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Attribute.h"

@class Ruleset;
@class Character;
@class CharacterLayout;

@interface CharacterDefinition : NSObject {
	Ruleset *rules;
}

@property (readonly, nonatomic, retain) NSString* name;
@property (readonly, nonatomic, retain) NSString* displayName;
@property (readonly, nonatomic, retain) NSArray* attributeSet;
@property (readonly, nonatomic) NSMutableDictionary* sheets;

@property (nonatomic, retain) NSString *createSheet;
@property (nonatomic, retain) NSString *editSheet;
@property (nonatomic, retain) NSString *trackSheet;

- (id)initWithXmlNode:(void*)node andRuleset:(Ruleset*)rules;
- (void)addSheet:(CharacterLayout*)sheet;

- (Attribute*)attributeForName:(NSString*)name;

@end
