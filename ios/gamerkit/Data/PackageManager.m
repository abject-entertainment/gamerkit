//
//  PackageManager.m
//  gamerkit
//
//  Created by Benjamin Taggart on 2/25/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "PackageManager.h"
#import <StoreKit/StoreKit.h>
#import "ZipArchive.h"
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <pthread.h>

static NSString *kPackageAPI_DEBUG = @"http://benmac.local:9000/toolkit/v2/packlist/ios/%@";
static NSString *kPackageAPI = @"https://domain.com/toolkit/v2/packlist/ios/%@";

extern BOOL __DEBUG__mockData;

@interface PackageData ()

@property (nonatomic, strong) SKProduct *storeProduct;
@property (nonatomic, copy) NSString *storeId;
@property (nonatomic, strong) NSURL *packageURL;

-(void)setTag:(NSString*)tag;
-(void)setName:(NSString*)name;
-(void)setDescr:(NSString*)descr;
-(void)setPrice:(NSString*)price;
-(void)setInstalledVersion:(int)installedVersion;
-(void)setAvailableVersion:(int)availableVersion;

@end

@implementation PackageData
- (id)init
{
	if ((self = [super init]))
	{
		_tag=@"";
		_name=@"";
		_descr=@"";
		_packageURL=nil;
		_storeId=nil;
		_storeProduct=nil;
		_price=nil;
		_installedVersion=-1;
		_availableVersion=-1;
	}
	return self;
}
-(NSUInteger)hash { return _tag.hash; }
-(void)setTag:(NSString * _Nonnull)tag { _tag = tag; }
-(void)setName:(NSString* _Nonnull)name { _name = name; }
-(void)setDescr:(NSString* _Nonnull)descr { _descr = descr; }
-(void)setPrice:(NSString * _Nullable)price { _price = price; }
-(void)setInstalledVersion:(int)installedVersion { _installedVersion = installedVersion; }
-(void)setAvailableVersion:(int)availableVersion { _availableVersion = availableVersion; }
@end

void ConfirmDirectory(NSFileManager *fm, NSString *dir);

@interface PackageManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver, ZipArchiveDelegate>
{
	NSString *_versionString;
	
	NSURLSession *_webServicesSession;
	NSMutableArray<NSURL *> *_downloadQueue;
	
	dispatch_semaphore_t _installedSem;
	NSMutableSet *_installedPackages;
	
	dispatch_semaphore_t _availableSem;
	NSMutableSet *_availablePackages;

	NSMutableSet *_packageListConsumers;
	NSMutableSet *_productCodeListConsumers;
}
@end

@implementation PackageManager

+ (PackageManager*)packageManager
{
	static PackageManager *instance;
	static dispatch_once_t flag;
	dispatch_once(&flag, ^{
		instance = [[PackageManager alloc] initPrivate];
	});
	return instance;
}

- (instancetype)init
{
	[NSException raise:@"Singleton"
				format:@"Use +[PackageManager packageManager]"];
	return nil;
}

- (void)dealloc
{
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (instancetype)initPrivate
{
	self = [super init];
	if (self)
	{
		NSString *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
		_versionString = [NSString stringWithFormat:@"%@/%@", versionStr,
					  [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
		
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];

		_installedSem = dispatch_semaphore_create(0);
		_installedPackages = [NSMutableSet set];
		dispatch_semaphore_signal(_installedSem);
		
		_availableSem = dispatch_semaphore_create(0);
		_availablePackages = [NSMutableSet set];
		dispatch_semaphore_signal(_availableSem);
		
		_packageListConsumers = [NSMutableSet set];
		_productCodeListConsumers = [NSMutableSet set];

		NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
		_webServicesSession = [NSURLSession sessionWithConfiguration:config];
		_downloadQueue = [NSMutableArray array];
		
		kPackageAPI_DEBUG = [NSString stringWithFormat:kPackageAPI_DEBUG, _versionString];
		kPackageAPI = [NSString stringWithFormat:kPackageAPI, _versionString];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self initInstalledPackages];
		});
	}
	return self;
}

