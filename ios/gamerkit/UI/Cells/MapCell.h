//
//  MapCell.h
//  gamerkit
//
//  Created by Benjamin Taggart on 4/22/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapCell : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UIImageView *image;
@property (nonatomic,weak) IBOutlet UILabel *name;

@end
