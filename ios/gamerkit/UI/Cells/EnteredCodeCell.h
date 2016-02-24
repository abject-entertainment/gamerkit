//
//  EnteredCodeCell.h
//  gamerkit
//
//  Created by Benjamin Taggart on 2/22/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnteredCodeCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *codeEntered;
@property (nonatomic, strong) IBOutlet UILabel *dateSubmitted;
@property (nonatomic, strong) IBOutlet UITextView *features;

@end
