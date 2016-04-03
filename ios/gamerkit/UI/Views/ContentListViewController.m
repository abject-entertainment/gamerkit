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
#import "ContentObject.h"

@implementation ContentListViewController

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	lpgr.delegate = self;
	[self.collectionView addGestureRecognizer:lpgr];
}

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

- (IBAction)handleLongPress:(UILongPressGestureRecognizer*)gestureRecognizer
{
	switch (gestureRecognizer.state)
	{
		case UIGestureRecognizerStateBegan:
		{
			NSLog(@"LONG PRESS!!");
			CGPoint p = [gestureRecognizer locationInView:self.collectionView];
			NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
			if (indexPath)
			{
				UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
				if ([cell isKindOfClass:ContentCell.class])
				{
					((ContentCell *)cell).delegate = self;
					p = [gestureRecognizer locationInView:self.collectionView.window];
					[(ContentCell *)cell showContextMenuAtPoint:p];
				}
			}
		}
			break;
		case UIGestureRecognizerStateCancelled:
			NSLog(@"cancel");
			break;
		case UIGestureRecognizerStateChanged:
			NSLog(@"change");
			break;
		case UIGestureRecognizerStateRecognized:
			NSLog(@"recognized/ended");
			break;
		case UIGestureRecognizerStateFailed:
			NSLog(@"failed");
			break;
		case UIGestureRecognizerStatePossible:
			NSLog(@"possible");
			break;
	}
}

-(id)contentObjectForCell:(ContentCell *)cell
{
	return cell._contentObject;
}

-(void)performActivitesForContentOfCell:(ContentCell *)cell
{
	id content = [cell getContentObject];
	if ([content isKindOfClass:ContentObject.class])
	{
		[(ContentObject *)content shareFromViewController:self];
	}
}

-(void)deleteContentOfCell:(ContentCell *)cell
{
	[self deleteContentForCell:cell];
}

-(id)createNewContentObject
{
	NSLog(@"IMPLEMENT createNewContentObject ON THIS LIST");
	return nil;
}

-(void)deleteContentForCell:(ContentCell *)cell
{
	NSLog(@"IMPLEMENT deletContentObject:(id)contentObject; ON THIS LIST");
}

@end
