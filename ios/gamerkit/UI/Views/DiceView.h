//
//  DiceView.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/18/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DiceView : UIView <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextView *results;
@property (nonatomic, strong) IBOutlet UITextField *notation;
@property (nonatomic, strong) IBOutlet UISegmentedControl *quickCount;
@property (nonatomic, strong) IBOutlet UISegmentedControl *quickSides;
@property (nonatomic, strong) IBOutlet UIButton *quickButton;

- (IBAction)rollNotation;
- (IBAction)rollQuick;

- (IBAction)quickValueChanged:(id)sender;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

- (NSString*)doNotationRoll:(NSString*)notation andSaveInPrefs:(BOOL)save;

@end