- (void)initInstalledPackages
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	NSBundle *appBundle = [NSBundle mainBundle];
	
	// check to see if packages need to be updated after an app update
	// gather .pack files from app bundle
	NSString *rootPath = [appBundle bundlePath];
	NSMutableDictionary *bundlePackDates = [NSMutableDictionary dictionary];
	
	NSArray *paths = [fm contentsOfDirectoryAtPath:rootPath error:nil];
	if (paths)
	{
		for (NSString *packFile in paths)
		{
			if ([packFile hasSuffix:@".pack"])
			{
				NSDictionary *packAttrs = [fm attributesOfItemAtPath:[rootPath stringByAppendingPathComponent:packFile] error:nil];
				NSDate *packDate = [packAttrs objectForKey:NSFileCreationDate];
				[bundlePackDates setObject:packDate forKey:packFile];
			}
		}
	}
	
	rootPath = [docsPath stringByAppendingPathComponent:@"Packages"];
	paths = [fm contentsOfDirectoryAtPath:rootPath error:nil];
	if (paths)
	{
		for (NSString *packageFile in paths)
		{
			if ([packageFile hasSuffix:@".package"])
			{
				NSString *fromPackFile = [packageFile stringByReplacingOccurrencesOfString:@".package" withString:@".pack"];
				NSString *packagePath = [rootPath stringByAppendingPathComponent:packageFile];
				NSDate *packFileDate = [bundlePackDates objectForKey:fromPackFile];
				[bundlePackDates removeObjectForKey:fromPackFile];
				if (packFileDate)
				{
					NSDictionary *packageAttrs = [fm attributesOfItemAtPath:packagePath error:nil];
					NSDate *packageDate = [packageAttrs objectForKey:NSFileCreationDate];
					if ([packFileDate compare:packageDate] != NSOrderedAscending)
					{
						[self installPackageAtPath:[[appBundle bundlePath] stringByAppendingPathComponent:fromPackFile]];
						break;
					}
				}
				
				NSArray *packageData = [NSArray arrayWithContentsOfFile:[rootPath stringByAppendingPathComponent:packageFile]];
				if (packageData)
				{
					[self addInstalledPackage:packageData[0]];
				}
			}
		}
	}
	
	for (NSString *pack in [bundlePackDates keyEnumerator])
	{
		[self installPackageAtPath:[[appBundle bundlePath] stringByAppendingPathComponent:pack]];
	}
}

-(void) refreshPackageList
{
#ifndef SINGLE_SYSTEM_SUPPORT
	static pthread_mutex_t packageListMutex;
	static dispatch_once_t packageListOnce;
	dispatch_once(&packageListOnce, ^{
		pthread_mutex_init(&packageListMutex, NULL);
	});
	
	if (pthread_mutex_trylock(&packageListMutex) != 0)
	{ return; }
	
	NSString *url = kPackageAPI_DEBUG;
	
	fprintf(stdout, "Want to download package list from: %s", [url UTF8String]);
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:60.0f];
	
	NSURLSessionDataTask *task = [_webServicesSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
	{
		if (error)
		{
			NSLog(@"Cannot get package list from server.\n%@", error);
		}
		else
		{
			NSString *packageXML = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			
			NSLog(@"%@", packageXML);
			
			NSMutableArray *packageids = [NSMutableArray arrayWithCapacity:10];
			
			xmlDocPtr doc = xmlParseDoc((const xmlChar*)[packageXML UTF8String]);
			if (doc)
			{
				xmlNodePtr curElem = xmlDocGetRootElement(doc);
				
				if (curElem && strcasecmp((const char *)curElem->name, "packages") == 0)
				{
					curElem = curElem->children;
					while (curElem)
					{
						if (strcasecmp((const char *)curElem->name, "package") == 0)
						{
							const char *attr = NULL;
							
							PackageData *pdata = [[PackageData alloc] init];
							
							attr = (const char *)xmlGetProp(curElem, (const xmlChar*)"id");
							if (attr) pdata.tag = [NSString stringWithUTF8String:attr];
							xmlFree((void*)attr);
							
							PackageData *installedPdata = [_installedPackages member:pdata];
							PackageData *previousPdata = [_availablePackages member:pdata];
							if (installedPdata)
							{ pdata = installedPdata; }
							else if (previousPdata)
							{ pdata = previousPdata; }
					
							attr = (const char *)xmlGetProp(curElem, (const xmlChar*)"app-store-id");
							if (attr)
							{
								pdata.storeId = [NSString stringWithUTF8String:attr];
								
								if ([pdata.storeId compare:@""] == NSOrderedSame)
								{
									pdata.storeId = nil;
								}
								else if ([pdata.storeId compare:@"!coming-soon"] != NSOrderedSame)
								{
									fprintf(stdout, "Adding id to store request: %s\n", attr);
									[packageids addObject:pdata.storeId];
								}
							}
							xmlFree((void*)attr);
							
							attr = (const char *)xmlGetProp(curElem, (const xmlChar*)"version");
							if (attr) pdata.availableVersion = atoi(attr);
							xmlFree((void*)attr);
							
							NSLog(@"%@ (v %d)", pdata.tag, pdata.availableVersion);
							
							xmlNodePtr subElem = curElem->children;
							while (subElem)
							{
								if (strcasecmp((const char *)subElem->name, "name") == 0)
								{
									pdata.name = [NSString stringWithUTF8String:(const char *)subElem->children->content];
									NSLog(@" - Name: %@", pdata.name);
								}
								else if (strcasecmp((const char *)subElem->name, "description") == 0)
								{
									pdata.descr = [NSString stringWithUTF8String:(const char *)subElem->children->content];
									NSLog(@" - Description: %@", pdata.descr);
								}
								else if (strcasecmp((const char *)subElem->name, "package-url") == 0)
								{
									pdata.packageURL = [NSURL URLWithString:[NSString stringWithUTF8String:(const char *)subElem->children->content]];
									NSLog(@" - URL: %@", pdata.packageURL);
								}
								subElem = subElem->next;
							}
							
							if (pdata != installedPdata)
							{
								[_availablePackages addObject:pdata];
								if (pdata != previousPdata)
								{
									[self availablePackageFound:pdata];
								}
							}
						}
						curElem = curElem->next;
					}
				}
				xmlFreeDoc(doc);
			}
			
			if (packageids.count > 0 && [SKPaymentQueue canMakePayments])
			{
				fprintf(stdout, "Sending store request...\n");
				SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithArray:packageids]];
				request.delegate = self;
				[request start];
			}
		}
		
		pthread_mutex_unlock(&packageListMutex);
	}];
	
	[task resume];
