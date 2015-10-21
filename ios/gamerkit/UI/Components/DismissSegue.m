//
//  DismissSegue.m
//  gamerkit
//
//  Created by Benjamin Taggart on 10/20/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform {
	UIViewController *sourceViewController = self.sourceViewController;
	[sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
