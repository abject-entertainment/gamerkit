//
//  RadialMenuButton.h
//  gamerkit
//
//  Created by Benjamin Taggart on 2/23/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadialMenuButton : UIButton

+ (RadialMenuButton*)buttonWithImageNamed:(NSString*)imageName;
- (instancetype)initWithImageNamed:(NSString*)imageName;

+ (RadialMenuButton*)buttonWithImage:(UIImage*)image;
- (instancetype)initWithImage:(UIImage*)image;

+ (RadialMenuButton*)buttonWithTitle:(NSString*)title;
- (instancetype)initWithTitle:(NSString*)title;

@end
