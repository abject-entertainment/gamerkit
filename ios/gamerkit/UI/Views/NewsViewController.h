//
//  NewsViewController.h
//  gamerkit
//
//  Created by Benjamin Taggart on 5/27/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *content;

- (IBAction)goHome:(id)sender;
- (IBAction)goToFeedback:(id)sender;

@end
