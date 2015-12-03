//
//  ShowDetailSegue.m
//  gamerkit
//
//  Created by Benjamin Taggart on 11/6/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import "ContentDetailSegue.h"
#import "ContentListViewController.h"

@implementation ContentDetailSegue

-(void)perform
{
	ContentListViewController *list = nil;
	if ([self.sourceViewController isKindOfClass:ContentListViewController.class])
	{ list = (ContentListViewController*)self.sourceViewController; }
	
	[self.sourceViewController presentViewController:self.destinationViewController animated:YES completion:nil];
}

@end