#else
	
#endif
}

-(void) addInstalledPackage:(NSArray *)meta
{
	PackageData *pdata = [[PackageData alloc] init];
	
	pdata.tag = meta[0];
	pdata.descr = meta[1];
	pdata.name = meta[2];
	pdata.installedVersion = (int)[meta[4] integerValue];
	
	PackageData *available = [_availablePackages member:pdata];
	if (available)
	{
		[_availablePackages removeObject:available];
		
		pdata.availableVersion = available.availableVersion;
		pdata.storeId = available.storeId;
		pdata.storeProduct = available.storeProduct;
	}
	
	PackageData *installed = [_installedPackages member:pdata];
	if (installed)
	{
		[_installedPackages removeObject: installed];
		[self installedPackageLost: installed];
	}
	
	[_installedPackages addObject:pdata];
	[self installedPackageFound: pdata];

}

-(void) installPackageAtPath:(NSString*)path
{
	NSFileManager *fm = [NSFileManager defaultManager];
	
	fprintf(stdout, "Attempting to install package:\n\t%s\n", [path UTF8String]);
	NSString *filename = [path substringFromIndex:[path rangeOfString:@"/" options:NSBackwardsSearch].location + 1];
	NSString *unpack = [NSTemporaryDirectory() stringByAppendingPathComponent:[filename stringByAppendingString:@"_unpacked"]];
	ZipArchive *zFile = [[ZipArchive alloc] init];
	
	BOOL bOK = YES;
	bOK = [zFile UnzipOpenFile:path];
	if (bOK) bOK = [zFile UnzipFileTo:unpack overWrite:YES];
	if (bOK) [zFile UnzipCloseFile];
	
	NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	
	if (bOK)
	{
		NSString *curFile = [unpack stringByAppendingPathComponent:@"package"];
		if ([fm fileExistsAtPath:curFile])
		{
			NSMutableArray *fileList = [NSMutableArray arrayWithContentsOfFile:curFile];
			if (fileList && fileList.count > 2)
			{
				NSError *error = nil;
				
				NSString *filePath = [docsPath stringByAppendingPathComponent:@"Packages"];
				
				NSMutableArray *meta = [NSMutableArray arrayWithArray:[fileList objectAtIndex:0]];
				[self addInstalledPackage:meta];
				
				ConfirmDirectory(fm, filePath);
				filePath = [filePath stringByAppendingPathComponent:[[meta objectAtIndex:0] stringByAppendingString:@".package"]];
				if ([fm fileExistsAtPath:filePath])
				{
					// If we're installing a new version, remove the old one first, to catch deleted files.
					[self uninstallPackage:meta[0] deleteContent:YES];
				}
				[fm copyItemAtPath:curFile
							toPath:filePath
							 error:&error];
				
				if (error) fprintf(stdout, "error installing %s: %s\n", [filename UTF8String], [[error description] UTF8String]);
				
				// yes, we skip index 0, because that's the meta data
				for (int i = 1; i < fileList.count; ++i)
				{
					curFile = [fileList objectAtIndex:i];
					
					if ([curFile rangeOfString:@"/*" options:NSBackwardsSearch].location == curFile.length-2)
					{
						curFile = [curFile substringToIndex:curFile.length-2];
						NSDirectoryEnumerator *en = [fm enumeratorAtPath:curFile];
						
						NSString *path = nil;
						BOOL isDir = NO;
						
						while ((path = [en nextObject]))
						{
							if ([fm fileExistsAtPath:path isDirectory:&isDir])
							{
								if (!isDir)
								{
									[fileList addObject: [curFile stringByAppendingPathComponent:path]];
								}
							}
						}
					}
					
					NSUInteger slash = [curFile rangeOfString:@"/" options:NSBackwardsSearch].location;
					if (slash != NSNotFound)
					{
						filePath = [docsPath stringByAppendingPathComponent:[curFile substringToIndex:slash]];
						curFile = [curFile substringFromIndex:slash];
						ConfirmDirectory(fm, filePath);
						filePath = [filePath stringByAppendingPathComponent:curFile];
						
						if ([fm fileExistsAtPath:filePath])
						{
							// file already exists
							if ([curFile hasSuffix:@".char"] ||
								[curFile hasSuffix:@".token"] ||
								[curFile hasSuffix:@".map"])
							{
								// don't replace content
#if !TARGET_IPHONE_SIMULATOR
								continue;
#endif
							}
							[fm removeItemAtPath:filePath error:&error];
						}
						
						[fm copyItemAtPath:[unpack stringByAppendingPathComponent:curFile]
									toPath:filePath
									 error:&error];
						
/*						if (bDataLoaded == YES)
						{
							if ([curFile hasSuffix:@".rules"])
							{
								fprintf(stdout, "Loading ruleset %s.\n", [filePath UTF8String]);
								Ruleset *rules = [[Ruleset alloc] initWithFile:filePath];
								Ruleset *existing = [_systems objectForKey:[rules name]];
								if (existing)
								{
									for (Character *ch in existing.characters)
									{
										[rules addCharacter:ch];
									}
								}
								[_systems setObject:rules forKey:[rules name]];
							}
							else if ([curFile hasSuffix:@".char"])
							{
								fprintf(stdout, "Loading character %s.\n", [filePath UTF8String]);
								Character *character = [[Character alloc] initWithFile:filePath];
								[[self rulesetForName:character.system] addCharacter:character];
							}
							else if ([curFile hasSuffix:@".token"] && _tokenData)
							{
								fprintf(stdout, "Loading token %s.\n", [filePath UTF8String]);
								Token *t = [[Token alloc] initWithFileAtPath:filePath];
								[_tokenData addToken:t];
							}
							else if ([curFile hasSuffix:@".map"] && _mapsData)
							{
								fprintf(stdout, "Loading map %s.\n", [filePath UTF8String]);
								Map *t = [[Map alloc] initWithFileAtPath:filePath];
								[_mapsData addMap:t];
							}
						} */
					}
					else
					{
						NSLog(@"package %@ lists invalid file \"%@\"", filename, curFile);
					}
				}
/*
				if (_unknownRuleset)
				{
					for (int i = 0; i < _unknownRuleset.characters.count; ++i)
					{
						Character *c = [_unknownRuleset.characters objectAtIndex:i];
						Ruleset *r = [self rulesetForName:c.system];
						if (r && r != _unknownRuleset)
						{
							--i;
							[r addCharacter:c];
							[_unknownRuleset deleteCharacter:c];
						}
					}
				}
				
				if (_characterData) [_characterData refreshData];
 */
			}
			else
			{
				NSLog(@"package file failed to load or contains insufficient contents for package %@\n", filename);
			}
			
		}
		else
		{
			NSLog(@"package %@ contains no 'package' file\n", filename);
		}
		
	}
	else
	{
		NSLog(@"error unzipping package file %@\n", filename);
	}
	
	// cleanup
	[fm removeItemAtPath:unpack error:nil];
}

