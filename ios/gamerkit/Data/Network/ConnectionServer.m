//
//  ConnectionServer.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 8/3/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "ConnectionServer.h"

#include <sys/socket.h>
#include <netinet/in.h>

#import "Character.h"
#import "ConnectionManager.h"
#import "ConnectionClient.h"

@implementation ConnectionServer

- (id)initWithContent:(ShareableContent*)content
{
	self = [super init];
	if (self)
	{
		_contentShared = content;
		connectedClients = [NSMutableSet setWithCapacity:3];
		
		contentData = [self.contentShared dataForSharing];
	}
	return self;
}

- (void)startSend:(int)fd
{
	ConnectionClient *client = [[ConnectionClient alloc] initForServer:self];
	if (client)
	{
		[client startSend:fd ofData:contentData];
		[connectedClients addObject:client];
	}
}

- (void)clientFinished:(ConnectionClient*)client
{
	[connectedClients removeObject:client];
}

- (void)acceptConnection:(int)fd
{
    assert(fd >= 0);
	
    [self startSend:fd];
}

static void AcceptCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
// Called by CFSocket when someone connects to our listening socket.  
// This implementation just bounces the request up to Objective-C.
{
    ConnectionServer *  obj;
    
#pragma unused(type)
    assert(type == kCFSocketAcceptCallBack);
#pragma unused(address)
    // assert(address == NULL);
    assert(data != NULL);
    
    obj = (__bridge ConnectionServer *) info;
    assert(obj != nil);
	
#pragma unused(s)
    assert(s == obj->listeningSocket);
    
    [obj acceptConnection:*(int *)data];
}

- (void)netServiceWillPublish:(NSNetService *)sender
{
	fprintf(stdout, "Net service publish request underway.\n");
}

- (void)netServiceDidPublish:(NSNetService *)sender
{
	fprintf(stdout, "Net service started successfully.\n");
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
	fprintf(stdout, "Net service failed to start: %d.\n", (int)[errorDict objectForKey:NSNetServicesErrorCode]);
}

- (void)netServiceDidStop:(NSNetService *)sender
{
	fprintf(stdout, "Net service stopped succesfully.\n");
}

- (void)stopServer
{
	//    if (self.isSending) {
	//       [self _stopSendWithStatus:@"Cancelled"];
	//    }
    if (service != nil) {
        [service stop];
        service = nil;
    }
    if (listeningSocket != NULL) {
        CFSocketInvalidate(listeningSocket);
        listeningSocket = NULL;
    }
	//    [self _serverDidStopWithReason:reason];
}

- (BOOL)startServer
{
    BOOL        success;
    int         err;
    int         fd;
    int         junk;
    struct sockaddr_in addr;
    int         port;
    
    // Create a listening socket and use CFSocket to integrate it into our 
    // runloop.  We bind to port 0, which causes the kernel to give us 
    // any free port, then use getsockname to find out what port number we 
    // actually got.
    
    port = 0;
    
    fd = socket(AF_INET, SOCK_STREAM, 0);
    success = (fd != -1);
    if (success) {
        memset(&addr, 0, sizeof(addr));
        addr.sin_len    = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_port   = 0;
        addr.sin_addr.s_addr = INADDR_ANY;
        err = bind(fd, (const struct sockaddr *) &addr, sizeof(addr));
        success = (err == 0);
    }
    if (success) {
        err = listen(fd, 5);
        success = (err == 0);
    }
    if (success) {
        socklen_t   addrLen;
		
        addrLen = sizeof(addr);
        err = getsockname(fd, (struct sockaddr *) &addr, &addrLen);
        success = (err == 0);
        
        if (success) {
            assert(addrLen == sizeof(addr));
            port = ntohs(addr.sin_port);
        }
    }
    if (success) {
        CFSocketContext context = { 0, (__bridge void *)(self), NULL, NULL, NULL };
        
        listeningSocket = CFSocketCreateWithNative(
												   NULL, 
												   fd, 
												   kCFSocketAcceptCallBack, 
												   AcceptCallback, 
												   &context
												   );
        success = (listeningSocket != NULL);
        
        if (success) {
            CFRunLoopSourceRef  rls;
            
            CFRelease(listeningSocket);        // to balance the create
            
            fd = -1;        // listeningSocket is now responsible for closing fd
			
            rls = CFSocketCreateRunLoopSource(NULL, listeningSocket, 0);
            assert(rls != NULL);
            
            CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
            
            CFRelease(rls);
        }
    }
    
    // Now register our service with Bonjour.  See the comments in -netService:didNotPublish: 
    // for more info about this simplifying assumption.
    
    if (success) {
        service = [[NSNetService alloc] initWithDomain:@"" type:[self.contentShared contentType] name:[self.contentShared sharedName] port:port];
        success = (service != nil);
    }
    if (success) {
        service.delegate = self;
        
        [service publishWithOptions:NSNetServiceNoAutoRename];
        
        // continues in -netServiceDidPublish: or -netService:didNotPublish: ...
    }
    
    // Clean up after failure.
    
    if ( success ) 
	{
        assert(port != 0);
//        [self _serverDidStartOnPort:port];
		return YES;
    }
	else
	{
        [self stopServer]; //:@"Start failed"];
        if (fd != -1) 
		{
            junk = shutdown(fd, SHUT_RDWR);
            assert(junk == 0);
        }
		return NO;
    }
}

@end
