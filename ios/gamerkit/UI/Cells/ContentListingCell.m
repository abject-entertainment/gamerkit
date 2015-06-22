//
//  ContentListingCell.m
//  gamerkit
//
//  Created by Benjamin Taggart on 6/3/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "ContentListingCell.h"

@interface ContentListingCell()
{
	UISwipeGestureRecognizer *_swipeLeftRecognizer;
	UISwipeGestureRecognizer *_swipeRightRecognizer;
}

@end

@implementation ContentListingCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		_swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
		_swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
		_swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
		_swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	}
	return self;
}

- (void)swipeLeft
{
}

- (void)swipeRight
{
}

@end
