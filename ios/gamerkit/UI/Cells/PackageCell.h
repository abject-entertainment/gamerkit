//
//  PackageCell.h
//  gamerkit
//
//  Created by Benjamin Taggart on 10/26/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuyButton.h"

@class PackageCell;
@class PackageData;

@protocol PackageCellDelegate
-(void)packageCell:(PackageCell*)cell didRequestPurchaseOfPackage:(PackageData*)pdata;
@end

@interface PackageCell : UICollectionViewCell <BuyButtonDelegate>

@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UIButton *update;
@property (nonatomic, strong) IBOutlet UITextView *summary;
@property (nonatomic, strong) IBOutlet UIImageView *image;
@property (nonatomic, strong) IBOutlet BuyButton *price;

-(void)setupForPackage:(PackageData*)pdata withDelegate:(id<PackageCellDelegate>)delegate;

@end
