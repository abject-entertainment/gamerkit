//
//  PackageDataStore.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 7/7/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "PackageDataStore.h"
#import "DataManager.h"
#import "AppDelegate.h"
#import <StoreKit/SKProduct.h>
#import <StoreKit/SKPayment.h>
#import <StoreKit/SKPaymentTransaction.h>
#import <UIKit/UIAlertView.h>
#import "PackageHeaderCell.h"

extern BOOL __DEBUG__mockData;

@interface PackageDataStore()
{
	BOOL _firstView;
}
@end

@implementation PackageDataStore

#define SECTION_AVAILABLE 0
#define SECTION_INSTALLED 1

- (void)scanForPackages
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsPath = [paths objectAtIndex:0];
	docsPath = [docsPath stringByAppendingPathComponent:@"Packages"];
	
	paths = [fm contentsOfDirectoryAtPath:docsPath error:nil];
	if (paths)
	{
		packages = [NSMutableDictionary dictionaryWithCapacity:paths.count];
		for (int i = 0; i < paths.count; ++i)
		{
			if ([[paths objectAtIndex:i] hasSuffix:@".package"])
			{
				NSArray *packageContents = [NSArray arrayWithContentsOfFile:[docsPath stringByAppendingPathComponent:[paths objectAtIndex:i]]];
				if (packageContents && packageContents.count > 2)
				{
					[packages setObject:[packageContents objectAtIndex:1] forKey:[packageContents objectAtIndex:2]];
				}
			}
		}
	}
}

- (void)refresh
{ [self.collectionView reloadData]; }

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		_firstView = NO;
		downloadFile = nil;
		downloadPath = nil;
		
		packages = nil;
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
		
		DataManager *dm = [DataManager getDataManager];
		if (dm)
		{
			if (dm.packageData == nil)
			{
				dm.packageData = self;
				[self scanForPackages];
			}
		}
	}
	return self;
}

- (void)viewDidAppear:(BOOL)animated
{
	if (!_firstView)
	{
		_firstView = YES;
		self.collectionView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 60.0f, 0.0f);
		[self storeRefresh];
	}
}

