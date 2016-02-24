//
//  Token.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/24/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentObject.h"

#define miniSize 128

@interface Token : ContentObject
@property (nonatomic) NSString* name;
@property (nonatomic, strong, setter=setImage:) UIImage* image;
@property (nonatomic, strong, readonly) UIImage *miniImage;
@property (nonatomic, readonly) NSString* file;

- (id)initWithFileAtPath:(NSString*)path;
- (id)initWithImage:(UIImage*)img;

- (void)writeToFile;

- (NSData*)dataForSharing;
+ (NSString*)contentType;
- (id)initWithSharedData:(NSData*)data;

@end
