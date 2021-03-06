//
//  TokenController.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/23/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "TokenEditController.h"
#import "Token.h"
#import "ContentManager.h"
#import "DismissSegue.h"

@interface TokenEditController()
{
	Token *_token;
}
@end

@implementation TokenEditController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (_token)
	{
		_imageView.image = _token.image;
	}
}

- (void)setToken:(Token *)token
{
	_token = token;
	if (_imageView)
	{
		_imageView.image = _token.image;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (IBAction)openPhotoLibrary
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
		photoLibrary.modalPresentationStyle = UIModalPresentationCurrentContext;
		photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		photoLibrary.allowsEditing = true;
		photoLibrary.delegate = self;
		[self presentViewController:photoLibrary animated:YES completion:nil];
	}
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

const float tokenSize = 256.0f;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
	UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
	if (img == nil)
	{ img = [info objectForKey:UIImagePickerControllerOriginalImage]; }
	
	if (img && _imageView)
	{
		UIGraphicsBeginImageContext(CGSizeMake(tokenSize, tokenSize));
		[img drawInRect:CGRectMake(0,0,tokenSize,tokenSize)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		_imageView.image = img;
		UIGraphicsEndImageContext();
	}
	
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:nil];
}

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
	if (_token == nil)
	{
		_token = [[Token alloc] initWithImage:_imageView.image];
		if ([self.presentingViewController isKindOfClass:[TokenListController class]])
		{
			[(TokenListController*)self.presentingViewController addToken:_token];
		}
	}
	else
	{
		_token.image = _imageView.image;
	}
	[_token saveFile];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)revert
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Revert" message:@"Revert to last saved version? This cannot be undone." preferredStyle:UIAlertControllerStyleAlert];
	
	[alert addAction:[UIAlertAction actionWithTitle:@"Yes, Revert" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		_imageView.image = _token.image;
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"No, Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}]];
	
	[self presentViewController:alert animated:YES completion:nil];
}

@end
