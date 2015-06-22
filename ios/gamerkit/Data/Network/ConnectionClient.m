//
//  ConnectionClient.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 8/3/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "ConnectionClient.h"
#import "ConnectionServer.h"
#import "ConnectionManager.h"

@implementation ConnectionClient
@synthesize service;

- (id)initForServer:(ConnectionServer*)inServer
{
	self = [super init];
	if (self)
	{
		input = nil;
		output = nil;
		server = inServer;
		service = nil;
	}
	return self;
}

- (id)initForService:(NSNetService*)inService withConnectionManager:(ConnectionManager*)inConnMgr
{
	self = [super init];
	if (self)
	{
		input = nil;
		output = nil;
		server = nil;
		service = inService;
		service.delegate = self;
		connMgr = inConnMgr;
	}
	return self;
}

- (void)startSend:(int)fd ofData:(NSData*)data
{
    CFWriteStreamRef    writeStream;
	
    assert(fd >= 0);
	
    assert(output == nil);      // can't already be sending
    assert(input == nil);         // ditto
	
    // Open a stream for the file we're going to send.
	
    input = [NSInputStream inputStreamWithData:data];
    assert(input != nil);
    
    [input open];
	
    // Open a stream based on the existing socket file descriptor.  Then configure 
    // the stream for async operation.
	
    CFStreamCreatePairWithSocket(NULL, fd, NULL, &writeStream);
    assert(writeStream != NULL);
    
    output = (__bridge NSOutputStream *) writeStream;

    CFRelease(writeStream);
	
    [output setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
	
    output.delegate = self;
    [output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [output open];
}

- (void)doneSending
{
    if (output != nil) {
        [output removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        output.delegate = nil;
        [output close];
        output = nil;
    }
    if (input != nil) {
        [input close];
        input = nil;
    }
    bufferOffset = 0;
    bufferLimit  = 0;
	
	if (server)
	{
		[server clientFinished:self];
	}
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    BOOL                success;
    
    assert(input == nil);      // don't tap receive twice in a row!
    assert(output == nil);         // ditto
	assert(service != nil);
	
    // Open a stream for the file we're going to receive into.
	
    output = [NSOutputStream outputStreamToMemory];
    assert(output != nil);
    
    [output open];
	
    // Open a stream to the server, finding the server via Bonjour.  Then configure 
    // the stream for async operation.
	
    success = [service getInputStream:&input outputStream:NULL];
    assert(success);
    
    input.delegate = self;
    [input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [input open];
}

- (void)netService:(NSNetService*)inService didNotResolve:(NSDictionary*)errDict
{
	fprintf(stdout, "Net service did not resolve.\n");
}

- (void)startReceive
{
	assert(service != nil);
	[service resolveWithTimeout:15];
}

- (void)doneReceiving
{
	NSData *data = [output propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
	NSString *contentType = [service type];
	
	service.delegate = nil;
    service = nil;
    if (input != nil) {
        input.delegate = nil;
        [input removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [input close];
        input = nil;
    }
    if (output != nil) {
        [output close];
        output = nil;
    }
	
	if (connMgr)
		[connMgr client:self doneReceiving:data forContent:contentType];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our 
// network stream.
{
#pragma unused(aStream)
	
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
//            [self _updateStatus:@"Opened connection"];
        } break;
        case NSStreamEventHasBytesAvailable: {
            NSInteger       bytesRead;
//            uint8_t         buffer[32768];
			
//            [self _updateStatus:@"Receiving"];
            
            // Pull some data off the network.
            
            bytesRead = [input read:buffer maxLength:sizeof(buffer)];
            if (bytesRead == -1) {
//                [self _stopReceiveWithStatus:@"Network read error"];
            } else if (bytesRead == 0) {
//                [self _stopReceiveWithStatus:nil];
				[self doneReceiving];
				break;
            } else {
                NSInteger   bytesWritten;
                NSInteger   bytesWrittenSoFar;
                
                // Write to the file.
				fprintf(stdout, "Receiving %d bytes\n", (int)bytesRead);
                
                bytesWrittenSoFar = 0;
                do {
                    bytesWritten = [output write:&buffer[bytesWrittenSoFar] maxLength:bytesRead - bytesWrittenSoFar];
                    assert(bytesWritten != 0);
                    if (bytesWritten == -1) {
//                        [self _stopReceiveWithStatus:@"File write error"];
                        break;
                    } else {
                        bytesWrittenSoFar += bytesWritten;
                    }
                } while (bytesWrittenSoFar != bytesRead);
            }
        } break;
        case NSStreamEventHasSpaceAvailable: {
//            [self _updateStatus:@"Sending"];
			
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (bufferOffset == bufferLimit) {
                NSInteger   bytesRead;
                
                bytesRead = [input read:buffer maxLength:kSendBufferSize];
                
                if (bytesRead == -1) {
//                    [self _stopSendWithStatus:@"File read error"];
                } else if (bytesRead == 0) {
//                    [self _stopSendWithStatus:nil];
					[self doneSending];
					break;
                } else {
                    bufferOffset = 0;
                    bufferLimit  = bytesRead;
                }
            }
			
            // If we're not out of data completely, send the next chunk.
            
            if (bufferOffset != bufferLimit) {
				fprintf(stdout, "Sending %d bytes\n", (int)bufferLimit);
                NSInteger   bytesWritten;
                bytesWritten = [output write:&buffer[bufferOffset] maxLength:bufferLimit - bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
//                    [self _stopSendWithStatus:@"Network write error"];
                } else {
                    bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
//            [self _stopSendWithStatus:@"Stream open error"];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}

@end
