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

@class Character;

@interface CharacterViewController : UIViewController <TokenSelectionDelegate, UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView* content;
@property (nonatomic, strong) IBOutlet UIBarItem* titleText;

@property (nonatomic, weak) CharacterListController* listController;

@property (readonly) Character *character;
- (void)setCharacter:(Character*)character;

- (IBAction)roll:(id)sender;

@end
