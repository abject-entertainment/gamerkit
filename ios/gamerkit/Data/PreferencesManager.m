//
//  PreferencesManager.m
//  gamerkit
//
//  Created by Benjamin Taggart on 2/29/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "PreferencesManager.h"

@interface PreferencesManager ()
{
	NSString *_prefsFile;
	NSMutableDictionary *_preferences;
}
@end

static const NSString *kPrefsFile = @"user.plist";

@implementation PreferencesManager

+(PreferencesManager *)preferencesManager
{
	static PreferencesManager *instance;
	static dispatch_once_t _1;
	dispatch_once(&_1, ^{
		instance = [[PreferencesManager alloc] initPrivate];
	});
	return instance;
}

-(instancetype) init
{
	[NSException raise:@"Singleton" format:@"Use +[PreferencesManager preferencesManager]"];
	return nil;
}

-(instancetype) initPrivate
{
	self = [super init];
	if (self)
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		_prefsFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:(NSString*)kPrefsFile];
		
		NSFileManager *fm = [NSFileManager defaultManager];
		if (![fm fileExistsAtPath:_prefsFile])
		{
			_preferences = [NSMutableDictionary dictionary];
		}
		else
		{
			_preferences = [NSMutableDictionary dictionaryWithContentsOfFile:_prefsFile];
		}
	}
	return self;
}

- (id)getPreferenceForKey:(NSString*)name
{
	if (_preferences)
	{
		return [_preferences objectForKey:name];
	}
	return nil;
}

- (BOOL)setPreference:(id)pref forKey:(id)key
{
	if (_preferences)
	{
		[_preferences setValue:pref forKey:key];
		return [_preferences writeToFile:_prefsFile atomically:YES];
	}
	
	return NO;
}

@end
