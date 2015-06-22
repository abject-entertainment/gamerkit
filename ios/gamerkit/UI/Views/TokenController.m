//
//  TokenController.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/23/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "TokenController.h"
#import "Token.h"
#import "DataManager.h"
#import "TokenListController.h"

@interface TokenController()
{
	Token *_token;
}
@end

@implementation TokenController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (_token)
	{
		_imageView.image = _token.image;
		_tokenName.text = _token.name;
	}
}

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

- (void)setToken:(Token *)token
{
	_token = token;
	[_token fullyLoad];
	if (_imageView)
	{
		_imageView.image = _token.image;
		_tokenName.text = _token.name;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (IBAction)openPhotoLibrary
{/*
	if (photoLibrary == nil)
	{
		photoLibrary = [[UIImagePickerController alloc] init];
		photoLibrary.delegate = self;
	}
	
	if (photoLibrary)
	{
		photoLibrary.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		if (bPad)
		{
			if (popover == nil)
			{
				popover = [[UIPopoverController alloc] initWithContentViewController:photoLibrary];
			}
			else
			{
				[popover setContentViewController:photoLibrary];
			}
			
			if ([popover isPopoverVisible] == NO)
			{
				[popover presentPopoverFromRect:imageView.frame inView:tokenDetail.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			}
		}
		else if (tokenDetail)
		{
			[tokenDetail presentViewController:photoLibrary animated:YES completion:nil];
		}
	} */
}

/*
- (IBAction)detailDone
{
	if (currentToken == nil)
		currentToken = [[Token alloc] initWithImage:imageView.image andName:tokenName.text];
	else
	{
		if (currentToken.image != imageView.image)
		{
			currentToken.image = imageView.image;
		}
		currentToken.name = tokenName.text;
	}
	
	[currentToken writeToFile];
	
	if (![currentToken isShared])
	{
		[currentToken unload];
	}
	
	if (![tokens containsObject:currentToken])
		[tokens addObject:currentToken];
	
	currentToken = nil;
	
	if (tokenList)
		[tokenList reloadData];
	
	self.imageView.image = nil;
	self.tokenName.text = @"New Token";
	
//	if (popover)
//	{
//		[popover dismissPopoverAnimated:YES];
//	}
	if (bPad)
	{
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView beginAnimations:@"hideTokenDetail" context:nil];
		tokenDetail.view.alpha = 0.0f;
		[UIView commitAnimations];
	}
	else if (self.presentedViewController)
	{
		[self dismissViewControllerAnimated:YES completion:nil];
	}
} */

const float tokenSize = 128.0f;
/* - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	if ([[info objectForKey: UIImagePickerControllerMediaType] caseInsensitiveCompare:(NSString*)kUTTypeImage] == NSOrderedSame)
	{
		UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
		if (img == nil)
		{ img = [info objectForKey:UIImagePickerControllerOriginalImage]; }
		if (img && imageView)
		{
			UIGraphicsBeginImageContext(CGSizeMake(tokenSize, tokenSize));
			[img drawInRect:CGRectMake(0,0,tokenSize,tokenSize)];
			img = UIGraphicsGetImageFromCurrentImageContext();
			imageView.image = img;
			UIGraphicsEndImageContext();
		}
	}
	if (popover)
	{
//		CGSize sz = tokenDetail.view.frame.size;
//		[popover setContentViewController:tokenDetail];
//		popover.popoverContentSize = sz;
		[popover dismissPopoverAnimated:YES];
	}
	else
	{
		[tokenDetail dismissViewControllerAnimated:YES completion:nil];
	}
} */

- (IBAction)flipHorizontal
{
	if (_imageView)
	{
		UIImage *img = _imageView.image;
		UIGraphicsBeginImageContext(CGSizeMake(tokenSize, tokenSize));
		CGContextTranslateCTM(UIGraphicsGetCurrentContext(), tokenSize, 0.0f);
		CGContextScaleCTM(UIGraphicsGetCurrentContext(), -1.0f, 1.0f);
		[img drawInRect:CGRectMake(0,0,tokenSize,tokenSize)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		_imageView.image = img;
		UIGraphicsEndImageContext();
	}
}

- (IBAction)flipVertical
{
	if (_imageView)
	{
		UIImage *img = _imageView.image;
		UIGraphicsBeginImageContext(CGSizeMake(tokenSize, tokenSize));
		CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0f, tokenSize);
		CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0f, -1.0f);
		[img drawInRect:CGRectMake(0,0,tokenSize,tokenSize)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		_imageView.image = img;
		UIGraphicsEndImageContext();
	}
}

- (IBAction)rotate90CW
{
	if (_imageView)
	{
		UIImage *img = _imageView.image;
		UIGraphicsBeginImageContext(CGSizeMake(tokenSize, tokenSize));
		CGContextTranslateCTM(UIGraphicsGetCurrentContext(), tokenSize/2.0f, tokenSize/2.0f);
		CGContextRotateCTM(UIGraphicsGetCurrentContext(), 1.570796326794897f);
		CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -tokenSize/2.0f, -tokenSize/2.0f);
		[img drawInRect:CGRectMake(0,0,tokenSize,tokenSize)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		_imageView.image = img;
		UIGraphicsEndImageContext();
	}
}

- (IBAction)save
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Save" message:@"Save all changes? This cannot be undone." preferredStyle:UIAlertControllerStyleAlert];
	
	[alert addAction:[UIAlertAction actionWithTitle:@"Yes, Save" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		_token.name = _tokenName.text;
		_token.image = _imageView.image;
		[_token writeToFile];
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"No, Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}]];
	
	[self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)revert
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Revert" message:@"Revert to last saved version? This cannot be undone." preferredStyle:UIAlertControllerStyleAlert];
	
	[alert addAction:[UIAlertAction actionWithTitle:@"Yes, Revert" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		_tokenName.text = _token.name;
		_imageView.image = _token.image;
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"No, Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}]];
	
	[self presentViewController:alert animated:YES completion:nil];
}

@end
