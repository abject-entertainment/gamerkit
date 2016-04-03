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

@property (readonly, nonatomic, copy) NSString* name;
@property (readonly, nonatomic, copy) NSString* displayName;
@property (readonly, nonatomic, copy) NSArray* attributeSet;

@property (readonly, nonatomic, copy) CharacterLayout *printSheet;
@property (readonly, nonatomic, copy) CharacterLayout *editSheet;
@property (readonly, nonatomic, copy) CharacterLayout *viewSheet;

- (id)initWithXmlNode:(void*)node andRuleset:(Ruleset*)rules;

- (Attribute*)attributeForName:(NSString*)name;

@end