- (void)uninstallPackage:(NSString*)tag deleteContent:(BOOL)shouldDeleteContent
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	
	/*
	Ruleset *rules = [_systems objectForKey:pkgName];
	[rules deleteThisSystemAndItsContent:shouldDeleteContent];
	
	[_systems removeObjectForKey:pkgName];
	 */
	
	NSString *pkgName = [[docsPath stringByAppendingPathComponent:@"Packages"]
			   stringByAppendingPathComponent:[tag stringByAppendingString:@".package"]];
	
	NSArray *pkg = [NSArray arrayWithContentsOfFile:pkgName];
	if (pkg)
	{
		for (int i = 1; i < pkg.count; ++i)
		{
			NSString *file = [pkg objectAtIndex:i];
			
			if ([file rangeOfString:@"/*" options:NSBackwardsSearch].location == file.length-2)
			{ // remove wildcards so the whole directory is removed
				file = [file substringToIndex:file.length-2];
			}
			
			// TODO: add support for other content types
			if (shouldDeleteContent || !(
										 [file hasPrefix:@"Characters/"] ||
										 [file hasPrefix:@"Media/"]))
			{
				[fm removeItemAtPath:[docsPath stringByAppendingPathComponent:file] error:nil];
			}
		}
	}
	[fm removeItemAtPath:pkgName error:nil];
	
	PackageData *pdata = [[PackageData alloc] init];
	pdata.tag = tag;
	pdata = [_installedPackages member:pdata];
	if (pdata)
	{
		[_installedPackages removeObject:pdata];
		[self installedPackageLost:pdata];
	}
	
	[self refreshPackageList];
}

