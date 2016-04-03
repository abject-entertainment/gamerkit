//
//  DataManager.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 5/25/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "ContentManager.h"
#import "PackageManager.h"
#import "Ruleset.h"
#import "Character.h"
#import "CharacterDefinition.h"
#import "Token.h"
#import "TokenListController.h"
#import "Map.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <objc/runtime.h>

@interface ContentObject (friend_ContentManager)
- (void)refreshPreview;
@end

@interface ContentManager() <PackageListConsumer>
{
	NSMutableSet<id<CharacterConsumer>> *_characterConsumers;
	NSMutableSet<id<TokenConsumer>> *_tokenConsumers;
	NSMutableSet<id<MapConsumer>> *_mapConsumers;
	
	NSString *_docsPath;
	Ruleset *_unknownRuleset;
}

@property (nonatomic, strong) NSMutableDictionary<NSString*,Ruleset*> *systems;
@property (nonatomic, strong) NSMutableDictionary<NSString*,Character*> *characters;
@property (nonatomic, strong) NSMutableDictionary<NSString*,Token*> *tokens;
@property (nonatomic, strong) NSMutableDictionary<NSString*,Map*> *maps;

@end

@implementation ContentManager

+(ContentManager *)contentManager
{
	static ContentManager *instance;
	static dispatch_once_t flag;
	dispatch_once(&flag, ^{
		instance = [[ContentManager alloc] initPrivate];
	});
	return instance;
}

-(instancetype) init
{
	[NSException raise:@"Singleton" format:@"Use +[ContentManager contentManager]"];
	return nil;
}

-(instancetype) initPrivate
{
	self = [super init];
	if (self)
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		_docsPath = [paths objectAtIndex:0];
		
		_systems = [[NSMutableDictionary alloc] init];
		
		_unknownRuleset = [[Ruleset alloc] initWithName:@"???" andDisplayName:@"Uninstalled System"];
		[_systems setObject:_unknownRuleset forKey:_unknownRuleset.name];

		_characters = [NSMutableDictionary dictionary];
		_tokens = [NSMutableDictionary dictionary];
		_maps = [NSMutableDictionary dictionary];

		_characterConsumers = [NSMutableSet<id<CharacterConsumer>> set];
		_tokenConsumers = [NSMutableSet<id<TokenConsumer>> set];
		_mapConsumers = [NSMutableSet<id<MapConsumer>> set];

		[[PackageManager packageManager] addPackageListConsumer:self];
	}
	return self;
}

- (void)addCharacterConsumer:(id<CharacterConsumer>)consumer
{
	@synchronized(_characterConsumers)
	{
		if ([_characterConsumers member:consumer] == nil)
		{
			[_characterConsumers addObject:consumer];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[_characters enumerateKeysAndObjectsUsingBlock:^(NSString *key, Character * _Nonnull obj, BOOL * _Nonnull stop) {
					[consumer characterAdded:obj];
				}];
			});
		}
	}
}

- (void)removeCharacterConsumer:(id<CharacterConsumer>)consumer
{
	@synchronized(_characterConsumers) {
		[_characterConsumers removeObject:consumer];
	}
}

- (void)characterAdded:(Character*)character
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id<CharacterConsumer> consumer in _characterConsumers)
		{
			[consumer characterAdded:character];
		}
	});
}

- (void)characterRemoved:(Character*)character
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id<CharacterConsumer> consumer in _characterConsumers)
		{
			[consumer characterRemoved:character];
		}
	});
}

- (void)characterUpdated:(Character*)character
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id<CharacterConsumer> consumer in _characterConsumers)
		{
			[consumer characterUpdated:character];
		}
	});
}

- (void)addTokenConsumer:(id<TokenConsumer>)consumer
{
	@synchronized(_tokenConsumers)
	{
		if ([_tokenConsumers member:consumer] == nil)
		{
			[_tokenConsumers addObject:consumer];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[_tokens enumerateKeysAndObjectsUsingBlock:^(NSString *key, Token * _Nonnull obj, BOOL * _Nonnull stop) {
					[consumer tokenAdded:obj];
				}];
			});
		}
	}
}

- (void)removeTokenConsumer:(id<TokenConsumer>)consumer
{
	@synchronized(_tokenConsumers) {
		[_tokenConsumers removeObject:consumer];
	}
}

- (void)tokenAdded:(Token*)token
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id<TokenConsumer> consumer in _tokenConsumers)
		{
			[consumer tokenAdded:token];
		}
	});
}

- (void)tokenRemoved:(Token*)token
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id<TokenConsumer> consumer in _tokenConsumers)
		{
			[consumer tokenRemoved:token];
		}
	});
}

- (void)tokenUpdated:(Token*)token
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id<TokenConsumer> consumer in _tokenConsumers)
		{
			[consumer tokenUpdated:token];
		}
	});
}

- (void)addMapConsumer:(id<MapConsumer>)consumer
{
	@synchronized(_mapConsumers)
	{
		if ([_mapConsumers member:consumer] == nil)
		{
			[_mapConsumers addObject:consumer];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[_maps enumerateKeysAndObjectsUsingBlock:^(NSString *key, Map * _Nonnull obj, BOOL * _Nonnull stop) {
					[consumer mapAdded:obj];
				}];
			});
		}
	}
}

