//
//  PageViewController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 5/30/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()
{
	NSArray *_titleBarItems;
}

@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	if (_titleBar)
	{ _titleBarItems = [NSArray arrayWithArray:_titleBar.items]; }
	
	if (_content)
	{ _content.delegate = self; }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onMenuButton:(id)sender {
	if (_delegate)
	{ [_delegate menuButtonTappedOnPageViewController:self]; }
}

- (IBAction)onClose:(id)sender {
	if (_delegate)
	{ [_delegate closeRequestedByPageViewController:self]; }
}

- (void)addToTitleBar:(UIBarItem*)item {
	[_titleBar setItems:[[NSArray arrayWithObject:item] arrayByAddingObjectsFromArray:_titleBarItems] animated: YES];
}

- (void)resetTitleBar {
	[_titleBar setItems:_titleBarItems animated:YES];
}

@end
