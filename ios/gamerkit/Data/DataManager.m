//
//  DataManager.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 5/25/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "DataManager.h"
#import "Ruleset.h"
#import "Character.h"
#import "CharacterDefinition.h"
#import "Token.h"
#import "TokenListController.h"
#import "Map.h"
#import "MapsController.h"
#import "PackageDataStore.h"
#import "CharacterListController.h"
#import <StoreKit/SKPaymentQueue.h>
#import <StoreKit/SKProduct.h>

extern BOOL bPad;
extern NSString *packageString;

@implementation PackageData
- (id)init
{
	if ((self = [super init])) 
	{ 
		self.tag=nil;
		self.name=nil;
		self.descr=nil;
		self.packageURL=nil;
		self.storeProduct=nil;
		self.installedVersion=-1;
		self.availableVersion=-1;
	}
	return self; 
}
@end

@implementation DataManager

/*
- (TokenController*)tokenData
{
	if (_tokenData == nil)
	{
//		_tokenData = [[TokenController alloc] initWithNibName:(bPad?@"TokensView-iPad":@"TokensView") bundle:nil];
	}
	return _tokenData;
}

- (MapsController*)mapsData
{
	if (_mapsData == nil)
	{
//		_mapsData = [[MapsController alloc] initWithNibName:(bPad?@"MapsView-iPad":@"MapsView") bundle:nil];
	}
	return _mapsData;
}
*/

static DataManager *g_DataManager = nil;

-(id) init {
	if (g_DataManager)
	{
		self = g_DataManager;
		return self;
	}
	
	self = [super init];
	_systems = [[NSMutableDictionary alloc] init];
	
	_unknownRuleset = [[Ruleset alloc] initWithName:@"???" andDisplayName:@"Uninstalled System"];
	[_systems setObject:_unknownRuleset forKey:_unknownRuleset.name];
	
	bDataLoaded = NO;
	
	_installedPackages = [[NSMutableArray alloc] init];
	_availablePackages = [[NSMutableArray alloc] init];
	_newPackagesFound = 0;
	_packageDelegate = nil;
	packageListRequestData = nil;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	_docsPath = [paths objectAtIndex:0];
	_tempPath = NSTemporaryDirectory();
	
	// Make sure shareable classes are registered.
	[ShareableContent registerClass:[Character class] forContentType:[Character contentType]];
	[ShareableContent registerClass:[Token class] forContentType:[Token contentType]];
	[ShareableContent registerClass:[Map class] forContentType:[Map contentType]];

	g_DataManager = self;
	
	return self;
}

+(DataManager*) getDataManager {
	if (g_DataManager == nil)
	{
		g_DataManager = [[DataManager alloc] init];
	}
	return g_DataManager;
}

-(void) ErrorMessage:(NSString*) msg
{
	fprintf(stdout, "ZIPERROR: %s\n", [msg UTF8String]);
}

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

-(void) checkForDownloadablePackages:(NSObject<PackageListener> *)listener
{
#ifndef SINGLE_SYSTEM_SUPPORT
	if (listener == nil) listener = _packageDelegate;
	
	if (packageListRequestData == nil)
	{
		packageListRequestData = [[NSMutableData alloc] initWithCapacity:1024];
		[_availablePackages removeAllObjects];
		
		_newPackagesFound = 0;
		_packageDelegate = listener;

		NSString *url = [NSString stringWithFormat:@"http://abject-entertainment.com/toolkit/%@", packageString];
		
		fprintf(stdout, "Want to download package list from: %s", [url UTF8String]);
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
										cachePolicy:NSURLRequestUseProtocolCachePolicy
									timeoutInterval:60.0f];
		if ([NSURLConnection canHandleRequest:request])
		{
			NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
			[conn start];
		}
		else 
		{
			fprintf(stdout, "Cannot handle file request.\n");
			if (_packageDelegate) [_packageDelegate packageListObtained:self];
		}
	}
