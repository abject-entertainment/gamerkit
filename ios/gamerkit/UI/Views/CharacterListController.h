//
//  CharacterDataStore.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 2/13/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalPicker.h"
#import "MessageUI/MFMailComposeViewController.h"
#import "TokenEditController.h"
#import "ContentListViewController.h"

@class Character;
@class Import;

typedef enum _CharacterPickTarget {
	CP_None,
	CP_New,
	CP_ImportSource,
	CP_View,
	
	CP_MAX
} CharacterPickTarget;

@interface CharacterListController : ContentListViewController <UICollectionViewDelegate, UICollectionViewDataSource>
- (void)refreshData;

@end
