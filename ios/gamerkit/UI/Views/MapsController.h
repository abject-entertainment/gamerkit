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
<UIImagePickerControllerDelegate, UINavigationControllerDelegate,
ModalPickerDelegate, SharedContentDoneDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
	NSMutableArray *maps;
	Map *currentMap;
	NSObject<MapSelectionDelegate> *_selectionDelegate;

	UIPopoverController *popover;
	UIViewController *cachedVC;
	id<UITabBarControllerDelegate> cachedDel;
	UIBarButtonItem *cachedButton;
}

@property (nonatomic, readonly) IBOutlet UITableView *mapList;

@property (nonatomic, readonly) IBOutlet UIViewController *mapDetail;
@property (nonatomic, readonly) IBOutlet GriddedView *mapGrid;
@property (nonatomic, readonly) IBOutlet UITextField *mapName;
@property (nonatomic, readonly) IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic, readonly) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, readonly) IBOutlet UIImagePickerController *photoLibrary;

@property (nonatomic, readonly) NSObject<MapSelectionDelegate> *selectionDelegate;
@property (nonatomic, assign) id doneTarget;
@property (nonatomic) SEL doneAction;

- (IBAction)done:(id)sender;
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