#else
	
#endif
}

-(void) recheckDownloadablePackages
{
#ifndef SINGLE_SYSTEM_SUPPORT
    if (_packageDelegate)
        [self checkForDownloadablePackages:_packageDelegate];
#endif
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	fprintf(stdout, "Cannot download package list: %s\n", [error.description UTF8String]);
	if (_packageDelegate) [_packageDelegate packageListObtained:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (packageListRequestData == nil) packageListRequestData = [[NSMutableData alloc] initWithCapacity:data.length];
	[packageListRequestData appendData: data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	fprintf(stdout, "Finished downloading\n");
	if (packageListRequestData)
	{
		NSString *packageXML = [[NSString alloc] initWithBytes:packageListRequestData.bytes
														 length:packageListRequestData.length
													   encoding:NSUTF8StringEncoding];
		
		fprintf(stdout, "%s\n", [packageXML UTF8String]);
		
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
						attr = (const char *)xmlGetProp(curElem, (const xmlChar*)"id");
						if (attr) pdata.tag = [NSString stringWithUTF8String:attr];
						xmlFree((void*)attr);
						xmlNodePtr subElem = curElem->children;
						while (subElem)
						{
							if (strcasecmp((const char *)subElem->name, "name") == 0)
							{
								pdata.name = [NSString stringWithUTF8String:(const char *)subElem->children->content];
							}
							else if (strcasecmp((const char *)subElem->name, "description") == 0)
							{
								pdata.descr = [NSString stringWithUTF8String:(const char *)subElem->children->content];
							}
							else if (strcasecmp((const char *)subElem->name, "package-url") == 0)
							{
								pdata.packageURL = [NSString stringWithUTF8String:(const char *)subElem->children->content];
							}
							subElem = subElem->next;
						}
						
						if (pdata.packageURL)
						{
							NSMutableDictionary *trackingData = [packageTracking objectForKey:pdata.tag];
							if (trackingData)
							{
								int aVersion = [[trackingData objectForKey:@"availableVersion"] intValue];
								int iVersion = [[trackingData objectForKey:@"installedVersion"] intValue];
								if (iVersion >= 0 && pdata.availableVersion > iVersion)
								{
									NSString *surl = pdata.packageURL;
									if (_packageData)
									{
										if ([surl hasPrefix:@"http://"])
											[_packageData downloadAndInstallPackage: surl];
										else
										{
											NSString *url = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:surl];
											[self installPackageAtPath: url];
										}
									}
									
//									++updatedPackagesFound;
								}
								pdata.installedVersion = iVersion;
								if (pdata.availableVersion > aVersion)
								{
									[trackingData setObject:[NSNumber numberWithInt:pdata.availableVersion] forKey:@"availableVersion"];
								}
							}
							else
							{
								trackingData = [NSMutableDictionary dictionaryWithCapacity:2];
								[trackingData setObject:[NSNumber numberWithInt:pdata.availableVersion] forKey:@"availableVersion"];
								[trackingData setObject:[NSNumber numberWithInt:-1] forKey:@"installedVersion"];
								++_newPackagesFound;
								[packageTracking setObject:trackingData forKey:pdata.tag];
							}
							
							BOOL installed = NO;
							for (int i = 0; i < _installedPackages.count; ++i)
							{
								if ([[[_installedPackages objectAtIndex:i] objectAtIndex:0] caseInsensitiveCompare:pdata.tag] == NSOrderedSame)
								{
									NSMutableArray *array = [_installedPackages objectAtIndex:i];
									while (array.count < 7)
										[array addObject:[NSNumber numberWithInt:-1]];
									[array replaceObjectAtIndex:5 withObject:[NSNumber numberWithInt:pdata.availableVersion]];
									[array replaceObjectAtIndex:6 withObject:pdata.packageURL?(id)pdata.packageURL:(id)[NSNull null]];
									installed = YES;
									break;
								}
							}
							if (!installed)
								[_availablePackages addObject:pdata];
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
		else if (_packageDelegate) {
			[_packageDelegate packageListObtained:self];
		}
		
		if (_packageData && [_packageData packageList])
			[[_packageData packageList] reloadData];
	}
	
	packageListRequestData = nil;
	
	[packageTracking writeToFile:packageTrackingFile atomically:YES];
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
	for (int i = 0; i < _availablePackages.count; ++i)
	{
		PackageData *pkg = [_availablePackages objectAtIndex:i];
		if (pkg.storeId != nil && pkg.storeProduct == nil)
		{
			[_availablePackages removeObjectAtIndex:i--];
		}
	}
	
	if (_packageDelegate) [_packageDelegate packageListObtained:self];
	//packageDelegate = nil;

	if (_packageData && [_packageData packageList])
		[[_packageData packageList] reloadData];

	// save tracking data
	[packageTracking writeToFile:packageTrackingFile atomically:YES];
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	fprintf(stdout, "Store request failed: %s", [[error localizedDescription] UTF8String]);
	
	if (_packageDelegate) [_packageDelegate packageListObtained:self];
}

- (void)requestDidFinish:(SKRequest *)request
{
	fprintf(stdout, "Store request finished.");
}

-(void) addInstalledPackage:(NSMutableArray*)meta
{
	while (meta.count < 7)
		[meta addObject:[NSNumber numberWithInt:-1]];
	[meta replaceObjectAtIndex:6 withObject:[NSNull null]];
	
	for (NSInteger i = 0; i < _availablePackages.count; ++i)
	{
		PackageData *pdata = [_availablePackages objectAtIndex:i];
		if ([pdata.tag compare:[meta objectAtIndex:0]] == NSOrderedSame)
		{
			[meta replaceObjectAtIndex:5 withObject:[NSNumber numberWithInt:pdata.availableVersion]];
			[meta replaceObjectAtIndex:6 withObject:pdata.packageURL];
			[_availablePackages removeObjectAtIndex:i--];
		}
	}

	for (NSInteger i = 0; i < _installedPackages.count; ++i)
	{
		if ([[[_installedPackages objectAtIndex:i] objectAtIndex:0] compare:[meta objectAtIndex:0]] == NSOrderedSame)
		{
			[_installedPackages replaceObjectAtIndex:i withObject:meta];
			return;
		}
	}
		
	[_installedPackages addObject:meta];
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
	
	if (bOK)
	{
		NSString *curFile = [unpack stringByAppendingPathComponent:@"package"];
		if ([fm fileExistsAtPath:curFile])
		{
			NSMutableArray *fileList = [NSMutableArray arrayWithContentsOfFile:curFile];
			if (fileList && fileList.count > 2)
			{
				NSError *error = nil;

				NSString *filePath = [_docsPath stringByAppendingPathComponent:@"Packages"];
				
				NSMutableArray *meta = [NSMutableArray arrayWithArray:[fileList objectAtIndex:0]];
				[self addInstalledPackage:meta];
				
				NSMutableDictionary *pData = [packageTracking objectForKey:[meta objectAtIndex:0]];
				if (pData == nil)
				{
					pData = [NSMutableDictionary dictionaryWithCapacity:2];
					[pData setObject:[NSNumber numberWithInt:-1] forKey:@"availableVersion"];
				}
				int Version = [[meta objectAtIndex:4] intValue];
				[pData setObject:[NSNumber numberWithInt:Version] forKey:@"installedVersion"];

				[packageTracking writeToFile:packageTrackingFile atomically:YES];
				
				ConfirmDirectory(fm, filePath);
				filePath = [filePath stringByAppendingPathComponent:[[meta objectAtIndex:0] stringByAppendingString:@".package"]];
				if ([fm fileExistsAtPath:filePath])
					[fm removeItemAtPath:filePath error:&error];
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
						filePath = [_docsPath stringByAppendingPathComponent:[curFile substringToIndex:slash]];
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
						
						if (bDataLoaded == YES)
						{
							if ([curFile hasSuffix:@".rules"])
							{
								fprintf(stdout, "Loading ruleset %s.\n", [filePath UTF8String]);
								Ruleset *rules = [[Ruleset alloc] initWithFileAtPath:filePath];
								Ruleset *existing = [_systems objectForKey:[rules name]];
								if (existing)
								{
									rules.characters = existing.characters;
								}
								[_systems setObject:rules forKey:[rules name]];
							}
							else if ([curFile hasSuffix:@".char"])
							{
								fprintf(stdout, "Loading character %s.\n", [filePath UTF8String]);
								Character *character = [[Character alloc] initWithFileAtPath:filePath fully:NO];
								[[self rulesetForName:character.system] addCharacter:character];
							}
							else if ([curFile hasSuffix:@".token"] && _tokenData)
							{
								fprintf(stdout, "Loading token %s.\n", [filePath UTF8String]);
								Token *t = [[Token alloc] initWithFileAtPath:filePath fully:NO];
								[_tokenData addToken:t];
							}
							else if ([curFile hasSuffix:@".map"] && _mapsData)
							{
								fprintf(stdout, "Loading map %s.\n", [filePath UTF8String]);
								Map *t = [[Map alloc] initWithFileAtPath:filePath fully:NO];
								[_mapsData addMap:t];
							}
						}
					}
					else 
					{
						fprintf(stdout, "package %s lists invalid file \"%s\"", [filename UTF8String], [curFile UTF8String]);
					}
				}
				
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
			}
			else 
			{
				fprintf(stdout, "package file failed to load or contains insufficient contents for package %s\n", [filename UTF8String]);
			}

		}
		else 
		{
			fprintf(stdout, "package %s contains no 'package' file\n", [filename UTF8String]);
		}

	}
	else
	{
		fprintf(stdout, "error unzipping package file %s\n", [filename UTF8String]);
	}

	// cleanup
	[fm removeItemAtPath:unpack error:nil];
}

