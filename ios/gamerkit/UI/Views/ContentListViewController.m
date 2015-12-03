//
//  ContentListViewController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 11/6/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import "ContentListViewController.h"
#import "ContentDetailSegue.h"
#import "NewContentSegue.h"
#import "ContentDetailViewController.h"
#import "ContentCell.h"

@implementation ContentListViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue isKindOfClass:ContentDetailSegue.class])
	{
		if ([segue.destinationViewController isKindOfClass:ContentDetailViewController.class] &&
			[sender isKindOfClass:ContentCell.class])
		{
			ContentDetailViewController *detail = (ContentDetailViewController*)segue.destinationViewController;
			ContentCell *cell = (ContentCell*)sender;
			
			[detail setContentObject:[cell getContentObject]];
		}
	}
	else if ([segue isKindOfClass:NewContentSegue.class])
	{
		if ([segue.destinationViewController isKindOfClass:ContentDetailViewController.class])
		{
			ContentDetailViewController *detail = (ContentDetailViewController*)segue.destinationViewController;
			
			[detail setContentObject:[self createNewContentObject]];
		}
	}
}

-(id)getContentObjectForCell:(ContentCell *)cell
{
	return cell._contentObject;
}

-(id)createNewContentObject
{
	NSLog(@"IMPLEMENT createNewContentObject ON THIS LIST");
	return nil;
}

@end
