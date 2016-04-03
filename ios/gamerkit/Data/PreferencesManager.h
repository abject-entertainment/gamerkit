//
//  PreferencesManager.h
//  gamerkit
//
//  Created by Benjamin Taggart on 2/29/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferencesManager : NSObject

+ (PreferencesManager*)preferencesManager;

- (NSString*)getPreferenceForKey:(NSString*)key;
- (BOOL)setPreference:(id)pref forKey:(NSString*)key;

@end