- (void)uninstallPackage:(NSInteger)index deleteContent:(BOOL)shouldDeleteContent
{
	NSFileManager *fm = [NSFileManager defaultManager];
	if (index >= 0 && index < _installedPackages.count)
	{
		NSArray *pdata = [_installedPackages objectAtIndex:index];
		if (pdata)
		{
			NSString *pkgName = [pdata objectAtIndex:0];
			
			NSMutableDictionary *pData = [packageTracking objectForKey:pkgName];
			if (pData == nil)
			{
				pData = [NSMutableDictionary dictionaryWithCapacity:2];
				[pData setObject:[NSNumber numberWithInt:-1] forKey:@"availableVersion"];
			}
			[pData setObject:[NSNumber numberWithInt:-1] forKey:@"installedVersion"];
			[packageTracking writeToFile:packageTrackingFile atomically:YES];

			Ruleset *rules = [_systems objectForKey:pkgName];
			[rules deleteThisSystemAndItsContent:shouldDeleteContent];
			
			[_systems removeObjectForKey:pkgName];

			pkgName = [[_docsPath stringByAppendingPathComponent:@"Packages"]
					   stringByAppendingPathComponent:[pkgName stringByAppendingString:@".package"]];

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
						[fm removeItemAtPath:[_docsPath stringByAppendingPathComponent:file] error:nil];
					}
				}
			}
			[fm removeItemAtPath:pkgName error:nil];
		}
		[_characterData refreshData];
		[_installedPackages removeObjectAtIndex:index];
		[self checkForDownloadablePackages:_packageDelegate];
	}
}

