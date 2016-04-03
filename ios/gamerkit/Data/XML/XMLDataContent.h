//
//  XMLDataContent.h
//  gamerkit
//
//  Created by Benjamin Taggart on 2/23/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMLDataTransform;

@interface XMLDataContent : NSObject

@property (nonatomic, readonly) BOOL dirty;
@property (nonatomic, readonly) BOOL valid;

- (NSInteger)dataVersion;

- (instancetype)initWithXmlString:(NSString *)xml;
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithFileAtPath:(NSString *)filepath;

- (NSString*)valueAtPath:(const NSString*)xpath;
- (UIImage*)imageAtPath:(const NSString*)xpath;
- (UIImage*)imageWithSize:(CGSize)size atPath:(const NSString*)xpath;

- (BOOL)setValue:(NSString*)value atPath:(const NSString*)xpath;
- (BOOL)setImage:(UIImage*)value atPath:(const NSString*)xpath;

- (void)saveToFile:(NSString *)filepath;
- (NSString*)saveToString;

@end
