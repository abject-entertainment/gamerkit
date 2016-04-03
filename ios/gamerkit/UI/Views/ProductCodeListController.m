//
//  ProductCodeListController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 2/22/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "ProductCodeListController.h"
#import "EnteredCodeCell.h"
#import "DismissSegue.h"

@interface ProductCodeListController ()
{
	NSArray *_codes;
}

@property (nonatomic, weak) IBOutlet UITableView *codeList;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ProductCodeListController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_codes = nil;
	
	[[PackageManager packageManager] addProductCodeListConsumer:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{ return 1; }

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_codes)
	{
		return 0;
	}
	else
	{
		return _codes.count;
	}
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	EnteredCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EnteredCode" forIndexPath:indexPath];
	
	if (indexPath.row < _codes.count)
	{
		NSDictionary *row = _codes[indexPath.row];
		
		cell.codeEntered.text = [row objectForKey:@"code"];
		
		NSDateFormatter *format = [[NSDateFormatter alloc] init];
		format.dateStyle = NSDateFormatterShortStyle;
		format.timeStyle = NSDateFormatterShortStyle;
		format.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
		cell.dateSubmitted.text = [format stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:[[row objectForKey:@"date"] doubleValue]]];
		
		cell.features.text = [row objectForKey:@"description"];
	}
	
	return cell;
}

- (void) receiveProductCodes:(NSArray *)list
{
	_codes = list;
	[self.codeList reloadData];
	
	if (list && list.count > 0)
	{ [self.spinner stopAnimating]; }
	else
	{ [self.spinner startAnimating]; }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue isKindOfClass:DismissSegue.class])
	{
		[[PackageManager packageManager] removeProductCodeListConsumer: self];
	}
}

@end
