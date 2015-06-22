//
//  CharacterViewController.h
//  gamerkit
//
//  Created by Benjamin Taggart on 5/27/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"

@class Character;

@interface CharacterViewController : PageViewController

@property (nonatomic, strong) IBOutlet UIBarItem* titleText;

@property (readonly) Character *character;
- (void)setCharacter:(Character*)character;

@end
