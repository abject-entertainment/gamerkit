//
//  ContentCell.h
//  gamerkit
//
//  Created by Benjamin Taggart on 11/7/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentCell;

@protocol ContentCellDelegate <NSObject>

-(id)getContentObjectForCell:(ContentCell*)cell;

@end


@interface ContentCell : UICollectionViewCell

@property (nonatomic, weak) id<ContentCellDelegate> delegate;
@property (weak) id _contentObject;

-(id)getContentObject;

@end