-(void) checkForFirstRunSetup {
	NSString *filePath = nil;
	NSFileManager *fm = nil;
	NSError *error = nil;
	
	fm = [NSFileManager defaultManager];
	
	NSBundle *appBundle = [NSBundle mainBundle];
	if (!appBundle)
	{
		fprintf(stdout, "checkForFirstRunSetup: Could not get application bundle.\n");
		return;
	}
	
	packageTrackingFile = [_docsPath stringByAppendingPathComponent:@"packages.plist"];
	if (![fm fileExistsAtPath:packageTrackingFile])
	{
		[fm copyItemAtPath:[[appBundle bundlePath] stringByAppendingPathComponent:@"packages.plist"] toPath:packageTrackingFile error:&error];
		if (error)
		{
			fprintf(stdout, "Can't create %s: %s\n", [packageTrackingFile UTF8String], [error.description UTF8String]);
		}
	}
	
	fprintf(stdout, "Loading package tracking database from: %s\n", [packageTrackingFile UTF8String]);
	packageTracking = [NSMutableDictionary dictionaryWithContentsOfFile:packageTrackingFile];
	
	filePath = [_docsPath stringByAppendingPathComponent:@"user.plist"];
	
#if TARGET_IPHONE_SIMULATOR
	if (true)
#else
	if (![fm fileExistsAtPath:filePath])
#endif
	{
		fprintf(stdout, "checkForFirstRunSetup: Preference data not found.  Creating initial data.\n");
		
		[fm copyItemAtPath:[[appBundle bundlePath] stringByAppendingPathComponent:@"user.plist"] toPath:filePath error:nil];
		
		NSArray *paths = [fm contentsOfDirectoryAtPath:[appBundle bundlePath] error:nil];
		if (paths)
		{
			for (int i = 0; i < paths.count; ++i)
			{
				if ([[paths objectAtIndex:i] hasSuffix:@".pack"])
				{
					[self installPackageAtPath:[[appBundle bundlePath] stringByAppendingPathComponent:[paths objectAtIndex:i]]];
				}
			}
		}
	}
	else
	{
		fprintf(stdout, "checkForFirstRunSetup: Preference data found.  Wahoo.\n");
		
		// always reinstall Core.pack, so it is always up to date.
		[self installPackageAtPath:[[appBundle bundlePath] stringByAppendingPathComponent:@"Core.pack"]];
	}
	
	userProps = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
	userPropsPath = filePath;
	
	// iterate through installed packages
	NSEnumerator *iter = [packageTracking keyEnumerator];
	NSString *key = nil;
	while ((key = [iter nextObject]))
	{
		NSDictionary *value = [packageTracking objectForKey:key];
		if (![value isKindOfClass:[NSMutableDictionary class]])
		{
			value = [NSMutableDictionary dictionaryWithDictionary:value];
			[packageTracking setObject:value forKey:key];
		}
		
		int iVersion = [[value objectForKey:@"installedVersion"] intValue];
		fprintf(stdout, "Package %s is installed at version %d\n", [key UTF8String], iVersion);
		if (iVersion >= 0)
		{
			NSString *packageFile = [[_docsPath stringByAppendingPathComponent:@"Packages"] stringByAppendingPathComponent:[key stringByAppendingString:@".package"]];
			fprintf(stdout, "checking installed package: %s\n", [packageFile UTF8String]);
			NSMutableArray *packageContents = [NSMutableArray arrayWithContentsOfFile:packageFile];
			 
			if (packageContents && packageContents.count > 1)
				[self addInstalledPackage:[packageContents objectAtIndex:0]];
		}
	}
	// done with installed packages
}

