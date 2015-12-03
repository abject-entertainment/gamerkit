//
//  DiceView.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/18/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "DiceView.h"
#import "DataManager.h"

//extern BOOL bPad;

@implementation DiceView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        // Initialization code
    }
    return self;
}

// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//	return bPad || (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

- (void)quickValueChanged:(id)sender
{
	if (self.quickButton)
	{
		NSString *quick = [NSString stringWithFormat:@"Roll %@d%@", [self.quickCount titleForSegmentAtIndex:[self.quickCount selectedSegmentIndex]],
						   [self.quickSides titleForSegmentAtIndex:[self.quickSides selectedSegmentIndex]]];
		[self.quickButton setTitle:quick forState:UIControlStateNormal];
		[self.quickButton setTitle:quick forState:UIControlStateHighlighted];
		[self.quickButton setTitle:quick forState:UIControlStateDisabled];
		[self.quickButton setTitle:quick forState:UIControlStateSelected];
	}	
}

- (void)viewDidLoad
{
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithDictionary:[[DataManager getDataManager] getUserProperty:@"dice"]];

	if (self.quickCount)
	{
		self.quickCount.selectedSegmentIndex = [[prefs objectForKey:@"quickCount"] intValue];
	}
	
	if (self.quickSides)
	{
		self.quickSides.selectedSegmentIndex = [[prefs objectForKey:@"quickSides"] intValue];
	}
	
	if (self.notation)
	{
		self.notation.text = [prefs objectForKey:@"notation"];
		self.notation.delegate = self;
	}
	
	if (self.results)
	{
		self.results.text = [prefs objectForKey:@"results"];
	}
	
	srandomdev();
}

typedef enum
{
	DieOpt_Default = 0,
	
	DieOpt_HideIndividualRolls = 1,
	DieOpt_HideDroppedRolls = 2,
} DieRollOptions;

void doRoll(int count, int sides, int drop, bool bDropLow, int rerollMin, int rerollMax, int adjust, NSMutableString *outResults, DieRollOptions options)
{
	NSMutableArray *rolls = [NSMutableArray arrayWithCapacity:count];
	for (int i = 0; i < count; ++i)
	{
		int roll = 0;
		do
		{
			roll = (random() % sides) + 1;
		}
		while (roll >= rerollMin && roll <= rerollMax);
		[rolls addObject:[NSNumber numberWithInt:roll]];
	}
	
	NSMutableArray *dropIndices = [NSMutableArray arrayWithCapacity:drop];
	if (drop > 0)
	{
		for (int i = 0; i < sides; ++i)
		{
			for (int j = 0; j < count; ++j)
			{
				int roll = [[rolls objectAtIndex:j] intValue];
				if (roll == (bDropLow?(i+1):(sides-i)))
				{
					[dropIndices addObject:[NSNumber numberWithInt:j]];
					if (dropIndices.count == drop)
						break;
				}
			}
			if (dropIndices.count == drop)
				break;
		}
	}
	
	int sum = 0;
	for (int i = 0; i < rolls.count; ++i)
	{
		bool dropped = false;
		if (drop > 0)
		{
			for (int j = 0; j < dropIndices.count; ++j)
			{
				if (i == [[dropIndices objectAtIndex:j] intValue])
				{
					dropped = true;
					break;
				}
			}
		}
		
		if (i > 0)
		{
			if (!((options & DieOpt_HideIndividualRolls) ||
				((options & DieOpt_HideDroppedRolls) && dropped)))
				[outResults appendString:@"+"];
		}
		if (dropped)
		{
			if ((options & DieOpt_HideDroppedRolls) == 0 && (options & DieOpt_HideIndividualRolls) == 0)
				[outResults appendFormat:@"(%d)", [[rolls objectAtIndex:i] intValue]];
		}
		else
		{
			if ((options & DieOpt_HideIndividualRolls) == 0)
				[outResults appendFormat:@"%d", [[rolls objectAtIndex:i] intValue]];
				
			sum += [[rolls objectAtIndex:i] intValue];
		}
	}
	
	if ((options & DieOpt_HideIndividualRolls) == 0)
	{
		if (adjust != 0)
			[outResults appendFormat:@"%@%d", (adjust>0)?@"+":@"", adjust];
			
		[outResults appendString:@"="];
	}
	sum += adjust;
	[outResults appendFormat:@"%d", sum];
}

- (IBAction)rollNotation
{
	if (self.notation == nil) return;

	// parse notation
	NSString *nStr = self.notation.text;
	
	self.results.text = [DiceView doNotationRoll:nStr andSaveInPrefs:YES];

	[self.notation resignFirstResponder];
}

