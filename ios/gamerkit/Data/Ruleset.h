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

#import <Foundation/Foundation.h>

@class DataSet;
#import "Attribute.h"
@class CharacterDefinition;
@class CharacterLayout;
@class EncounterElement;
@class OptionSet;

#include <libxml/parser.h>

@class Character;

@interface Ruleset : NSObject {
	NSMutableDictionary *dataSets;
	NSMutableDictionary *attributesByName;
	NSMutableDictionary *attributesById;
	
	NSMutableDictionary *_characterTypes;
	NSMutableDictionary *_characterSheets;
	NSMutableDictionary *_imports;
	
	NSMutableArray *supplementFiles;
}

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *displayName;
@property (nonatomic, readonly, copy) NSString *file;

@property (nonatomic, readonly, retain) NSDictionary* characterTypes;
@property (nonatomic, readonly, retain) NSDictionary* characterSheets;

@property (nonatomic, retain) NSMutableArray* characters;
@property (nonatomic, readonly, retain) NSDictionary* imports;

- (id)initWithName:(NSString*)name andDisplayName:(NSString*)displayName;
- (id)initWithFileAtPath:(NSString*)path;

- (bool)load;
- (void)unload;
- (void)loadSupplementFromFile:(NSString*)path;

- (AttributeRef)attributeRefForName:(NSString*)inName;
- (Attribute*)attributeForName:(NSString*)inName;
- (Attribute*)attributeForRef:(AttributeRef)ref;
- (DataSet*)dataSetForName:(NSString*)inName;
- (CharacterDefinition*)characterDefinitionForName:(NSString*)inName;

// root type load functions
- (DataSet *)loadDataSet:(xmlNode*)element;
- (Attribute *)loadAttribute:(xmlNode*)element withUid:(int)inUid;
- (CharacterDefinition *)loadCharacterDefinition:(xmlNode*)element;
- (CharacterLayout *)loadCharacterLayout:(xmlNode*)element withDocsPath:(NSString*)docsPath;
- (EncounterElement *)loadEncounterElement:(xmlNode*)element;

// sub-type load functions
- (AttributeRef)loadAttributeRef:(xmlNode*)element;
- (OptionSet *)loadOptionSet:(xmlNode*)firstElement;

- (void)addCharacter:(Character*)c;
- (void)deleteCharacter:(Character*)c;
- (void)deleteThisSystemAndItsContent:(BOOL)shouldDeleteContent;
@end
