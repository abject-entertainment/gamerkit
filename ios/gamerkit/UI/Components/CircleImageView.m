//
//  CircleImage.m
//  gamerkit
//
//  Created by Benjamin Taggart on 10/12/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import "CircleImageView.h"

@implementation CircleImageView

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self)
	{
		CALayer *maskLayer = [CALayer layer];
		UIImage *maskImage = [UIImage imageNamed:@"imageMask"];
		maskLayer.contents = (id)maskImage.CGImage;
		maskLayer.frame = self.frame;
	
		self.layer.mask = maskLayer;
		self.layer.masksToBounds = YES;
	}
	return self;
}

@end
