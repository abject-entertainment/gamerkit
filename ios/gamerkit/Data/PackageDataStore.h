//
//  PackageDataStore.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 7/7/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/SKPaymentQueue.h>
#import "ProductDetailView.h"
#import "PackageCell.h"

@interface PackageDataStore : UICollectionViewController
<SKPaymentTransactionObserver, PackageCellDelegate> {
	NSMutableDictionary *packages;
	
	NSFileHandle *downloadFile;
	NSString *downloadPath;
	NSMutableArray *downloadQueue;
}

- (void) storeRefresh;
- (void) storeRestore;

- (void)downloadAndInstallPackage:(NSString *)urlString;
- (void)refresh;

@end
