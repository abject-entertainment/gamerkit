//
//  ConnectionManager.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 7/31/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "ConnectionManager.h"

#import "DataManager.h"
#import "Character.h"
#import "CharacterListController.h"
#import "Ruleset.h"
#import "ConnectionServer.h"
#import "ConnectionClient.h"
#import "ShareableContent.h"

#import <objc/runtime.h>

@implementation ConnectionManager

- (id)init
{
	self = [super init];
	if (self)
	{
		services = [NSMutableSet setWithCapacity:1];
		connections = [NSMutableSet setWithCapacity:10];
	}
	return self;
}

- (void)startSharingContent:(ShareableContent*)content
{
	NSEnumerator *enumerator = [services objectEnumerator];
	ConnectionServer *value = nil;
	while ((value = (ConnectionServer*)[enumerator nextObject]))
	{
		if (value.contentShared == content)
		{
			return;
		}
	}
	
	ConnectionServer *service = [[ConnectionServer alloc] initWithContent:content];
	[service startServer];
	[services addObject:service];
}

- (void)lookForSharedContent:(NSObject<NetServiceConsumer>*)delegate forClass:(Class)c;
{
	if (delegate == nil) return;
	
	serviceConsumer = delegate;
	
	if (browser == nil)
	{
		browser = [[NSNetServiceBrowser alloc] init];
		browser.delegate = self;
	}
	
	if (browser)
	{
		[browser stop];
		[serviceConsumer clearServices];
		[browser searchForServicesOfType:[ShareableContent contentTypeForClass:c] inDomain:@"local."];
	}
}

- (void)client:(ConnectionClient*)client doneReceiving:(NSData*)data forContent:(NSString*)contentType
{
	Class c = [ShareableContent classForContentType:contentType];
	if (c)
	{
		id inst = [c alloc];
		if ([inst isKindOfClass:[ShareableContent class]])
			inst = [inst initWithSharedData:data];
	}
//	if ([contentType caseInsensitiveCompare:[ConnectionManager contentTypeForClass:[Character class]]] == NSOrderedSame)
//	{
//		Character *c = [[Character alloc] initWithXMLString:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
//		if (c)
//		{
//			Ruleset *rules = [[DataManager getDataManager] rulesetForName:[c system]];
//			if (rules)
//			{
//				[rules addCharacter:c];
//				[c saveToFile];
//				[[[DataManager getDataManager] characterData] refreshData];
//			}
//		}
//	}
	[connections removeObject:client];
}

- (void)stopSearch
{
	if (browser)
		[browser stop];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)netServiceBrowser
{
	if (netServiceBrowser == browser && serviceConsumer)
	{
		[serviceConsumer connectionManagerDoneFindingServices:self];
		serviceConsumer = nil;
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing
{
	if (netServiceBrowser == browser && serviceConsumer)
	{
		if (netService)
			[serviceConsumer connectionManager:self foundNetService:netService];
		if (moreServicesComing == NO)
		{
			[serviceConsumer connectionManagerDoneFindingServices:self];
			serviceConsumer = nil;
		}
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing
{
	if (netServiceBrowser == browser && serviceConsumer)
	{
		if (netService)
			[serviceConsumer connectionManager:self lostNetService:netService];
		if (moreServicesComing == NO)
		{
			[serviceConsumer connectionManagerDoneFindingServices:self];
			serviceConsumer = nil;
		}
	}
}

- (void)downloadContentFromService:(NSNetService*)service
{
	NSEnumerator *enumerator = [connections objectEnumerator];
	ConnectionClient* client;
	while ((client = [enumerator nextObject]))
	{
		if (client && client.service == service)
			return;
	}
	client = [[ConnectionClient alloc] initForService:service withConnectionManager:self];
	[client startReceive];
	[connections addObject:client];
}

- (void)stopSharingContent:(ShareableContent *)content
{
	NSArray *aServices = [services allObjects];
	NSEnumerator *enumerator = [aServices objectEnumerator];
	ConnectionServer *service;
	while ((service = [enumerator nextObject]))
	{
		if (service && service.contentShared == content)
		{
			[service stopServer];
			[services removeObject:service];
		}
	}
}

@end
