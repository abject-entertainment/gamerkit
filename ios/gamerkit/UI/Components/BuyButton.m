//
//  BuyButton.m
//  gamerkit
//
//  Created by Benjamin Taggart on 11/20/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import "BuyButton.h"
#import "PackageManager.h"

@interface BuyButton()
{
	NSString *_priceLabel;
	NSString *_confirmLabel;
	int _state;
}
@end

@implementation BuyButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		self.layer.cornerRadius = 2;
		self.layer.borderColor = self.tintColor.CGColor;
		self.layer.borderWidth = 1;
		[self setTitleColor:[self titleColorForState:UIControlStateNormal] forState:UIControlStateSelected];
		
		[self setTitle:@"..." forState:UIControlStateDisabled];
		self.enabled = NO;
		
		_product = nil;
		_state = -1;
		_priceLabel = @"Free";
		_confirmLabel = @"Get";
		
		[self deactivate];
		[self addTarget:self action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}

- (void)setProduct:(PackageData *)product
{
	_product = product;
	if (_product.price)
	{
		_priceLabel = _product.price;
		_confirmLabel = @"Buy";
		
		self.enabled = YES;
	}
//	else if (_product.price < 0)
//	{
#warning "<<AE>> Implement coming soon message."
//		self.enabled = NO;
//	}
	else
	{
		_priceLabel = @"Free";
		_confirmLabel = @"Get";
		self.enabled = YES;
	}
	
	[self deactivate];
}

- (void)onTap
{
	if (_state == 0)
	{
		_state = 1;
		[self setTitle:_confirmLabel forState:UIControlStateNormal];
		if (_delegate && [_delegate respondsToSelector:@selector(buyButtonWasActivated:)])
		{
			[_delegate buyButtonWasActivated:self];
		}
	}
	else if (_state == 1)
	{
		_state = 2;
		self.enabled = false;
		if (_delegate)
		{
			[_delegate buyButtonWasConfirmed:self];
		}
	}
}

- (void)deactivate
{
	_state = 0;
	[self setTitle:_priceLabel forState:UIControlStateNormal];
}

@end
