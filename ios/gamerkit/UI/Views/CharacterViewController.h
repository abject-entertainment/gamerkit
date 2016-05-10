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
#import "ContentObject.h"

@class Character;

@interface CharacterViewController : ContentDetailViewController <TokenSelectionDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView* content;

@property (nonatomic, weak) CharacterListController* listController;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *toggleButton;

- (IBAction)toggleEdit:(id)sender;
- (IBAction)characterActions:(id)sender;

- (void)displayCharacter:(Character *)character withAction:(ContentObjectAction)action;

@end
