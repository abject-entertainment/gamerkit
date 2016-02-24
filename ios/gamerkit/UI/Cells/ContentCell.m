//
//  ContentCell.m
//  gamerkit
//
//  Created by Benjamin Taggart on 11/7/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import "ContentCell.h"
#import "RadialMenuButton.h"

@interface ContentCell()
{
	LNERadialMenu *_menu;
	NSUInteger _actions;
	NSUInteger _actionCount;
}
@end

typedef enum : NSUInteger {
	Activities,
	Delete,
	Duplicate,
	
	MaxActions
} MenuActions;

static dispatch_once_t imageNamesInitialized;
static NSArray *ImageNames = nil;

@implementation ContentCell

-(id)getContentObject
{
	if (self.delegate)
	{ return [self.delegate contentObjectForCell:self]; }
	
	return self._contentObject;
}

- (void) showContextMenuAtPoint:(CGPoint)point
{
	_actions = 0;
	_actionCount = 0;
	
	if (self.delegate)
	{
		// activity defaults on
		if (![self.delegate respondsToSelector:@selector(contentCellCanPerformActivites:)] ||
			[self.delegate contentCellCanPerformActivites:self])
		{ _actions |= (1 << Activities); ++_actionCount; }
		
		// delete defaults on
		if (![self.delegate respondsToSelector:@selector(contentCellCanBeDeleted:)] ||
			[self.delegate contentCellCanBeDeleted:self])
		{ _actions |= (1 << Delete); ++_actionCount; }
		
		// duplicate defaults off
		if ([self.delegate respondsToSelector:@selector(contentCellCanBeDuplicated:)] &&
			[self.delegate contentCellCanBeDuplicated:self])
		{ _actions |= (1 << Duplicate); ++_actionCount; }
	}
	
	_menu = [[LNERadialMenu alloc] initFromPoint:point withDataSource:self andDelegate:self];
	
	[_menu showMenu];
}

- (UIButton*)radialMenu:(LNERadialMenu *)radialMenu elementAtIndex:(NSInteger)index
{
	dispatch_once(&imageNamesInitialized, ^{
		ImageNames = @[@"activites", @"delete", @"duplicate"];
	});
	
	for (NSUInteger i = 0; i < MaxActions; ++i)
	{
		if (_actions | (1 << i))
		{
			if (index == 0)
			{
				// this one
				RadialMenuButton *btn = [RadialMenuButton buttonWithTitle:ImageNames[i]];
				btn.tag = i;
				return btn;
			}
			--index;
		}
	}
	return nil;
}

- (NSInteger)numberOfButtonsForRadialMenu:(LNERadialMenu *)radialMenu
{
	return _actionCount;
}

- (CGFloat)radiusLenghtForRadialMenu:(LNERadialMenu *)radialMenu
{
	return 50.0f;
}

- (void)radialMenu:(LNERadialMenu *)radialMenu didSelectButton:(UIButton *)button
{
	if (self.delegate)
	{
		switch (button.tag) {
			case Activities:
				[self.delegate performActivitesForContentOfCell:self];
				break;
			case Delete:
				[self.delegate deleteContentOfCell:self];
				break;
			case Duplicate:
				[self.delegate duplicateContentOfCell:self];
				break;
		}
	}
	[_menu closeMenu];
}

- (UIView *)viewForCenterOfRadialMenu:(LNERadialMenu *)radialMenu
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(viewForContextMenuForCell:)])
	{
		return [self.delegate viewForContextMenuForCell:self];
	}
	return nil;
}

@end