- (void)downloadAndInstallPackage:(NSURL *)url
{
	@synchronized(self) {
		if ([_downloadQueue indexOfObject:url] == NSNotFound)
		{
			[_downloadQueue addObject:url];
			[self touchDownloadQueue];
		}
	}
}

- (void)touchDownloadQueue
{
	static pthread_mutex_t downloadMutex;
	static dispatch_once_t downloadOnce;
	dispatch_once(&downloadOnce, ^{
		pthread_mutex_init(&downloadMutex, NULL);
	});
	
	if (pthread_mutex_trylock(&downloadMutex) != 0)
	{ return; }
	
	if (_downloadQueue.count == 0)
	{ return; }
	
	NSURL *url = [_downloadQueue firstObject];
	[_downloadQueue removeObjectAtIndex:0];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:60.0f];
	NSURLSessionDataTask *task = [_webServicesSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
	{
		
		if (error)
		{
			fprintf(stdout, "Cannot download package file: %s\n", [error.description UTF8String]);
		}
		else
		{
			CFUUIDRef uuid = CFUUIDCreate(NULL);
			CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
			CFRelease(uuid);
			NSString *downloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString*)uuidString];
			CFRelease(uuidString);
			
			[data writeToFile:downloadPath atomically:YES];
			[[PackageManager packageManager] installPackageAtPath:downloadPath];
			
			[[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
		}
		
		pthread_mutex_unlock(&downloadMutex);
		[self touchDownloadQueue];
	}];
	
	[task resume];
}

- (void)submitProductCode:(NSString *)code withCallback:(void (^)(NSString *))callback
{
#warning <<AE>> TODO
}

