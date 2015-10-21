//
//  MasterViewController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 4/22/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()
{
}
@end

@implementation MasterViewController

- (void)awakeFromNib {
	[super awakeFromNib];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tabBar.barTintColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Segues
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if (segue.destinationViewController && segue.destinationViewController.view)
	{
		if (_visibleVC)
		{
			[_visibleVC.view removeFromSuperview];
			[_visibleVC removeFromParentViewController];
		}
		
		[self addChildViewController: segue.destinationViewController];
		UIView *view = segue.destinationViewController.view;
		view.frame = self.view.frame;
		[self.view insertSubview:view atIndex:0];
	}
}


- (void)tabSelectionView: (TabSelectionView*)view didSelectTab:(NSString *)tab
{
	@try {
		[self performSegueWithIdentifier:tab sender:self];
	}
	@catch (NSException *exception) {
		// no segue with that tab name.  IMPLEMENT IT.
		NSLog(@"Implement segue id \"%@\" on main menu!!", tab);
		NSLog(@"Exception: %@", exception.debugDescription);
	}
	@finally {
	}
}
*/
@end
