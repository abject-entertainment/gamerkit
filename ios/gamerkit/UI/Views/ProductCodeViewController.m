//
//  ProductCodeViewController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 2/22/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "ProductCodeViewController.h"
#import "PackageManager.h"

@interface ProductCodeViewController ()

@property (nonatomic, weak) IBOutlet UITextField *codeEntryField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UITextView *messageView;

@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@property (nonatomic, weak) IBOutlet UIButton *listButton;
@property (nonatomic, weak) IBOutlet UIButton *submitButton;


- (IBAction)submitCode:(id)sender;

@end

@implementation ProductCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitCode:(id)sender
{
	[self.spinner startAnimating];
	self.messageView.text = @"";
	self.doneButton.enabled = NO;
	self.listButton.enabled = NO;
	self.submitButton.enabled = NO;
	self.codeEntryField.enabled = NO;
	
	NSString *code = self.codeEntryField.text;
	
	// submit code
	[[PackageManager packageManager] submitProductCode:code withCallback:^(NSString *message) {
		[self.spinner stopAnimating];
		self.doneButton.enabled = YES;
		self.listButton.enabled = YES;
		self.submitButton.enabled = YES;
		self.codeEntryField.enabled = YES;
		
		self.messageView.text = message;
	}];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.codeEntryField)
	{
		[self submitCode:textField];
		return YES;
	}
	return NO;
}

@end