-(void) purchaseRequestedForPackage:(PackageData *)package
{
	if (package.storeId == nil || __DEBUG__mockData == YES)
	{
		// download
		if ([package.packageURL.scheme compare:@"http"] == NSOrderedSame ||
			[package.packageURL.scheme compare:@"https"] == NSOrderedSame)
		{
			[self downloadAndInstallPackage: package.packageURL];
		}
		else
		{
			[self installPackageAtPath: [package.packageURL absoluteString]];
		}
	}
	else if (package.storeProduct && [SKPaymentQueue canMakePayments])
	{
		// buy, then download
		//[RPG_ToolkitAppDelegate sharedApp].purchasing += 1;
		SKPayment *payment = [SKPayment paymentWithProduct:package.storeProduct];
		if (payment)
			[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	fprintf(stdout, "Products response received\n");
	
	for (int i = 0; i < response.invalidProductIdentifiers.count; ++i)
	{
		fprintf(stdout, "Invalid product identifier: %s\n", [[response.invalidProductIdentifiers objectAtIndex:i] UTF8String]);
	}
	
	for (int i = 0; i < response.products.count; ++i)
	{
		SKProduct *product = [response.products objectAtIndex:i];
		fprintf(stdout, "Product information received for: %s\n", [product.localizedTitle UTF8String]);
		NSString *packageName = product.productIdentifier;
		packageName = [packageName substringFromIndex:[packageName rangeOfString:@"." options:NSBackwardsSearch].location+1];
		
		NSEnumerator *iter = [_availablePackages objectEnumerator];
		PackageData *pkg = nil;
		
		while ((pkg = [iter nextObject]))
		{
			if ([pkg.storeId compare:product.productIdentifier] == NSOrderedSame)
			{
				pkg.storeProduct = product;
			}
		}
	}
	
	// clean up packages that didn't validate
	for (PackageData *pdata in _availablePackages)
	{
		if (pdata.storeId != nil && pdata.storeProduct == nil)
		{
			[_availablePackages removeObject:pdata];
			[self availablePackageLost:pdata];
		}
	}
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	fprintf(stdout, "Store request failed: %s", [[error localizedDescription] UTF8String]);
}

- (void)requestDidFinish:(SKRequest *)request
{
	fprintf(stdout, "Store request finished.");
}

// SKPaymentQueueDelegate
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
				
				for (PackageData *pdata in _availablePackages)
				{
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

#pragma mark Consumers
// PackageListProvider
- (void)addPackageListConsumer:(id<PackageListConsumer>)consumer
{
	if ([_packageListConsumers member:consumer] == nil)
	{
		[_packageListConsumers addObject:consumer];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			// send packages
			PackageData *pack;
			dispatch_semaphore_wait(_installedSem, DISPATCH_TIME_FOREVER);
			for (pack in _installedPackages)
			{
				[consumer installedPackageFound:pack];
			}
			dispatch_semaphore_signal(_installedSem);
			
			dispatch_semaphore_wait(_availableSem, DISPATCH_TIME_FOREVER);
			for (pack in _availablePackages)
			{
				[consumer availablePackageFound:pack];
			}
			dispatch_semaphore_signal(_availableSem);
		});
	}
}

- (void)removePackageListConsumer:(id<PackageListConsumer>)consumer
{
	[_packageListConsumers removeObject:consumer];
}

- (void)installedPackageFound:(PackageData * _Nonnull)package
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id <PackageListConsumer> consumer in _packageListConsumers)
		{
			if ([consumer respondsToSelector:@selector(installedPackageFound:)])
			{
				[consumer installedPackageFound:package];
			}
		}
	});
}

- (void)installedPackageLost:(PackageData * _Nonnull)package
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id <PackageListConsumer> consumer in _packageListConsumers)
		{
			if ([consumer respondsToSelector:@selector(installedPackageLost:)])
			{
				[consumer installedPackageLost:package];
			}
		}
	});
}

- (void)availablePackageFound:(PackageData * _Nonnull)package
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id <PackageListConsumer> consumer in _packageListConsumers)
		{
			if ([consumer respondsToSelector:@selector(availablePackageFound:)])
			{
				[consumer availablePackageFound:package];
			}
		}
	});
}

- (void)availablePackageLost:(PackageData * _Nonnull)package
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (id <PackageListConsumer> consumer in _packageListConsumers)
		{
			if ([consumer respondsToSelector:@selector(availablePackageLost:)])
			{
				[consumer availablePackageLost:package];
			}
		}
	});
}


// ProductCodeListProvider
- (void)addProductCodeListConsumer:(id<ProductCodeListConsumer>)consumer
{
	if ([_productCodeListConsumers member:consumer] == nil)
	{
		[_productCodeListConsumers addObject:consumer];
		
		//		if (_productCodeList)
		//		{
		//			[consumer receiveProductCodes:_productCodeList];
		//		}
		//		else
		//		{
		//			[self getProductCodeList];
		//		}
	}
}

- (void)removeProductCodeListConsumer:(id<ProductCodeListConsumer>)consumer
{
	[_productCodeListConsumers removeObject:consumer];
}

#pragma mark ZipArchive

// ZipArchiveDelegate
-(void) ErrorMessage:(NSString*) msg
{
	fprintf(stdout, "ZIPERROR: %s\n", [msg UTF8String]);
}

@end

void ConfirmDirectory(NSFileManager *fm, NSString *dir)
{
	BOOL isDirectory;
	if (![fm fileExistsAtPath:dir isDirectory: &isDirectory])
	{
		[fm createDirectoryAtPath: dir withIntermediateDirectories: YES attributes: nil error: nil];
	}
	else if (!isDirectory)
	{
		fprintf(stdout, "Directory exists as file.  Cannot install data.\n");
	}
}
