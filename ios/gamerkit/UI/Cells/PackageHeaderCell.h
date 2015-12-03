//
//  PackageHeaderCell.h
//  gamerkit
//
//  Created by Benjamin Taggart on 11/9/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageHeaderCell : UICollectionReusableView
@property (nonatomic, strong) IBOutlet UILabel *count;
@property (nonatomic, strong) IBOutlet UILabel *label;
@end
