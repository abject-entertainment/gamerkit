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

@property (nonatomic, assign) IBOutlet UILabel *title;
@property (nonatomic, assign) IBOutlet UITextView *description;
@property (nonatomic, assign) IBOutlet UIToolbar *buttonBar;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *downloadButton;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *updateButton;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic, assign) IBOutlet UIView *downloadingOverlay;

@property (assign) NSInteger section;
@property (assign) NSInteger row;

- (void)setButtonsInstalled:(BOOL)installed updatable:(BOOL)updatable;

@end
