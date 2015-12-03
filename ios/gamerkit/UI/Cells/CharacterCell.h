//
//  CharacterTableCell.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 2/19/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentCell.h"

@class Character;

@interface CharacterCell : ContentCell

@property (nonatomic,weak) IBOutlet UILabel *name;
@property (nonatomic,weak) IBOutlet UIImageView *token;
@property (nonatomic,weak) IBOutlet UILabel *summary;

@end
