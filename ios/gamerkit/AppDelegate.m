//
//  AppDelegate.m
//  gamerkit
//
//  Created by Benjamin Taggart on 4/22/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "AppDelegate.h"
#import "DataManager.h"

BOOL bPad = NO;
NSString *packageString = nil;
NSString *feedbackStats = nil;

AppDelegate *s_delegate = nil;

@interface AppDelegate () <UISplitViewControllerDelegate>
{
	UISplitViewController *_splitVC;
}

@end

@implementation AppDelegate

+ (UISplitViewController*)splitView
{
	return s_delegate->_splitVC;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	s_delegate = self;
	
	DataManager *dataManager = [DataManager getDataManager];
	[dataManager checkForFirstRunSetup];
	[dataManager loadData];
	
	bPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
	
	
	NSString *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
	packageString = [NSString stringWithFormat:@"__toolkit_package_list.php?v=%@&d=%@", versionStr,
					  [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
	
	UIDevice *dev = [UIDevice currentDevice];
	feedbackStats = [NSString stringWithFormat:@"GTv%@-%@-%@", versionStr, dev.model, dev.systemVersion];
	
	// Override point for customization after application launch.
	_splitVC = (UISplitViewController *)self.window.rootViewController;

	_splitVC.delegate = self;
	_splitVC.presentsWithGesture = NO;
	
	if (dev.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
	{
		_splitVC.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
		//[_splitVC showDetailViewController:[_splitVC.viewControllers lastObject] sender:self];
	}
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
	UIDevice *dev = [UIDevice currentDevice];
	if (dev.userInterfaceIdiom == UIUserInterfaceIdiomPad &&
		UIDeviceOrientationIsLandscape(dev.orientation))
	{
		_splitVC.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
	}
	else
	{
		_splitVC.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
	}
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
	return NO;
}

@end
