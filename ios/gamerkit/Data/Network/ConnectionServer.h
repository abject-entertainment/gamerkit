//
//  ConnectionServer.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 8/3/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConnectionClient;
@class ShareableContent;

@interface ConnectionServer : NSObject <NSNetServiceDelegate> {
	NSNetService *service;
	NSData *contentData;
	CFSocketRef listeningSocket;
	
	NSMutableSet *connectedClients;
	
	NSInputStream *input;
	NSOutputStream *output;
}

@property (readonly, assign) ShareableContent *contentShared;

- (id)initWithContent:(ShareableContent*)content;

- (BOOL)startServer;
- (void)stopServer;

- (void)clientFinished:(ConnectionClient*)client;

@end
