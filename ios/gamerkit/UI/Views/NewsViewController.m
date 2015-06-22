//
//  NewsViewController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 5/27/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "NewsViewController.h"
#import "DataManager.h"

@interface NewsViewController ()

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.content)
	{
		DataManager *dm = [DataManager getDataManager];
		
		NSString *startPage = [dm.docsPath stringByAppendingPathComponent:(@"Systems/start-ipad.html")];
		[self.content loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:startPage]]];
	}
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
