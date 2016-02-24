//
//  RadialMenuButton.m
//  gamerkit
//
//  Created by Benjamin Taggart on 2/23/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "RadialMenuButton.h"

@implementation RadialMenuButton

+ (RadialMenuButton*)buttonWithImageNamed:(NSString*)imageName
{ return [[RadialMenuButton alloc] initWithImageNamed:imageName]; }
- (instancetype)initWithImageNamed:(NSString*)imageName
{ return [self initWithImage:[UIImage imageNamed:imageName]]; }
+ (RadialMenuButton*)buttonWithImage:(UIImage*)image
{ return [[RadialMenuButton alloc] initWithImage:image]; }

- (instancetype)initWithImage:(UIImage*)image
{
	self = [super initWithFrame:CGRectMake(0, 0, 64, 64)];
	if (self)
	{
		[self setImageForAllStates:image];
		[self setTitleForAllStates:@""];
		[self setBackgroundImages];
	}
	return self;
}

+ (RadialMenuButton*)buttonWithTitle:(NSString *)title
{ return [[RadialMenuButton alloc] initWithTitle:title]; }

- (instancetype)initWithTitle:(NSString *)title
{
	self = [super initWithFrame:CGRectMake(0, 0, 64, 64)];
	if (self)
	{
		[self setImageForAllStates:nil];
		[self setTitleForAllStates:title];
		[self setBackgroundImages];
	}

	return self;
}

- (void)setBackgroundImages
{
//	[self setBackgroundImage:[UIImage imageNamed:@"buttonPlaceholder"] forState:UIControlStateNormal];
//	[self setBackgroundImage:[UIImage imageNamed:@"buttonPlaceholder"] forState:UIControlStateHighlighted];
//	[self setBackgroundImage:[UIImage imageNamed:@"buttonPlaceholder"] forState:UIControlStateFocused];
//	[self setBackgroundImage:[UIImage imageNamed:@"buttonPlaceholder"] forState:UIControlStateDisabled];
//	[self setBackgroundImage:[UIImage imageNamed:@"buttonPlaceholder"] forState:UIControlStateSelected];
}

- (void)setImageForAllStates:(UIImage*)image
{
	[self setImage:image forState:UIControlStateNormal];
	[self setImage:image forState:UIControlStateHighlighted];
	[self setImage:image forState:UIControlStateFocused];
	[self setImage:image forState:UIControlStateDisabled];
	[self setImage:image forState:UIControlStateSelected];
}

- (void)setTitleForAllStates:(NSString*)title
{
	[self setTitle:title forState:UIControlStateNormal];
	[self setTitle:title forState:UIControlStateHighlighted];
	[self setTitle:title forState:UIControlStateFocused];
	[self setTitle:title forState:UIControlStateDisabled];
	[self setTitle:title forState:UIControlStateSelected];
}

@end
