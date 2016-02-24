//
//  ProductDetailView.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 7/14/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProductDetailView : UIView {
	NSInteger section;
	NSInteger row;
	
	NSMutableArray *installedButtons;
	NSMutableArray *updatableButtons;
	NSMutableArray *availableButtons;
}

@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UITextView *description;
@property (nonatomic, strong) IBOutlet UIToolbar *buttonBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *downloadButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *updateButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic, strong) IBOutlet UIView *downloadingOverlay;

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger row;

- (void)setButtonsInstalled:(BOOL)installed updatable:(BOOL)updatable;

@end