-(void) loadData 
{
	NSFileManager *fm = nil;
	NSString *path = nil;
	NSError *error = nil;
	
	fm = [NSFileManager defaultManager];
	if (!fm)
	{
		fprintf(stdout, "loadSystems: Could not get file manager.\n");
		return;
	}
	
	// Systems
	path = [_docsPath stringByAppendingPathComponent:@"Systems"];
	NSArray *paths = [fm contentsOfDirectoryAtPath:path error:&error];
	
	if (error)
	{
		fprintf(stdout, "%s\n", [[error description] UTF8String]);
	}
	else
	{
		for (int i = 0; i < [paths count]; ++i)
		{
			NSString *filePath = [paths objectAtIndex:i];
			if (filePath && [filePath hasSuffix:@".rules"])
			{
				fprintf(stdout, "Loading ruleset %s.\n", [filePath UTF8String]);
				Ruleset *rules = [[Ruleset alloc] initWithFileAtPath:[path stringByAppendingPathComponent:filePath]];
				[_systems setObject:rules forKey:[rules name]];
			}
		}

		// System supplements
		for (int i = 0; i < [paths count]; ++i)
		{
			NSString *filePath = [paths objectAtIndex:i];
			if (filePath && [filePath hasSuffix:@".newrules"])
			{
				fprintf(stdout, "Loading supplemental ruleset %s.\n", [filePath UTF8String]);
				NSString *systemName = [filePath substringFromIndex:[filePath rangeOfString:@"/" options:NSBackwardsSearch].location + 1];
				systemName = [systemName substringToIndex:[systemName rangeOfString:@"."].location];
				Ruleset *rules = [_systems objectForKey:systemName];
				if (rules)
					[rules loadSupplementFromFile:filePath];
			}
		}
	}
	
	// Characters
	path = [_docsPath stringByAppendingPathComponent:@"Characters"];
	paths = [fm contentsOfDirectoryAtPath:path error:&error];
	
	if (error)
	{
		fprintf(stdout, "%s\n", [[error description] UTF8String]);
	}
	else
	{
		for (int i = 0; i < [paths count]; ++i)
		{
			NSString *filePath = [paths objectAtIndex:i];
			if (filePath && [filePath hasSuffix:@".char"])
			{
				fprintf(stdout, "Loading character %s.\n", [filePath UTF8String]);
				Character *character = [[Character alloc] initWithFileAtPath:[path stringByAppendingPathComponent:filePath] fully:NO];
				[[self rulesetForName:character.system] addCharacter:character];
			}
		}
	}
	
	bDataLoaded = YES;
}