- (void)dealloc
{
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 2;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	DataManager *dm = [DataManager getDataManager];
	
	if (section == SECTION_INSTALLED) // installed
	{
		PackageCell *cell = (PackageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"InstalledPackage" forIndexPath:indexPath];

		cell.name.text = [[dm.installedPackages objectAtIndex:row] objectAtIndex:2];
		int iVer = [[[dm.installedPackages objectAtIndex:row] objectAtIndex:4] intValue];
		int aVer = [[[dm.installedPackages objectAtIndex:row] objectAtIndex:5] intValue];
		if (cell.update)
        {
            cell.update.hidden = aVer <= iVer;
        }
		
		return cell;
	}
	else // available
	{
		PackageCell *cell = (PackageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"AvailablePackage" forIndexPath:indexPath];
		PackageData *pdata = [dm.availablePackages objectAtIndex:row];
		[cell setupForPackage:pdata withDelegate:self];
		
		return cell;
	}
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	DataManager *dm = [DataManager getDataManager];
	if (section == SECTION_INSTALLED)
	{
		NSInteger cnt = dm.installedPackages.count;
		return cnt;
	}
    else
    {
		NSInteger cnt = dm.availablePackages.count;
		return cnt;
	}

}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	if ([kind compare:UICollectionElementKindSectionHeader] == NSOrderedSame)
	{
		PackageHeaderCell* header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"PackageHeader" forIndexPath:indexPath];
		
		if (indexPath.section == SECTION_INSTALLED)
		{
			header.label.text = @"Installed Packages";
			header.count.text = [NSString stringWithFormat:@"%ld", (long)[self collectionView:collectionView numberOfItemsInSection:SECTION_INSTALLED]];
		}
		else
		{
			header.label.text = @"Available Packages";
			header.count.text = [NSString stringWithFormat:@"%ld", (long)[self collectionView:collectionView numberOfItemsInSection:SECTION_AVAILABLE]];
		}
		return header;
	}
	/*
	else if ([kind compare:UICollectionElementKindSectionFooter] == NSOrderedSame)
	{
		return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ButtonBar" forIndexPath:indexPath];
	}
	*/
	
	return nil;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (!_productDetailView || !_storeView) return;
	
	DataManager *dm = [DataManager getDataManager];
	
	if (indexPath.section == SECTION_INSTALLED) // installed
	{
		if (indexPath.row < dm.installedPackages.count)
		{
			NSInteger row = indexPath.row;
			_productDetailView.title.text = [[dm.installedPackages objectAtIndex:row] objectAtIndex:2];
			_productDetailView.description.text = [[dm.installedPackages objectAtIndex:row] objectAtIndex:1];
			int iVer = [[[dm.installedPackages objectAtIndex:row] objectAtIndex:4] intValue];
			int aVer = [[[dm.installedPackages objectAtIndex:row] objectAtIndex:5] intValue];
			[_productDetailView setButtonsInstalled:YES updatable:iVer < aVer];
		}
	}
    else if (indexPath.section == SECTION_BUTTONS) // coupon code
    {
        if (_codeEntryView)
        {
			_codeEntryView.frame = CGRectMake(0, 0, _storeView.frame.size.width, _storeView.frame.size.height);
            [_storeView addSubview:_codeEntryView];
            return;
        }
    }
	else // available
	{
		if (indexPath.section < dm.availablePackages.count)
		{
			PackageData *pdata = [dm.availablePackages objectAtIndex:indexPath.row];
			if (pdata.name)
			{
				if (pdata.storeId && [pdata.storeId compare:@"!coming-soon"] == NSOrderedSame)
				{
					return;
				}
				else
				{
					_productDetailView.title.text = pdata.name;
					_productDetailView.description.text = pdata.description;
					_productDetailView.downloadButton.title = @"Download Package";
					[_productDetailView setButtonsInstalled:NO updatable:NO];
				}
			}
			else if (pdata.storeProduct)
			{
				_productDetailView.title.text = pdata.storeProduct.localizedTitle;
				_productDetailView.description.text = pdata.storeProduct.localizedDescription;
				
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
				[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
				[numberFormatter setLocale:pdata.storeProduct.priceLocale];
				_productDetailView.downloadButton.title = [@"Buy for " stringByAppendingString:[numberFormatter stringFromNumber:pdata.storeProduct.price]];
				[_productDetailView setButtonsInstalled:NO updatable:NO];
			}
			else 
			{
				return;
			}
		}
	}
	
	_productDetailView.section = indexPath.section;
	_productDetailView.row = indexPath.row;
//	[productDetailView.title sizeToFit];
//	[productDetailView.description sizeToFit];

	_productDetailView.frame = CGRectMake(0, 0, _storeView.frame.size.width, _storeView.frame.size.height);
	[_storeView addSubview:_productDetailView];
}
*/

- (void)storeRefresh
{
	[[DataManager getDataManager] checkForDownloadablePackages:nil];
	[self.collectionView reloadData];
}

- (void)storeRestore
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)submitCode
{ /*
    if (_codeField == nil)
	{
		return;
	}
	
	[_codeField resignFirstResponder];
	
	if (_codeField.text.length > 0)
    {
        if (_codeSubmit) _codeSubmit.enabled = false;
        if (_codeSpinner) [_codeSpinner startAnimating];
        if (_codeResponse) _codeResponse.hidden = true;
        
        // submit the code
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://abject-entertainment.com/toolkit/submitCode.php?c=%@&d=%@", _codeField.text, [[[UIDevice currentDevice] identifierForVendor] UUIDString]]];
        NSError *error = nil;
        NSString *result = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        
//		fprintf(stdout, "Code submit query: %s\n", [[url absoluteString] UTF8String]);
//		fprintf(stdout, "Code submit result: %s\n", [result UTF8String]);
        if (error)
        {
            result = @"Submit failed.  Try again later.";
        }
		
		fprintf(stdout, "%s\n", [result UTF8String]);
        
        if (_codeSpinner) [_codeSpinner stopAnimating];
        if (_codeSubmit) _codeSubmit.enabled = true;
        if (_codeResponse)
        {
            _codeResponse.text = result;
            _codeResponse.hidden = false;
        }
        
        [[DataManager getDataManager] recheckDownloadablePackages];
    } */
}

