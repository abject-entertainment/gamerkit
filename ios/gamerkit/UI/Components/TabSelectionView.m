//
//  TabSelectionView.m
//  gamerkit
//
//  Created by Benjamin Taggart on 10/12/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import "TabSelectionView.h"

@interface TabSelectionView()
{
	UIView *_loadedView;
}
@end

@implementation TabSelectionView

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self setup];
	}
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[self setup];
	}
	return self;
}

- (void) setup
{
	self.autoresizesSubviews = YES;
	self.backgroundColor = [UIColor clearColor];
	
	UINib *nib = [UINib nibWithNibName:@"TabSelectionView" bundle:[NSBundle bundleForClass:self.class]];
	NSArray *objects = [nib instantiateWithOwner:self options:nil];
	_loadedView = (UIView *)[objects firstObject];
	self.frame = _loadedView.frame;
	[self addSubview:_loadedView];
}

- (IBAction)tabClick:(id)sender
{
	if (_tabDelegate && [sender isKindOfClass:[TabButton class]])
	{
		[_tabDelegate tabSelectionView:self didSelectTab:[(TabButton *)sender tabName]];
	}
}

@end
