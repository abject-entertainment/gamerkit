//
//  TokenListController.h
//  gamerkit
//
//  Created by Benjamin Taggart on 6/10/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Token;

@protocol TokenSelectionDelegate
- (void)tokenWasSelected:(Token*)token;
@optional
- (void)tokenSelectionWasCancelled;
@end


@interface TokenListController : UICollectionViewController

+ (void)selectTokenForDelegate:(UIViewController<TokenSelectionDelegate>*)tokenSelectionDelegate;
- (void)addToken:(Token *)token;

@end
