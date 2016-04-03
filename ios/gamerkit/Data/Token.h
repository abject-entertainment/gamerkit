//
//  Token.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/24/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentObject.h"

extern uint miniTokenSize;

@interface Token : ContentObject
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong, readonly) UIImage *miniImage;

- (id)initWithImage:(UIImage*)img;

@end
