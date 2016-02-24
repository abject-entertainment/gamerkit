//
//  ContentCell.h
//  gamerkit
//
//  Created by Benjamin Taggart on 11/7/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LNERadialMenu/LNERadialMenu.h>

@class ContentCell;

@protocol ContentCellDelegate <NSObject>

-(id)contentObjectForCell:(ContentCell*)cell;

@optional
-(BOOL)contentCellCanPerformActivites:(ContentCell*)cell;
-(BOOL)contentCellCanBeDeleted:(ContentCell*)cell;
-(BOOL)contentCellCanBeDuplicated:(ContentCell*)cell;

-(void)performActivitesForContentOfCell:(ContentCell*)cell;
-(void)deleteContentOfCell:(ContentCell*)cell;
-(void)duplicateContentOfCell:(ContentCell*)cell;

-(UIView*)viewForContextMenuForCell:(ContentCell*)cell;

@end


@interface ContentCell : UICollectionViewCell<LNERadialMenuDataSource, LNERadialMenuDelegate>

@property (nonatomic, strong) id<ContentCellDelegate> delegate;
@property (nonatomic, strong) id _contentObject;

-(id)getContentObject;
-(void)showContextMenuAtPoint:(CGPoint)point;

@end
