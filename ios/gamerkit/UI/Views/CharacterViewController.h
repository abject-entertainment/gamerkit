//
//  CharacterViewController.h
//  gamerkit
//
//  Created by Benjamin Taggart on 5/27/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharacterListController.h"
#import "TokenListController.h"
#import "ContentDetailViewController.h"

@class Character;

@interface CharacterViewController : ContentDetailViewController <TokenSelectionDelegate, UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView* content;
@property (nonatomic, weak) IBOutlet UIBarItem* titleText;

@property (nonatomic, weak) CharacterListController* listController;

- (IBAction)roll:(id)sender;

@end
