//
//  Map.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/31/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "Map.h"
#import "ContentManager.h"
#import "XMLDataContent.h"


#define CURRENT_VERSION ((NSUInteger)2)

extern uint miniTokenSize;

static const NSString *kXPath_Map_image = @"/map";

@interface Map ()
{
	UIImage *_miniImage;
}
@end

@implementation Map

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

- (UIImage *)image
{ return [self.data imageAtPath:kXPath_Map_image]; }

- (void)setImage:(UIImage*)newImage
{
	[self.data setImage:newImage atPath:kXPath_Map_image];
	[self createMiniImage];
}

- (UIImage *)miniImage
{
	if (_miniImage == nil)
	{ [self createMiniImage]; }
	return _miniImage;
}

@end
