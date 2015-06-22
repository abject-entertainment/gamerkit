//
//  SystemHeaderCell.h
//  gamerkit
//
//  Created by Benjamin Taggart on 5/30/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SystemHeaderCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel* systemName;

- (void)setSystem:(NSString*)name;

@end
