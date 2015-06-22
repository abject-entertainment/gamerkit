//
//  TokenListController.h
//  gamerkit
//
//  Created by Benjamin Taggart on 6/10/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Token;

@interface TokenListController : UICollectionViewController

- (void)addToken:(Token *)token;

@end
