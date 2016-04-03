//
//  CharacterViewController.h
//  gamerkit
//
//  Created by Benjamin Taggart on 5/27/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "CharacterListController.h"
#import "TokenListController.h"
#import "ContentDetailViewController.h"
#import "ContentJSContext.h"

@class Character;

@interface CharacterViewController : ContentDetailViewController <TokenSelectionDelegate, TokenRequestDelegate>

@property (nonatomic, strong) IBOutlet WKWebView* content;

@property (nonatomic, weak) CharacterListController* listController;

- (IBAction)roll:(id)sender;

@end
