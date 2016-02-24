//
//  Map.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/31/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentObject.h"

@interface Map : ContentObject

@property (nonatomic) NSString *name;
@property (nonatomic, strong, setter=setImage:) UIImage *image;
@property (nonatomic, strong, readonly) UIImage *miniImage;
@property (nonatomic) CGPoint gridOffset;
@property (nonatomic) CGFloat gridScale;
@property (nonatomic, readonly) NSString *path;

- (id)initWithFileAtPath:(NSString*)path;

- (void)writeToFile;

- (NSData*)dataForSharing;
+ (NSString*)contentType;
- (id)initWithSharedData:(NSData*)data;

@end
