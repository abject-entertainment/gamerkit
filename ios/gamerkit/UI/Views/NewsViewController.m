//
//  NewsViewController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 5/27/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "NewsViewController.h"
#import "ContentManager.h"

@interface NewsViewController ()

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.content)
	{
		[self goHome:self];
	}
}

- (IBAction)goHome:(id)sender
{
	NSString *newsPage = @"Core/start.html";
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsPath = [paths objectAtIndex:0];
	
	NSString *startPage = [docsPath stringByAppendingPathComponent:newsPage];
	[self.content loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:startPage]]];
}

- (IBAction)goToFeedback:(id)sender
{
	NSString *feedbackPage = @"Core/feedback.html";
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsPath = [paths objectAtIndex:0];
	
	NSString *startPage = [docsPath stringByAppendingPathComponent:feedbackPage];
	[self.content loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:startPage]]];
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

@end
