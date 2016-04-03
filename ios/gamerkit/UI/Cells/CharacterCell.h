//
//  CharacterTableCell.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 2/19/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentCell.h"

@class ContentTransformResult;

@interface CharacterCell : ContentCell

@property (nonatomic,strong) IBOutlet UILabel *name;
@property (nonatomic,strong) IBOutlet UIImageView *token;
@property (nonatomic,strong) IBOutlet UILabel *summary;

- (void)setupForPreview:(ContentTransformResult*)preview;

@end
