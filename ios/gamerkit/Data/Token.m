//
//  Token.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/24/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "Token.h"
#import "ContentManager.h"
#import "TokenListController.h"
#import "XMLDataContent.h"

#define CURRENT_VERSION ((NSUInteger)3)

uint miniTokenSize = 128;

static const NSString *kXPath_Token_Image = @"/token";

@implementation Token

- (void)createMiniImage
{
	_miniImage = nil;
	
	UIImage *img = self.image;
	if (img)
	{
		UIGraphicsBeginImageContext(CGSizeMake(miniTokenSize, miniTokenSize));
		[img drawInRect:CGRectMake(0,0,miniTokenSize,miniTokenSize)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		_miniImage = img;
		UIGraphicsEndImageContext();
	}
}

- (UIImage*)image
{ return [self.data imageAtPath:kXPath_Token_Image]; }
- (void)setImage:(UIImage *)newImage
{
	[self.data setImage:newImage atPath:kXPath_Token_Image];
	[self createMiniImage];
}

- (id)initWithImage:(UIImage*)img
{
	self = [self init];
	if (self)
	{
		self.image = img;
	}
	return self;
}

@end
