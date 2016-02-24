//
//  MapsController.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/31/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Map.h"
#import "ModalPicker.h"

@protocol MapSelectionDelegate

- (void)mapSelected:(Map*)map;

@end

@class GriddedView;

@interface MapsController : UICollectionViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate,
ModalPickerDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
	NSMutableArray *maps;
	Map *currentMap;

	UIPopoverController *popover;
	UIViewController *cachedVC;
	id<UITabBarControllerDelegate> cachedDel;
	UIBarButtonItem *cachedButton;
}

@property (nonatomic, weak) IBOutlet UITableView *mapList;

@property (nonatomic, weak) IBOutlet UIViewController *mapDetail;
@property (nonatomic, weak) IBOutlet GriddedView *mapGrid;
@property (nonatomic, weak) IBOutlet UITextField *mapName;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)newMap:(id)sender;
- (IBAction)detailDone;
- (IBAction)pickImage:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)toggleEditGrid:(id)sender;

- (void)addMap:(Map*)map;

- (BOOL)modalPicker:(ModalPicker*)picker donePicking:(NSArray*)results;
- (void)modalPicker:(ModalPicker*)picker selectionChanged:(NSInteger) newIndex forColumn:(NSInteger)column;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end