- (void)helper_downloadAndInstallPackage:(id)url
{ if ([url isKindOfClass:[NSString class]]) [self downloadAndInstallPackage:(NSString*)url]; }
- (void)downloadAndInstallPackage:(NSString *)urlString
{
	if (downloadFile)
	{
		if (urlString)
		{
			if (downloadQueue == nil) downloadQueue = [[NSMutableArray alloc] initWithCapacity:2];
			
			[downloadQueue addObject:urlString];
		}
	}
	else
	{
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
												 cachePolicy:NSURLRequestUseProtocolCachePolicy
											 timeoutInterval:60.0f];
		if ([NSURLConnection canHandleRequest:request])
		{
			downloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
							[urlString substringFromIndex:[urlString rangeOfString:@"/" options:NSBackwardsSearch].location+1]];
			[[NSFileManager defaultManager] createFileAtPath:downloadPath contents:nil attributes:nil];
			downloadFile = [NSFileHandle fileHandleForWritingAtPath:downloadPath];
			
			if (downloadFile)
			{
				NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
				[conn start];
			}
		}
		else 
		{
			fprintf(stdout, "Cannot handle file request.\n");
			//TODO: show popup message
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	fprintf(stdout, "Cannot download package file: %s\n", [error.description UTF8String]);
	
	if (downloadFile)
	{
		[downloadFile closeFile];
		[[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
		downloadFile = nil;
	}
	
	//TODO: show popup message
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (downloadFile)
		[downloadFile writeData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (downloadFile)
		[downloadFile closeFile];
	
	[[DataManager getDataManager] installPackageAtPath:downloadPath];
	
	[[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
	downloadFile = nil;
	downloadPath = nil;

	if (downloadQueue && downloadQueue.count > 0)
	{
		NSString *url = [downloadQueue objectAtIndex:0];
		[downloadQueue removeObjectAtIndex: 0];
		[[NSRunLoop mainRunLoop] performSelector:@selector(helper_downloadAndInstallPackage:) 
		target:self argument:url order:0 modes:[NSArray arrayWithObject: NSDefaultRunLoopMode]];
	}
}

/*
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	DataManager *dm = [DataManager getDataManager];
	if (buttonIndex == actionSheet.cancelButtonIndex)
	{
		if ([actionSheet.title compare:@"Are you sure?"] == NSOrderedSame)
		{ // cancelled the action, do nothing
		}
		else
		{
			// Don't delete content.
//			[dm uninstallPackage:_productDetailView.row deleteContent:NO];
		}

	}
	else
	{
		// check which action sheet we're closing.
		if ([actionSheet.title compare:@"Are you sure?"] == NSOrderedSame)
		{
			// check to see if this is a system
			if (_productDetailView.row >= 0 && _productDetailView.row < dm.installedPackages.count)
			{
				NSArray *pdata = [dm.installedPackages objectAtIndex:_productDetailView.row];
				if (pdata && pdata.count > 2 && [[pdata objectAtIndex:3] compare:@"system" options:NSCaseInsensitiveSearch] == NSOrderedSame)
				{
					UIActionSheet *nextActionSheet = [[UIActionSheet alloc] initWithTitle:@"Also delete content (characters, etc.) for this system?"
																				 delegate:self
																		cancelButtonTitle:@"No, leave the content."
																   destructiveButtonTitle:@"Yes, delete the content."
																		otherButtonTitles:nil];
					[nextActionSheet showInView:_productDetailView];
				}
				else
				{
					// just delete the package
					[dm uninstallPackage:_productDetailView.row deleteContent:NO];
					[self productDetailCancel];
				}
			}
		}
		else
		{
			// should delete content
			[dm uninstallPackage:_productDetailView.row deleteContent:YES];
			[self productDetailCancel];
		}

	}
}
*/

-(void)packageCell:(PackageCell *)cell didRequestPurchaseOfPackage:(PackageData *)pdata
{
	if (pdata.storeId == nil || __DEBUG__mockData == YES)
	{
		DataManager *dm = [DataManager getDataManager];
		
		// download
        if ([pdata.packageURL hasPrefix:@"http://"] || [pdata.packageURL hasPrefix:@"https://"])
			[self downloadAndInstallPackage: pdata.packageURL];
		else
		{
			NSString *url = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:pdata.packageURL];
			[dm installPackageAtPath: url];
		}
		
		[self.collectionView reloadData];
	}
	else if (pdata.storeProduct && [SKPaymentQueue canMakePayments])
	{
		// buy, then download
		//[RPG_ToolkitAppDelegate sharedApp].purchasing += 1;
		SKPayment *payment = [SKPayment paymentWithProduct:pdata.storeProduct];
		if (payment)
			[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
}

- (IBAction)productDetailUpdate
{ /*
	DataManager *dm = [DataManager getDataManager];
	
	if (_productDetailView.row >= 0 && _productDetailView.row < dm.installedPackages.count)
	{
		NSArray *pdata = [dm.installedPackages objectAtIndex:_productDetailView.row];
		DataManager *dm = [DataManager getDataManager];
		
		// download
		NSString *surl = [pdata objectAtIndex:6];
		if ([surl hasPrefix:@"http://"])
			[self downloadAndInstallPackage: surl];
		else
		{
			NSString *url = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:surl];
			[dm installPackageAtPath: url];
			[self productDetailCancel];
		}
	}
	
	[self.collectionView reloadData];
	*/
}

- (IBAction)productDetailDelete
{ /*
	DataManager *dm = [DataManager getDataManager];
	
	if (_productDetailView.row >= 0 && _productDetailView.row < dm.installedPackages.count)
	{
		NSString *pkgId = [[dm.installedPackages objectAtIndex:_productDetailView.row] objectAtIndex:0];
		if ([pkgId caseInsensitiveCompare:@"Core"] == NSOrderedSame)
		{
			// can't delete core
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nope"
															 message:@"Can't delete core files."
															delegate:nil
												   cancelButtonTitle:@"Ok"
												   otherButtonTitles:nil];
			[alert show];
		}
		else
		{
			// delete
			
			// first, confirm deletion
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure?"
																	 delegate:self
															cancelButtonTitle:@"No, don't!"
													   destructiveButtonTitle:@"Yes, delete it."
															otherButtonTitles:nil];
			[actionSheet showInView:_productDetailView];
		}
	} */
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (int i = 0; i < transactions.count; ++i)
	{
		SKPaymentTransaction *trans = [transactions objectAtIndex:i];
		switch (trans.transactionState)
		{
			case SKPaymentTransactionStateFailed:
#warning <<AE>> Error case not implemented for purchasing
				//TODO show error
				break;
			case SKPaymentTransactionStatePurchasing:
				//Nothing here?
				break;
			case SKPaymentTransactionStatePurchased:
				fprintf(stdout, "SKPaymentTransactionStatePurchased\n");
			case SKPaymentTransactionStateRestored:
			{
				if (trans.transactionState == SKPaymentTransactionStateRestored)
					fprintf(stdout, "SKPaymentTransactionStateRestored\n");
					
				DataManager *dm = [DataManager getDataManager];
				for (int p = 0; p < dm.availablePackages.count; ++p)
				{
					PackageData *pdata = [dm.availablePackages objectAtIndex:p];
					if (pdata.storeProduct && [pdata.storeProduct.productIdentifier compare:trans.payment.productIdentifier] == NSOrderedSame)
					{
						[self downloadAndInstallPackage: pdata.packageURL];
						break;
					}
				}
				//[RPG_ToolkitAppDelegate sharedApp].purchasing -= 1;
				break;
			}
			case SKPaymentTransactionStateDeferred:
#warning <<AE>> Make sure there isn't something to do for the deferred purchase state.
				//TODO do something here?
				break;
		}
		
		if (trans.transactionState != SKPaymentTransactionStatePurchasing)
			[queue finishTransaction:trans];
	}
}
									  
@end