- (void)removeMapConsumer:(id<MapConsumer>)consumer
{
	@synchronized(_mapConsumers) {
		[_mapConsumers removeObject:consumer];
	}
}

- (void)mapAdded:(Map*)map
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id<MapConsumer> consumer in _mapConsumers)
		{
			[consumer mapAdded:map];
		}
	});
}

- (void)mapRemoved:(Map*)map
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id<MapConsumer> consumer in _mapConsumers)
		{
			[consumer mapRemoved:map];
		}
	});
}

- (void)mapUpdated:(Map*)map
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id<MapConsumer> consumer in _mapConsumers)
		{
			[consumer mapUpdated:map];
		}
	});
}

-(void)installedPackageLost:(PackageData *)package
{
	Ruleset *rules = _systems[package.tag];
	[_systems removeObjectForKey:package.tag];
	
	// remove data related to this system
	for (Character *c in rules.characters)
	{
		[_unknownRuleset addCharacter: c];
		[self characterUpdated:c];
	}
	
	[rules.characters removeAllObjects];
}

-(void)installedPackageFound:(PackageData *)package
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	
	// scan package dir for files
	NSString *packageDir = [_docsPath stringByAppendingPathComponent:package.tag];
	
	NSArray<NSString*> *files = [fm contentsOfDirectoryAtPath:packageDir error:&error];
	
	for (NSString *file in files)
	{
		if ([file hasSuffix:@".gtsystem"])
		{
			Ruleset *rules = (Ruleset*)[self loadContentObjectOfClass:Ruleset.class fromPath:[package.tag stringByAppendingPathComponent:file]];
			
			[_systems setObject:rules forKey:rules.name];
		}
	}
	
	// scan characters dir for new characters
	NSString *charsDir = [_docsPath stringByAppendingPathComponent:@"Characters"];
	
	if (![fm fileExistsAtPath:charsDir])
	{
		[fm createDirectoryAtPath:charsDir withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	files = [fm contentsOfDirectoryAtPath:charsDir error:&error];
	
	for (NSString *file in files)
	{
		if ([file hasSuffix:@".gtchar"])
		{
			NSString *path = [@"Characters" stringByAppendingPathComponent:file];
			Character *exists = _characters[path];
			if (exists == nil)
			{
				Character *character = (Character*)[self loadContentObjectOfClass:Character.class fromPath:path];
				
				if (character)
				{
					NSString *system = character.system;
					Ruleset *rules = _systems[system];
					if (rules == nil)
					{ rules = _unknownRuleset; }
					
					[rules addCharacter:character];
					[_characters setObject:character forKey:path];
					[self characterAdded:character];
				}
			}
			else if ([exists.system isEqualToString:package.tag])
			{
				[exists refreshPreview];
				[self characterUpdated:exists];
			}
		}
	}
	
	NSString *mediaDir = [_docsPath stringByAppendingPathComponent:@"Media"];
	
	if (![fm fileExistsAtPath:mediaDir])
	{
		[fm createDirectoryAtPath:mediaDir withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	files = [fm contentsOfDirectoryAtPath:mediaDir error:&error];
	
	for (NSString *file in files)
	{
		if ([file hasSuffix:@".gttoken"])
		{
			NSString *path = [@"Media" stringByAppendingString:file];
			if (_tokens[path] == nil)
			{
				Token *token = (Token*)[self loadContentObjectOfClass:Token.class fromPath:[@"Media" stringByAppendingString:file]];
			
				if (token)
				{
					[_tokens setObject:token forKey:path];
					[self tokenAdded:token];
				}
			}
		}
		else if ([file hasSuffix:@".gtmap"])
		{
			NSString *path = [@"Media" stringByAppendingString:file];
			if (_maps[path] == nil)
			{
				Map	*map = (Map*)[self loadContentObjectOfClass:Map.class fromPath:[@"Media" stringByAppendingString:file]];
				
				if (map)
				{
					[_maps setObject:map forKey:path];
					[self mapAdded:map];
				}
			}
		}
	}
}

-(Ruleset*) systemForId:(NSString*)name
{
	if (_systems == nil) return nil;
	Ruleset *rules = [_systems objectForKey:name];
	if (rules == nil) return _unknownRuleset;
	return rules;
}

-(NSEnumerator<Ruleset *> *)enumerateSystems
{
	return _systems.objectEnumerator;
}

- (ContentObject*)loadContentObjectOfClass:(Class)clss fromPath:(NSString *)path
{
	id obj = [clss alloc];
	if ([obj isKindOfClass:ContentObject.class])
	{
		ContentObject *co = [obj initWithFile:[_docsPath stringByAppendingPathComponent:path]];
		
		return co;
	}
	return nil;
}

- (NSURL*)baseURLForDisplayOfCharacter:(Character *)character
{
	Ruleset *rules = [self systemForId:character.system];
	return [NSURL URLWithString:[_docsPath stringByAppendingPathComponent:[rules contentPath]]];
}

- (void)deleteContent:(ContentObject *)content
{
}

@end
