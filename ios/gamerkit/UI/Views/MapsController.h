//
//  MapsController.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/31/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Map.h"
#import "SharedContentController.h"
#import "ModalPicker.h"

@protocol MapSelectionDelegate

- (void)mapSelected:(Map*)map;

@end

@class GriddedView;

@interface MapsController : UICollectionViewController
<UIImagePickerControllerDelegate,
ModalPickerDelegate, SharedContentDoneDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
	NSMutableArray *maps;
	Map *currentMap;

	UIPopoverController *popover;
	UIViewController *cachedVC;
	id<UITabBarControllerDelegate> cachedDel;
	UIBarButtonItem *cachedButton;
}

@property (nonatomic) IBOutlet UITableView *mapList;

@property (nonatomic) IBOutlet UIViewController *mapDetail;
@property (nonatomic) IBOutlet GriddedView *mapGrid;
@property (nonatomic) IBOutlet UITextField *mapName;
@property (nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic) IBOutlet UIImagePickerController *photoLibrary;

- (IBAction)newMap:(id)sender;
- (IBAction)detailDone;
- (IBAction)pickImage:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)toggleEditGrid:(id)sender;

- (void)addMap:(Map*)map;

- (BOOL)modalPicker:(ModalPicker*)picker donePicking:(NSArray*)results;
- (void)modalPicker:(ModalPicker*)picker selectionChanged:(NSInteger) newIndex forColumn:(NSInteger)column;

- (void)sharedContentDone:(SharedContentController*)controller;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end
