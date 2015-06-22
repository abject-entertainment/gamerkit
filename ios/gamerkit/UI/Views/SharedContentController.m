    //
//  SharedContentController.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 8/4/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "SharedContentController.h"

#import "ConnectionManager.h"
#import "SharedContentDataStore.h"

@implementation SharedContentController

@synthesize contentTable;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)displaySharedContentForClass:(Class)c delegate:(NSObject<SharedContentDoneDelegate>*)dlgt
{
	if (connMgr == nil)
	{
		if (contentStore == nil)
		{
			if ([contentTable.delegate isKindOfClass:[SharedContentDataStore class]])
			{
				contentStore = (SharedContentDataStore*)contentTable.delegate;
			}
		}
		
		if (contentStore)
		{
			connMgr = contentStore.connectionMgr;
		}
	}
	
	if (connMgr && contentStore)
	{
		[connMgr lookForSharedContent:contentStore forClass: c];
		delegate = dlgt;
	}
}

- (IBAction)done
{
	if (delegate)
	{
		[delegate sharedContentDone:self];
		delegate = nil;
		
		if (popover)
			[popover dismissPopoverAnimated:YES];
	}
}

- (void)showAsPopoverFromButton:(UIBarButtonItem*)btn
{
	if (popover == nil)
	{
		CGSize sz = self.view.frame.size;
		popover = [[UIPopoverController alloc] initWithContentViewController:self];
		popover.popoverContentSize = sz;
	}
	
	[popover presentPopoverFromBarButtonItem:btn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	if (popoverController == popover)
	{
		[self done];
	}
}

@end
