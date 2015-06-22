//
//  PageViewController.h
//  gamerkit
//
//  Created by Benjamin Taggart on 5/30/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageViewController;

@protocol PageViewControllerDelegate

- (void)menuButtonTappedOnPageViewController:(PageViewController *)controller;
- (void)closeRequestedByPageViewController:(PageViewController *)controller;

@end

@interface PageViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet id<PageViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIWebView* content;
@property (nonatomic, strong) IBOutlet UIToolbar* titleBar;

- (IBAction)onMenuButton:(id)sender;
- (IBAction)onClose:(id)sender;

- (void)addToTitleBar:(UIBarItem*)item;
- (void)resetTitleBar;

@end