+ (NSString*)doNotationRoll:(NSString *)notation
{ return [DiceView doNotationRoll:notation andSaveInPrefs:NO]; }
+ (NSString*)doNotationRoll:(NSString *)nStr andSaveInPrefs:(BOOL)save
{
	NSMutableString *resultsStr = [NSMutableString stringWithCapacity:48];
	
	// comma-separated list
	NSArray *rolls = [nStr componentsSeparatedByString:@","];
	NSEnumerator *enumerator = [rolls objectEnumerator];
	NSString *roll;
	while ((roll = [enumerator nextObject]))
	{
		NSArray *parts = [roll componentsSeparatedByString:@"="];
		DieRollOptions options = DieOpt_Default;
		
		if (parts.count > 1)
		{
			NSString *prefix = [parts objectAtIndex:0];
			
			if ([prefix characterAtIndex:0] == '/')
			{
				int i = 1;
				char c = [prefix characterAtIndex:i];
				while (c != '/' && c != '=' && i < prefix.length)
				{
					switch ([prefix characterAtIndex:i])
					{
						case 'i':
							options |= DieOpt_HideIndividualRolls;
							break;
						case 'd':
							options |= DieOpt_HideDroppedRolls;
							break;
						default:
							break;
					}
					
					++i;
					c = [prefix characterAtIndex:i];
				}
				
				if (i < prefix.length)
					prefix = [prefix substringFromIndex:i+1];
				else
					prefix = @"";
			}
			
			if (prefix.length > 0)
				[resultsStr appendFormat:@"%@: ", prefix];
			roll = [parts objectAtIndex:1];
		}
		else
		{
			[resultsStr appendFormat:@"%@: ", roll];
		}
		
		NSScanner *scanner = [NSScanner scannerWithString:roll];
		
		// AdB
		int count;
		if (![scanner scanInt:&count]) { [resultsStr appendString:@"error"]; continue; } // error
		
		if (![scanner scanString:@"d" intoString:NULL]) { [resultsStr appendString:@"error"]; continue; } // error
		
		int sides;
		if (![scanner scanInt:&sides]) { [resultsStr appendString:@"error"]; continue; } // error
		
		// kNH, kNL
		int drop = 0;
		bool bDropLow = true;
		if ([scanner scanString:@"k" intoString:NULL])
		{
			if (![scanner scanInt:&drop]) { [resultsStr appendString:@"error"]; continue; } // error
			
			drop = count - drop; // notation is actually keep.  invert.
			
			if ([scanner scanString:@"H" intoString:NULL])
				bDropLow = true;
			else if ([scanner scanString:@"L" intoString:NULL])
				bDropLow = false;
		}
		
		// rX-Y
		int rerollMin = 0;
		int rerollMax = 0;
		if ([scanner scanString:@"r" intoString:NULL])
		{
			if (![scanner scanInt:&rerollMin]) { [resultsStr appendString:@"error"]; continue; } // error
			
			if ([scanner scanString:@"-" intoString:NULL])
			{
				if (![scanner scanInt:&rerollMax]) { [resultsStr appendString:@"error"]; continue; } // error
			}
			else
			{
				rerollMax = rerollMin;
			}

		}
		
		// +,-
		int adjust = 0;
		[scanner scanInt:&adjust];
		
		doRoll(count, sides, drop, bDropLow, rerollMin, rerollMax, adjust, resultsStr, options);
		
		if (parts.count > 2)
		{
			[resultsStr appendFormat:@" %@", [parts objectAtIndex:2]];
		}
		
		[resultsStr appendString:@"\n"];
	}
	
	if (save)
	{
		NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithDictionary:[[DataManager getDataManager] getUserProperty:@"dice"]];
		[prefs setValue:nStr forKey:@"notation"];
		[prefs setValue:resultsStr forKey:@"results"];
		[[DataManager getDataManager] setUserProperty:@"dice" value:prefs];
	}
	
	return resultsStr;
}

- (IBAction)rollQuick
{
	if (self.quickCount && self.quickSides && self.results)
	{
		int count = atoi([[self.quickCount titleForSegmentAtIndex:[self.quickCount selectedSegmentIndex]] UTF8String]);
		int sides = atoi([[self.quickSides titleForSegmentAtIndex:[self.quickSides selectedSegmentIndex]] UTF8String]);
		if (sides == 0) sides = 100;
		NSString *resultStr = [NSString stringWithFormat:@"%dd%d: ", count, sides];
		int total = 0;
		for (int i = 0; i < count; ++i)
		{
			int roll = (random() % sides) + 1;
			resultStr = [resultStr stringByAppendingFormat:@"%d, ", roll];
			total += roll;
		}
		resultStr = [resultStr stringByAppendingFormat:@" Total: %d", total];
		
		self.results.text = resultStr;

        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithDictionary:[[DataManager getDataManager] getUserProperty:@"dice"]];
		[prefs setValue:[NSNumber numberWithLong:self.quickCount.selectedSegmentIndex] forKey:@"quickCount"];
		[prefs setValue:[NSNumber numberWithLong:self.quickSides.selectedSegmentIndex] forKey:@"quickSides"];
		[prefs setValue:self.results.text forKey:@"results"];
		[[DataManager getDataManager] setUserProperty:@"dice" value:prefs];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self rollNotation];
	return NO;
}


@end
