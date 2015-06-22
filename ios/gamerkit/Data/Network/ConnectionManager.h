//
//  ConnectionManager.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 7/31/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Character;
@class ConnectionClient;
@class ConnectionManager;
@class ShareableContent;

@protocol NetServiceConsumer

- (void)connectionManager:(ConnectionManager*)cm foundNetService:(NSNetService*)service;
- (void)connectionManager:(ConnectionManager*)cm lostNetService:(NSNetService*)service;
- (void)connectionManagerDoneFindingServices:(ConnectionManager*)cm;
- (void)clearServices;

@end


@interface ConnectionManager : NSObject <NSNetServiceBrowserDelegate> {
	NSMutableSet* services;
	NSMutableSet* connections;
	
	NSNetServiceBrowser* browser;
	NSObject<NetServiceConsumer>* serviceConsumer;
}

- (id)init;

- (void)startSharingContent:(ShareableContent*)content;
- (void)lookForSharedContent:(NSObject<NetServiceConsumer>*)delegate forClass:(Class)c;
- (void)downloadContentFromService:(NSNetService*)service;
- (void)client:(ConnectionClient*)client doneReceiving:(NSData*)data forContent:(NSString*)contentType;

- (void)stopSearch;
- (void)stopSharingContent:(ShareableContent*)content;

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)netServiceBrowser;
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing;
@end
