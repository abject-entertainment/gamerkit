//
//  MapDetailController.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 9/5/11.
//  Copyright 2011 Abject Entertainment. All rights reserved.
//

#import "MapDetailController.h"
#import "GriddedView.h"

extern BOOL bPad;

@implementation MapDetailController
@synthesize grid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return bPad ||
		(interfaceOrientation == UIInterfaceOrientationPortrait) ||
		(interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if (grid)
	{
		[grid setNeedsDisplay];
	}
}

@end
