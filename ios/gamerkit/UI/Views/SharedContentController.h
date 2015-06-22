//
//  SharedContentController.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 8/4/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConnectionManager;
@class SharedContentDataStore;
@class SharedContentController;

@protocol SharedContentDoneDelegate

- (void)sharedContentDone:(SharedContentController*)controller;

@end


@interface SharedContentController : UIViewController <UIPopoverControllerDelegate> {
	UITableView *contentTable;
	SharedContentDataStore *contentStore;
	ConnectionManager *connMgr;
	NSObject<SharedContentDoneDelegate> *delegate;
	UIPopoverController *popover;
}

@property (readonly, retain) IBOutlet UITableView *contentTable;

- (void)displaySharedContentForClass:(Class)c delegate:(NSObject<SharedContentDoneDelegate>*)dlgt;
- (IBAction)done;

- (void)showAsPopoverFromButton:(UIBarButtonItem*)btn;

@end
