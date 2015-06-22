//
//  ModalPicker.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 7/5/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModalPicker;
@protocol ModalPickerDelegate

- (BOOL)modalPicker:(ModalPicker*)picker donePicking:(NSArray*) results;
- (void)modalPicker:(ModalPicker*)picker selectionChanged:(NSInteger) newIndex forColumn:(NSInteger)column;
- (void)modalPicker:(ModalPicker*)picker isDoneHiding:(BOOL) animated fromResults:(NSArray*)results;

@end


@interface ModalPicker : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
	NSObject <ModalPickerDelegate> *pickDelegate;
	
	NSInteger numCols;
	NSMutableArray *arraysOfStrings;
	
	NSArray *last_results;
}

@property (nonatomic, assign) IBOutlet UIPickerView *picker;
@property (nonatomic, readonly) UIPopoverController *popover;

- (IBAction)done;
- (IBAction)cancel;

+ (id) showModalPicker:(NSObject<ModalPickerDelegate>*)delegate withColumns:(NSInteger)numCols andStringArrays:(NSArray*)array1, ...;
+ (void) cancelModalPicker;

- (void) setStringsForColumn:(NSInteger)column withArray:(NSArray*)stringArray;
- (NSString*) stringForRow:(NSInteger)row andColumn:(NSInteger)column;

// UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

// UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;

@end
