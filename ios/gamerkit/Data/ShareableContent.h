//
//  ShareableContent.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/25/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ShareableContent : NSObject {
	BOOL bShared;
	NSData *sharedData;
	BOOL bFullyLoaded;
}

@property (nonatomic, readonly) NSString *sharedName;

+ (void)registerClass:(Class)c forContentType:(NSString*)contentType;
+ (Class)classForContentType:(NSString*)contentType;
+ (NSString *)contentTypeForClass:(Class)c;

- (BOOL)startSharing:(NSString*)sharedName;
- (void)stopSharing;
- (BOOL)isShared;

- (NSData*)dataForSharing; // abstract
- (NSString*)contentType; // abstract
- (id)initWithSharedData:(NSData*)data; // abstract
- (void)unload; // abstract
- (void)fullyLoad; // abstract

@end
