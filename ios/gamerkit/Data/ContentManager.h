//
//  DataManager.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 5/25/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "ModalPicker.h"

@class JSContext;

@class ContentObject;
@class Ruleset;
@class Character;
@class Token;
@class Map;

@protocol CharacterConsumer <NSObject>
- (void)characterAdded:(Character*)character;
- (void)characterRemoved:(Character*)character;
- (void)characterUpdated:(Character*)character;
@end

@protocol TokenConsumer <NSObject>
- (void)tokenAdded:(Token*)token;
- (void)tokenRemoved:(Token*)token;
- (void)tokenUpdated:(Token*)token;
@end

@protocol MapConsumer <NSObject>
- (void)mapAdded:(Map*)map;
- (void)mapRemoved:(Map*)map;
- (void)mapUpdated:(Map*)map;
@end

/*
typedef enum _PickTarget {
	PICK_None,
	PICK_System,
	PICK_SystemAndType,
	PICK_CharacterView,
	PICK_Import,
	
	PICK_MAX
} PickTarget;
*/

@protocol PackageListener;

@interface ContentManager : NSObject

+ (ContentManager *)contentManager;

- (void)addCharacterConsumer:(id<CharacterConsumer>)consumer;
- (void)removeCharacterConsumer:(id<CharacterConsumer>)consumer;
- (void)addTokenConsumer:(id<TokenConsumer>)consumer;
- (void)removeTokenConsumer:(id<TokenConsumer>)consumer;
- (void)addMapConsumer:(id<MapConsumer>)consumer;
- (void)removeMapConsumer:(id<MapConsumer>)consumer;

- (Ruleset*)systemForId:(NSString *)id;
- (NSEnumerator<Ruleset*>*)enumerateSystems;

- (void)deleteContent:(ContentObject*)content;

- (ContentObject *)loadContentObjectOfClass:(Class)clss fromPath:(NSString*)path;

- (NSURL *)baseURLForDisplayOfCharacter:(Character*)character;

@end

@protocol PackageListener
- (void)packageListObtained:(ContentManager *)dm;
@end


