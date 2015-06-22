//
//  NSStringAdditions.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/28/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSString.h>

@interface NSString (NSStringAdditions)
+ (NSString *) base64StringFromData:(NSData *)data length:(NSUInteger)length;
@end

@interface NSData (NSDataAdditions)
+ (NSData *) base64DataFromString:(const char *)string;
@end