-(Ruleset*) rulesetForName:(NSString*)name
{
	if (_systems == nil) return nil;
	Ruleset *rules = [_systems objectForKey:name];
	if (rules == nil) return _unknownRuleset;
	return rules;
}

- (void)pickSystem:(NSObject <ModalPickerDelegate> *)inDelegate withView:(UIViewController*)view andButton:(UIBarButtonItem*)btn {
#ifdef SINGLE_SYSTEM_SUPPORT
	[inDelegate modalPicker:nil donePicking:[NSArray arrayWithObject:SINGLE_SYSTEM]];
#else
	pickTarget = PICK_System;
	delegate = inDelegate;
	
	pickCol1 = [NSMutableArray arrayWithCapacity:[_systems count]-1];
	pickCol1Keys = [NSMutableArray arrayWithCapacity:[_systems count]-1];
	NSArray *sys = [_systems allKeys];
	for (int i = 0; i < sys.count; ++i)
	{
		Ruleset *rules = [_systems objectForKey:[sys objectAtIndex:i]];
		if (rules != _unknownRuleset)
		{
			[pickCol1 addObject:rules.displayName];
			[pickCol1Keys addObject:rules.name];
		}
	}
	
	id modal = [ModalPicker showModalPicker:self withColumns:1 andStringArrays:pickCol1];
	if (btn && [modal isKindOfClass:[UIPopoverController class]])
	{
		UIPopoverController *pop = (UIPopoverController *)modal;
		[pop presentPopoverFromBarButtonItem:btn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		pickerContainer = modal;
	}
	else if ([modal isKindOfClass:[UIViewController class]])
	{
		UIViewController *ctrl = (UIViewController*)modal;
		ctrl.modalTransitionStyle = UIModalTransitionStylePartialCurl;
		[view presentViewController:ctrl animated:YES completion:nil];
		pickerContainer = view;
	}
#endif
}

- (void)pickSystemAndType:(NSObject <ModalPickerDelegate> *)inDelegate withView:(UIViewController*)view andButton:(UIBarButtonItem*)btn {
	pickTarget = PICK_SystemAndType;
	delegate = inDelegate;
	
#ifndef SINGLE_SYSTEM_SUPPORT
	pickCol1 = [NSMutableArray arrayWithCapacity:[_systems count]-1];
	pickCol1Keys = [NSMutableArray arrayWithCapacity:[_systems count]-1];
	NSArray *sys = [_systems allKeys];
	for (int i = 0; i < sys.count; ++i)
	{
		Ruleset *rules = [_systems objectForKey:[sys objectAtIndex:i]];
		if (rules != _unknownRuleset)
		{
			[pickCol1 addObject:rules.displayName];
			[pickCol1Keys addObject:rules.name];
		}
	}
	
	Ruleset *rules = [_systems objectForKey:[pickCol1Keys objectAtIndex:0]];
#else
	Ruleset *rules = [_systems objectForKey:SINGLE_SYSTEM];
#endif
	NSArray *types = [rules.characterTypes allKeys];
	pickCol2 = [NSMutableArray arrayWithCapacity:types.count];
	for (int i = 0; i < types.count; ++i)
	{
		[pickCol2 addObject:[[rules.characterTypes objectForKey:[types objectAtIndex:i]] displayName]];
	}
	
#ifdef SINGLE_SYSTEM_SUPPORT
	id modal = [ModalPicker showModalPicker:self withColumns:1 andStringArrays:pickCol2];
#else
	id modal = [ModalPicker showModalPicker:self withColumns:2 andStringArrays:pickCol1, pickCol2];
#endif
	if (btn && [modal isKindOfClass:[UIPopoverController class]])
	{
		UIPopoverController *pop = (UIPopoverController *)modal;
		[pop presentPopoverFromBarButtonItem:btn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		pickerContainer = modal;
	}
	else if ([modal isKindOfClass:[UIViewController class]])
	{
		UIViewController *ctrl = (UIViewController*)modal;
		ctrl.modalTransitionStyle = UIModalTransitionStylePartialCurl;
		[view presentViewController:ctrl animated:YES completion:nil];
		pickerContainer = view;
	}
}

- (void)pickCharacterView:(NSObject <ModalPickerDelegate> *)inDelegate withView:(UIViewController*)view forCharacter:(Character*)character andButton:(UIBarButtonItem*)btn {
	pickTarget = PICK_CharacterView;
	delegate = inDelegate;
	
	Ruleset *rules = [_systems objectForKey:character.system];
	CharacterDefinition *cd = [rules.characterTypes objectForKey:character.charType];

	NSArray *layouts = [cd.sheets allKeys];
	pickCol1 = [NSMutableArray arrayWithCapacity:[layouts count]];
	for (int i = 0; i < layouts.count; ++i)
	{
		[pickCol1 addObject:[[cd.sheets objectForKey:[layouts objectAtIndex:i]] displayName]];
	}
	
	id modal = [ModalPicker showModalPicker:self withColumns:1 andStringArrays:pickCol1];
	if (btn && [modal isKindOfClass:[UIPopoverController class]])
	{
		UIPopoverController *pop = (UIPopoverController *)modal;
		[pop presentPopoverFromBarButtonItem:btn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		pickerContainer = modal;
	}
	else if ([modal isKindOfClass:[UIViewController class]])
	{
		UIViewController *ctrl = (UIViewController*)modal;
		ctrl.modalTransitionStyle = UIModalTransitionStylePartialCurl;
		[view presentViewController:ctrl animated:YES completion:nil];
		pickerContainer = view;
	}
}

- (void)pickImportSource:(NSObject <ModalPickerDelegate> *)inDelegate forClass:(Class)c withView:(UIViewController*)view andButton:(UIBarButtonItem*)btn {
	pickTarget = PICK_Import;
	delegate = inDelegate;
	
	if (c == [Character class])
	{
		pickCol1 = [NSMutableArray arrayWithCapacity:3];
		[pickCol1 addObject:@"Create New"];
		[pickCol1 addObject:@"Shared Content"];
		[pickCol1 addObject:@"Web Site"];
	}
	else if (c == [Token class])
	{
		pickCol1 = [NSMutableArray arrayWithCapacity:2];
		[pickCol1 addObject:@"Create New"];
		[pickCol1 addObject:@"Shared Content"];
	}
	else if (c == [Map class])
	{
		pickCol1 = [NSMutableArray arrayWithCapacity:2];
		[pickCol1 addObject:@"Create New"];
		[pickCol1 addObject:@"Shared Content"];
	}
	
	id modal = [ModalPicker showModalPicker:self withColumns:1 andStringArrays:pickCol1];
	if (btn && [modal isKindOfClass:[UIPopoverController class]])
	{
		UIPopoverController *pop = (UIPopoverController *)modal;
		[pop presentPopoverFromBarButtonItem:btn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		pickerContainer = modal;
	}
	else if ([modal isKindOfClass:[UIViewController class]])
	{
		UIViewController *ctrl = (UIViewController*)modal;
		ctrl.modalTransitionStyle = UIModalTransitionStylePartialCurl;
		[view presentViewController:ctrl animated:YES completion:nil];
		pickerContainer = view;
	}
}

- (BOOL)modalPicker:(ModalPicker*)picker donePicking:(NSArray*) results {
	if (pickerContainer)
	{
		if ([pickerContainer isKindOfClass:[UIPopoverController class]])
			[(UIPopoverController*)pickerContainer dismissPopoverAnimated:YES];
		else
			[pickerContainer dismissViewControllerAnimated:YES completion:nil];
		pickerContainer = nil;
	}
	
	return NO;
}

- (void)modalPicker:(ModalPicker *)picker isDoneHiding:(BOOL)animated fromResults:(NSArray *)results
{
	pickTarget = PICK_None;
	pickCol1 = pickCol2 = pickCol1Keys = nil;
	
	if (delegate)
		[delegate modalPicker:nil donePicking:results];
}

- (void)modalPicker:(ModalPicker*)picker selectionChanged:(NSInteger) newIndex forColumn:(NSInteger)column {
#ifndef SINGLE_SYSTEM_SUPPORT
	if (pickTarget == PICK_SystemAndType)
	{
		if (column == 0)
		{
			Ruleset *rules = [_systems objectForKey:[pickCol1Keys objectAtIndex:newIndex]];
			if (rules)
			{
				NSArray *types = [rules.characterTypes allKeys];
				pickCol2 = [NSMutableArray arrayWithCapacity:types.count];
				for (int i = 0; i < types.count; ++i)
				{
					[pickCol2 addObject:[[rules.characterTypes objectForKey:[types objectAtIndex:i]] displayName]];
				}
				[picker setStringsForColumn:1 withArray:pickCol2];
			}
		}
	}
#endif
}

- (id)getUserProperty:(NSString*)name
{
	if (userProps)
	{
		return [userProps objectForKey:name];
	}
	return nil;
}

- (BOOL)setUserProperty:(NSString*)name value:(id)value
{
	if (userProps)
	{
		[userProps setValue:value forKey:name];
		if (userPropsPath)
		{
			return [userProps writeToFile:userPropsPath atomically:YES];
		}
	}
	
	return NO;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	if (popoverController == pickerContainer)
		[ModalPicker cancelModalPicker];
}

@end
