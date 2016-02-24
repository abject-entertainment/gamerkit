//
//  ContentListViewController.h
//  gamerkit
//
//  Created by Benjamin Taggart on 11/6/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentCell.h"

@interface ContentListViewController : UICollectionViewController <ContentCellDelegate, UIGestureRecognizerDelegate>

-(id)contentObjectForCell:(ContentCell *)cell;
-(void)deleteContentForCell:(ContentCell *)cell;

@end
