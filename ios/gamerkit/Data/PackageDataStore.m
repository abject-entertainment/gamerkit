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

static PackageDataStore *g_pds = nil;

@implementation PackageDataStore

#define SECTION_BUTTONS 0
#define SECTION_AVAILABLE 1
#define SECTION_INSTALLED 2

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

- (id)init 
{
	if (g_pds)
	{
		self = g_pds;
		return self;
	}
	
	g_pds = self;
	
	downloadFile = nil;
	downloadPath = nil;
	
	packages = nil;
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	
	DataManager *dm = [DataManager getDataManager];
	if ((self = [super init]))
	{
		if (dm)
		{
			if (dm.packageData == nil)
			{
				[self scanForPackages];
				dm.packageData = self;
			}
		}
	}
	return dm.packageData;
}

- (void)dealloc
{
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	_packageList = tableView;
	
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	_packageList = tableView;
	
	NSUInteger idx[2];
	[indexPath getIndexes: idx];
	
	UITableViewCell *cell = nil;
	
	if (_storeButtons && idx[0] == SECTION_BUTTONS)
	{
		return _storeButtons;
	}
	else
	{
		cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PackageCell"];
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PackageCell"];
		}
	}
		
	if (cell != nil)
	{
		DataManager *dm = [DataManager getDataManager];
		
		if (idx[0] == SECTION_INSTALLED) // installed
		{
			if (dm.installedPackages.count == 0)
			{
				cell.textLabel.text = @"No packages installed";
				cell.detailTextLabel.text = nil;
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			else 
			{
				cell.textLabel.text = [[dm.installedPackages objectAtIndex:idx[1]] objectAtIndex:2];
				int iVer = [[[dm.installedPackages objectAtIndex:idx[1]] objectAtIndex:4] intValue];
				int aVer = [[[dm.installedPackages objectAtIndex:idx[1]] objectAtIndex:5] intValue];
				if (aVer > iVer)
					cell.detailTextLabel.text = @"Update Available!";
				else
					cell.detailTextLabel.text = nil;
				cell.accessoryView = nil;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}

		}
        else if (idx[0] == SECTION_BUTTONS) // coupon code
        {
            cell.textLabel.text = @"Enter Code";
            cell.detailTextLabel.text = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
		else // available
		{
			if (dm.availablePackages.count == 0)
			{
				cell.textLabel.text = @"No packages available";
				cell.detailTextLabel.text = nil;
				cell.accessoryView = nil;
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			else
			{
				PackageData *pdata = [dm.availablePackages objectAtIndex:idx[1]];
				if (pdata.storeId)
				{
					if (pdata.storeProduct)
					{
						cell.textLabel.text = pdata.storeProduct.localizedTitle;
						NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
						[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
						[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
						[numberFormatter setLocale:pdata.storeProduct.priceLocale];
						cell.detailTextLabel.text = [numberFormatter stringFromNumber:pdata.storeProduct.price];
						cell.accessoryView = nil;
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					}
					else if ([pdata.storeId compare:@"!coming-soon"] == NSOrderedSame)
					{
						cell.textLabel.text = pdata.name;
						cell.detailTextLabel.text = @"Coming Soon!";
						cell.accessoryView = nil;
						cell.accessoryType = UITableViewCellAccessoryNone;
					}
					else 
					{
						cell.textLabel.text = pdata.name;
						cell.detailTextLabel.text = @"...";
						cell.accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
						[(UIActivityIndicatorView*)cell.accessoryView startAnimating];
					}
				}
				else
				{
					cell.textLabel.text = pdata.name;
					cell.detailTextLabel.text = @"Free";
					cell.accessoryView = nil;
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				}
			}
		}
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger idx[2];
	[indexPath getIndexes: idx];
	
	if (idx[0] == SECTION_BUTTONS && _storeButtons)
	{
		return _storeButtons.frame.size.height;
	}
	return tableView.rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	_packageList = tableView;
	
	DataManager *dm = [DataManager getDataManager];
	if (section == SECTION_INSTALLED)
	{
		NSInteger cnt = dm.installedPackages.count;
		return cnt;
	}
	else if (section == SECTION_BUTTONS)
    {
        return 1;
    }
    else
    {
		NSInteger cnt = dm.availablePackages.count;
		return cnt;
	}

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	_packageList = tableView;
	
	if (section == SECTION_INSTALLED) return @"Installed Packages";
    else if (section == SECTION_BUTTONS) return nil;
	else return @"Available Packages";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	_packageList = tableView;
	
	DataManager *dm = [DataManager getDataManager];
	if (section == SECTION_INSTALLED)
	{
		if (dm.installedPackages.count == 0)
			return @"No installed packages.";
		else
			return [NSString stringWithFormat:@"%lu installed packages.", (unsigned long)dm.installedPackages.count];
	}
	else if (section == SECTION_BUTTONS)
    {
        return nil;
    }
    else
	{
		if (dm.availablePackages.count == 0)
			return @"No available packages.";
		else
			return [NSString stringWithFormat:@"%lu available packages.", (unsigned long)dm.availablePackages.count];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	_packageList = tableView;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (!_productDetailView || !_storeView) return;
	
	DataManager *dm = [DataManager getDataManager];
	
	NSUInteger idx[2];
	[indexPath getIndexes: idx];
	
	if (idx[0] == SECTION_INSTALLED) // installed
	{
		if (idx[1] < dm.installedPackages.count)
		{
			_productDetailView.title.text = [[dm.installedPackages objectAtIndex:idx[1]] objectAtIndex:2];
			_productDetailView.description.text = [[dm.installedPackages objectAtIndex:idx[1]] objectAtIndex:1];
			int iVer = [[[dm.installedPackages objectAtIndex:idx[1]] objectAtIndex:4] intValue];
			int aVer = [[[dm.installedPackages objectAtIndex:idx[1]] objectAtIndex:5] intValue];
			[_productDetailView setButtonsInstalled:YES updatable:iVer < aVer];
		}
	}
    else if (idx[0] == SECTION_BUTTONS) // coupon code
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
		if (idx[1] < dm.availablePackages.count)
		{
			PackageData *pdata = [dm.availablePackages objectAtIndex:idx[1]];
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
	
	_productDetailView.section = idx[0];
	_productDetailView.row = idx[1];
//	[productDetailView.title sizeToFit];
//	[productDetailView.description sizeToFit];

	_productDetailView.frame = CGRectMake(0, 0, _storeView.frame.size.width, _storeView.frame.size.height);
	[_storeView addSubview:_productDetailView];
}

- (IBAction)storeRefresh
{
	[[DataManager getDataManager] checkForDownloadablePackages:nil];
	[_packageList reloadData];
}

- (IBAction)storeCodes
{
	if (_codeEntryView)
	{
		_codeEntryView.frame = CGRectMake(0, 0, _storeView.frame.size.width, _storeView.frame.size.height);
		[_storeView addSubview:_codeEntryView];
		return;
	}
}

- (IBAction)storeRestore
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)submitCode
{
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
    }
}

- (void)cancelCodeEntry
{
    if (_codeSubmit) _codeSubmit.enabled = true;
    if (_codeSpinner) [_codeSpinner stopAnimating];
    if (_codeResponse) _codeResponse.hidden = true;
    
    [_codeEntryView removeFromSuperview];
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
		if (_productDetailView.downloadingOverlay)
		{
			_productDetailView.downloadingOverlay.hidden = NO;
		}
		
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
	
	if (_productDetailView.downloadingOverlay)
	{
		_productDetailView.downloadingOverlay.hidden = YES;
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

	if (_productDetailView.downloadingOverlay)
	{
		_productDetailView.downloadingOverlay.hidden = YES;
	}
	
	[self productDetailCancel];
	
	if (downloadQueue && downloadQueue.count > 0)
	{
		NSString *url = [downloadQueue objectAtIndex:0];
		[downloadQueue removeObjectAtIndex: 0];
		[[NSRunLoop mainRunLoop] performSelector:@selector(helper_downloadAndInstallPackage:) 
		target:self argument:url order:0 modes:[NSArray arrayWithObject: NSDefaultRunLoopMode]];
	}
}

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
			[dm uninstallPackage:_productDetailView.row deleteContent:NO];
			[self productDetailCancel];
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

- (IBAction) productDetailCancel
{
	[_productDetailView removeFromSuperview];
	_productDetailView.section = -1;
	_productDetailView.row = -1;
	
	[_packageList reloadData];
}

- (IBAction) productDetailBuy
{
	DataManager *dm = [DataManager getDataManager];
	
	if (_productDetailView.row >= 0 && _productDetailView.row < dm.availablePackages.count)
	{
		PackageData *pdata = [dm.availablePackages objectAtIndex:_productDetailView.row];
		if (pdata.storeId == nil)
		{
			DataManager *dm = [DataManager getDataManager];
			
			// download
			if ([pdata.packageURL hasPrefix:@"http://"])
				[self downloadAndInstallPackage: pdata.packageURL];
			else
			{
				NSString *url = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:pdata.packageURL];
				[dm installPackageAtPath: url];
				[self productDetailCancel];
			}
			
			[_packageList reloadData];
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
}

- (IBAction)productDetailUpdate
{
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
	
	[_packageList reloadData];
}

- (IBAction)productDetailDelete
{
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
	}
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
