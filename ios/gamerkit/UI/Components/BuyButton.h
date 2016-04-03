//
//  BuyButton.h
//  gamerkit
//
//  Created by Benjamin Taggart on 11/20/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BuyButton;
@class PackageData;

@protocol BuyButtonDelegate

- (void)buyButtonWasConfirmed:(BuyButton*)button;

@optional
- (void)buyButtonWasActivated:(BuyButton*)button;

@end

@interface BuyButton : UIButton

@property (nonatomic, weak) PackageData *product;
@property (nonatomic, weak) IBOutlet NSObject<BuyButtonDelegate> *delegate;

- (void)deactivate;

@end
