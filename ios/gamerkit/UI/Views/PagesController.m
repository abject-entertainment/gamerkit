//
//  PageController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 5/20/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "PagesController.h"
#import "CharacterViewController.h"
#import "Character.h"
#import "AppDelegate.h"

PagesController *s_pages = nil;

@interface PagesController ()
{
	PageViewController *_newsPage;
	NSMutableArray *_otherPages;
}

@end

@implementation PagesController

+ (PagesController *)getPages {
	return s_pages;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	s_pages = self;
	
	self.delegate = self;
	self.dataSource = self;
	
	_newsPage = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsView"];
	_newsPage.delegate = self;
	
	_otherPages = [NSMutableArray arrayWithCapacity:4];
	[self makeCurrentViewController:_newsPage];
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

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
	return _otherPages.count + 1;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
	PageViewController *vc = [[pageViewController viewControllers] firstObject];
	NSInteger i = [_otherPages indexOfObject:vc];
	if (i == NSNotFound)
	{ return 0; }
	else
	{ return i + 1; }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	  viewControllerBeforeViewController:(UIViewController *)viewController {
	NSInteger i = [_otherPages indexOfObject:viewController];
	if (i == NSNotFound)
	{ return nil; }
	else if (i == 0)
	{ return _newsPage; }
	else
	{ return [_otherPages objectAtIndex:i-1]; }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	   viewControllerAfterViewController:(UIViewController *)viewController {
	NSInteger i = [_otherPages indexOfObject:viewController];
	if (i == NSNotFound)
	{ return (_otherPages.count > 0)?[_otherPages firstObject]:nil; }
	else if (i == (_otherPages.count-1))
	{ return nil; }
	else
	{ return [_otherPages objectAtIndex:i+1]; }
}

- (void)makeCurrentViewController:(PageViewController *)vc {
	PageViewController *from = [[self viewControllers] firstObject];
	
	if (from == vc)
	{ return; }
	
	UIPageViewControllerNavigationDirection dir = UIPageViewControllerNavigationDirectionForward;
	
	if (from != _newsPage && (vc == _newsPage || [_otherPages indexOfObject:vc] < [_otherPages indexOfObject:from]))
	{ dir = UIPageViewControllerNavigationDirectionReverse; }
	
	BOOL anim = YES;
	
	if (vc == _newsPage && _otherPages.count == 0)
	{ anim = NO; }

	[self setViewControllers:@[vc] direction:dir animated:anim completion:nil];
}

- (void)addPageForCharacter:(Character*)character {
	for (int i = 0; i < _otherPages.count; ++i) {
		id vc = [_otherPages objectAtIndex:i];
		if ([vc isKindOfClass:CharacterViewController.class])
		{
			if (((CharacterViewController*)vc).character == character)
			{
				[self makeCurrentViewController:vc];
				return;
			}
		}
	}
	
	CharacterViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CharacterView"];
	if (cvc)
	{
		// initialize with character.
		[cvc setCharacter:character];
		
		[_otherPages addObject:cvc];
		
		/* / close menu window
		UISplitViewController *svc = [AppDelegate splitView];
		if (svc.displayMode != UISplitViewControllerDisplayModeAllVisible)
		{
			svc.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
		}
		else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		{
			[svc showDetailViewController:self sender:self];
		} */
	}
}

- (void)menuButtonTappedOnPageViewController:(PageViewController *)controller {
/*	UISplitViewController *svc = [AppDelegate splitView];
	if (svc.displayMode != UISplitViewControllerDisplayModeAllVisible)
	{
		svc.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
	}
	else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		[svc dismissViewControllerAnimated:YES completion:nil];
	} */
}

- (void)closeRequestedByPageViewController:(PageViewController *)controller {
	if (controller != _newsPage)
	{
		NSInteger i = [_otherPages indexOfObject:controller];
		if (i == NSNotFound)
		{ return; }
		
		PageViewController *newVC = (i > 0)?[_otherPages objectAtIndex:i-1]:_newsPage;
		[self makeCurrentViewController:newVC];
		
		[_otherPages removeObjectAtIndex:i];
	}
}

@end



