//
//  Ruleset.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 2/19/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

/*
 The Ruleset class represents a set of definitions for an RPG system.  It defines:
 1. The types of characters (PC, NPC, Monster, Minion, etc) available.
 2. An attribute set for each type of character.
 3. One or more character sheet layouts for each type of character.
 4. Encounter attribute sets.
 5. Rule sets for running encounters.
 */

#import "ContentObject.h"

@class Character;
@class DataSet;
@class Attribute;
@class CharacterDefinition;
@class CharacterLayout;
@class EncounterElement;
@class OptionSet;

@interface Ruleset : ContentObject

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *displayName;

@property (nonatomic, readonly, strong) NSDictionary<NSString*,CharacterDefinition*>* characterTypes;
@property (nonatomic, readonly, strong) NSDictionary<NSString*,CharacterLayout*>* characterSheets;

@property (nonatomic, readonly, strong) NSMutableArray* characters;
@property (nonatomic, readonly, strong) NSDictionary* imports;

- (id)initWithName:(NSString*)name andDisplayName:(NSString*)displayName;

- (bool)load;
- (void)unload;
- (void)loadSupplementFromFile:(NSString*)path;

- (Attribute*)attributeForName:(NSString*)inName;
- (DataSet*)dataSetForName:(NSString*)inName;

- (void)addCharacter:(Character*)c;
- (void)deleteCharacter:(Character*)c;

@end
