//
//  ShareableContent.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/25/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "ShareableContent.h"

#import "DataManager.h"
#import "SharedContentDataStore.h"

static NSMutableDictionary *g_contentTypeClasses;

@implementation ShareableContent

+ (void)registerClass:(Class)c forContentType:(NSString*)contentType
{
	if (g_contentTypeClasses == nil)
	{
		g_contentTypeClasses = [[NSMutableDictionary alloc] initWithCapacity:5];
	}
	if ([g_contentTypeClasses objectForKey:contentType] == nil)
	{
		[g_contentTypeClasses setObject:c forKey:contentType];
	}
	if ([g_contentTypeClasses objectForKey:c] == nil)
	{
		[g_contentTypeClasses setObject:contentType forKey:NSStringFromClass(c)];
	}
}

+ (Class)classForContentType:(NSString*)contentType
{
	if (g_contentTypeClasses)
	{
		return [g_contentTypeClasses objectForKey:contentType];
	}
	return nil;
}

+ (NSString *)contentTypeForClass:(Class)c
{
	if (g_contentTypeClasses)
	{
		return [g_contentTypeClasses objectForKey:NSStringFromClass(c)];
	}
	return nil;
}

- (BOOL)startSharing:(NSString*)inSharedName
{
	if (bShared) return NO;
	
	_sharedName = inSharedName;
	sharedData = [self dataForSharing];

	bShared = YES;
	[[[[DataManager getDataManager] sharedData] connectionMgr] startSharingContent:self];
	
	return YES;
}

- (void)stopSharing
{
	if (bShared)
	{
		_sharedName = nil;
		sharedData = nil;
	}
	[[[[DataManager getDataManager] sharedData] connectionMgr] stopSharingContent:self];
	bShared = NO;
}

- (BOOL)isShared
{
	return bShared;
}

- (NSData*)dataForSharing
{ return nil; }
- (NSString*)contentType
{ return nil; }
- (id)initWithSharedData:(NSData*)data
{ return nil; }

- (void)unload {}
- (void)fullyLoad {}

@end
