//
//  ConnectionClient.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 8/3/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConnectionServer;
@class ConnectionManager;

enum {
    kSendBufferSize = 32768
};

@interface ConnectionClient : NSObject <NSStreamDelegate, NSNetServiceDelegate> {
	NSOutputStream *output;
	NSInputStream *input;
	
	// sending
	ConnectionServer *server;

	// receiving
	NSNetService *service;
	ConnectionManager *connMgr;
	
    uint8_t buffer[kSendBufferSize];
    size_t bufferOffset;
    size_t bufferLimit;
}

@property (readonly) NSNetService *service;

- (id)initForServer:(ConnectionServer*)server;
- (id)initForService:(NSNetService*)inService withConnectionManager:(ConnectionManager*)inConnMgr;
- (void)startSend:(int)fp ofData:(NSData*)data;
- (void)startReceive;

@end
