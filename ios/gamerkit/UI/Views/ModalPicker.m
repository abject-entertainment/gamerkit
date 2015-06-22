    //
//  ModalPicker.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 7/5/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "ModalPicker.h"

extern BOOL bPad;

static ModalPicker *g_ModalPicker = NULL;

@implementation ModalPicker

- (void) viewDidLoad {
	if (g_ModalPicker == NULL)
	{
		g_ModalPicker = self;
	}
}

- (void) setupModalPickerWithDelegate:(NSObject<ModalPickerDelegate>*)inDelegate withColumns:(NSInteger)inNumCols {
	if (bPad && _popover == nil)
	{
		CGSize sz = self.view.frame.size;
		_popover = [[UIPopoverController alloc] initWithContentViewController:self];
		_popover.popoverContentSize = sz;
	}

	pickDelegate = inDelegate;
	numCols = inNumCols;
	arraysOfStrings = [NSMutableArray arrayWithCapacity:numCols];
	
	for (int i = 0; i < numCols; ++i)
		[arraysOfStrings addObject:[NSNull null]];
}

+ (id) showModalPicker:(NSObject<ModalPickerDelegate>*)inDelegate withColumns:(NSInteger)inNumCols andStringArrays:(NSArray*)array1, ... 
{
	[g_ModalPicker setupModalPickerWithDelegate:inDelegate withColumns:inNumCols];
	
	va_list args;
	if (array1)
	{
		[g_ModalPicker setStringsForColumn:0 withArray: array1];
		va_start(args, array1);
		for (int i = 1; i < inNumCols; ++i)
		{
			[g_ModalPicker setStringsForColumn:i withArray: va_arg(args, NSArray*)];
		}
	}

//	[[RPG_ToolkitAppDelegate sharedApp] showFullScreenView:[g_ModalPicker view] withTransition:FSVT_SlideVertical];
	[g_ModalPicker.picker reloadAllComponents];
	if (g_ModalPicker.popover)
		return g_ModalPicker.popover;
	else
		return g_ModalPicker;
}

- (IBAction)done {
	BOOL animate = NO;
	
	last_results = nil;
	if (pickDelegate && _picker)
	{
		NSMutableArray *values = [NSMutableArray arrayWithCapacity:numCols];
		for (int i = 0; i < numCols; ++i)
		{
			NSInteger index = [_picker selectedRowInComponent:i];
			if (index >= 0 && index < [[arraysOfStrings objectAtIndex:i] count])
			{
				[values addObject:[[arraysOfStrings objectAtIndex:i] objectAtIndex:index]];
			}
			else
			{
				[values addObject:[NSNull null]];
			}
		}
		animate = [pickDelegate modalPicker:self donePicking:values];
		
		last_results = values;
	}

//	[[RPG_ToolkitAppDelegate sharedApp] hideFullScreenView:[g_ModalPicker view] withTransition:animate?FSVT_SlideVertical:FSVT_None];
}

- (IBAction)cancel {
	last_results = nil;
	
	if (pickDelegate)
		[pickDelegate modalPicker:self donePicking:nil];
	
//	[[RPG_ToolkitAppDelegate sharedApp] hideFullScreenView:[self view] withTransition:FSVT_SlideVertical];
	
	pickDelegate = nil;
	[arraysOfStrings removeAllObjects];
	arraysOfStrings = nil;
	numCols = 0;
}

- (void) setStringsForColumn:(NSInteger)column withArray:(NSArray*)stringArray
{
	if (pickDelegate && column >= 0 && column < numCols)
	{
		[arraysOfStrings replaceObjectAtIndex:column withObject:stringArray];
		
		if (_picker && [self.view superview]) [_picker reloadAllComponents];
	}
}

- (NSString*) stringForRow:(NSInteger)row andColumn:(NSInteger)column {
	if (column >= 0 && column < [arraysOfStrings count])
	{
		if (row >= 0 && row < [[arraysOfStrings objectAtIndex:column] count])
		{
			return [[arraysOfStrings objectAtIndex:column] objectAtIndex:row];
		}
	}
	return nil;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return numCols;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (component >= 0 && component < [arraysOfStrings count] && [arraysOfStrings objectAtIndex:component] != [NSNull null])
		return [[arraysOfStrings objectAtIndex:component] count];
	return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if (pickDelegate)
		[pickDelegate modalPicker:self selectionChanged:row forColumn:component];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (component >= 0 && component < numCols)
	{
		if (row >= 0 && row < [[arraysOfStrings objectAtIndex:component] count] && [arraysOfStrings objectAtIndex:component] != [NSNull null])
		{
			return [[arraysOfStrings objectAtIndex:component] objectAtIndex:row];
		}
	}
	return nil;
}

+ (void) cancelModalPicker
{
	[g_ModalPicker cancel];
}

- (void)viewDidDisappear:(BOOL)animated
{
	if (pickDelegate)
		[pickDelegate modalPicker:self isDoneHiding:animated fromResults:last_results];
	last_results = nil;

	// clean up
	pickDelegate = nil;
	[arraysOfStrings removeAllObjects];
	arraysOfStrings = nil;
	numCols = 0;
}

@end
