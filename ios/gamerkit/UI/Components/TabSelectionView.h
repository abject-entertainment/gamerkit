//
//  TabSelectionView.h
//  gamerkit
//
//  Created by Benjamin Taggart on 10/12/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabButton.h"

@class TabSelectionView;

@protocol TabSelectionViewDelegate <NSObject>

- (void)tabSelectionView: (TabSelectionView*)view didSelectTab: (NSString*)tab;

@end

IB_DESIGNABLE
@interface TabSelectionView : UIScrollView

@property (nonatomic, strong) IBOutlet NSObject<TabSelectionViewDelegate>* tabDelegate;

- (IBAction)tabClick:(id)sender;

@end
