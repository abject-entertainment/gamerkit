//
//  ProductDetailView.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 7/14/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "ProductDetailView.h"


@implementation ProductDetailView
@synthesize title, description;
@synthesize buttonBar, cancelButton, downloadButton, updateButton, deleteButton;
@synthesize section, row;
@synthesize downloadingOverlay;


- (id)initWithCoder:(NSCoder*)coder {
    if ((self = [super initWithCoder:coder])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setButtonsInstalled:(BOOL)installed updatable:(BOOL)updatable
{
	if (buttonBar)
	{
		if (updatableButtons == nil)
		{
			updatableButtons = [NSMutableArray arrayWithCapacity:3];
			[updatableButtons addObject:cancelButton];
			[updatableButtons addObject:updateButton];
			[updatableButtons addObject:deleteButton];
		}
		if (installedButtons == nil)
		{
			installedButtons = [NSMutableArray arrayWithCapacity:2];
			[installedButtons addObject:cancelButton];
			[installedButtons addObject:deleteButton];
		}
		if (availableButtons == nil)
		{
			availableButtons = [NSMutableArray arrayWithCapacity:2];
			[availableButtons addObject:cancelButton];
			[availableButtons addObject:downloadButton];
		}
		if (installed)
		{
			if (updatable)
			{
				[buttonBar setItems:updatableButtons animated:NO];
			}
			else
			{
				[buttonBar setItems:installedButtons animated:NO];
			}

		}
		else 
		{
			[buttonBar setItems:availableButtons animated:NO];
		}

	}
}
@end
