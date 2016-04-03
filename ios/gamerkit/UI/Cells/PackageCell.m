//
//  PackageCell.m
//  gamerkit
//
//  Created by Benjamin Taggart on 10/26/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import "PackageCell.h"
#import "PackageManager.h"

@interface PackageCell()
{
	id<PackageCellDelegate> _delegate;
	PackageData *_pdata;
}
@end

@implementation PackageCell

-(void)setImage:(UIImageView *)image
{
	_image = image;
	[_image setHidden: (image == nil)];
}

- (void)buyButtonWasConfirmed:(BuyButton *)button
{
	if (_delegate)
	{
		[_delegate packageCell:self didRequestPurchaseOfPackage:_pdata];
	}
}

-(void)setupForPackage:(PackageData *)pdata withDelegate:(id<PackageCellDelegate>)delegate
{
	_delegate = delegate;
	_pdata = pdata;
	
	if (pdata)
	{
		_name.text = pdata.name;
		if (_summary)
		{
			_summary.text = pdata.descr;
		}
		
		if (_image)
		{
			[_image setHidden:YES];
		}
		
		if (_update)
		{
			BOOL hasUpdate = pdata.availableVersion > pdata.installedVersion;
			_update.hidden = !hasUpdate;
			_update.enabled = hasUpdate;
		}
		
		if (_price)
		{
			_price.delegate = self;
			_price.product = pdata;
		}
	}
}

@end
