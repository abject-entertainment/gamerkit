//
//  TokenController.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/23/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalPicker.h"
#import "SharedContentController.h"
#import "TokenListController.h"

@class Token;

@interface TokenEditController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) id<TokenSelectionDelegate> selectionDelegate;

- (IBAction)openPhotoLibrary;

- (IBAction)flipHorizontal;
- (IBAction)flipVertical;
- (IBAction)rotate90CW;

- (IBAction)save;
- (IBAction)revert;

- (void)setToken:(Token*)token;

@end
