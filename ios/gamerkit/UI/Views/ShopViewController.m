//
//  ShopViewController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 11/16/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import "ShopViewController.h"
#import "PackageDataStore.h"

@implementation ShopViewController

-(IBAction)refreshList:(id)sender
{
	for (UIViewController *vc in self.childViewControllers) {
		if ([vc isKindOfClass:PackageDataStore.class])
		{
			[(PackageDataStore*)vc storeRefresh];
		}
	}
}

-(IBAction)restorePurchases:(id)sender
{
	for (UIViewController *vc in self.childViewControllers) {
		if ([vc isKindOfClass:PackageDataStore.class])
		{
			[(PackageDataStore*)vc storeRestore];
		}
	}
}

@end
