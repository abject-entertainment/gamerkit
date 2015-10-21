//
//  DataManager.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 5/25/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/SKProductsRequest.h>
#import <StoreKit/SKProduct.h>
#import "ModalPicker.h"
#import "ZipArchive.h"

@class Ruleset;
@class CharacterListController;
@class PackageDataStore;
@class SharedContentDataStore;
@class Character;
@class TokenListController;
@class MapsController;

typedef enum _PickTarget {
	PICK_None,
	PICK_System,
	PICK_SystemAndType,
	PICK_CharacterView,
	PICK_Import,
	
	PICK_MAX
} PickTarget;

@interface PackageData : NSObject
@property (assign) NSString *tag;
@property (assign) NSString *name;
@property (assign) NSString *descr;
@property (assign) NSString *storeId;
@property (assign) NSString *packageURL;
@property (assign) SKProduct *storeProduct;
@property (assign) int installedVersion;
@property (assign) int availableVersion;
@end

@protocol PackageListener;

@interface DataManager : NSObject <ModalPickerDelegate, ZipArchiveDelegate, SKProductsRequestDelegate, UIPopoverControllerDelegate> {
	BOOL bDataLoaded;
	
	NSMutableDictionary *packageTracking;
	NSString *packageTrackingFile;
	NSMutableData *packageListRequestData;
	
	NSMutableArray *_installedPackages;
	NSMutableArray *_availablePackages;
	
	NSObject <ModalPickerDelegate> *delegate;
	PickTarget pickTarget;
	NSMutableArray *pickCol1;
	NSMutableArray *pickCol1Keys;
	NSMutableArray *pickCol2;
	id pickerContainer;
	
	NSMutableDictionary *userProps;
	NSString *userPropsPath;
}

@property (nonatomic, retain) NSMutableDictionary *systems;
@property (nonatomic, retain) UIViewController *rootController;
@property (nonatomic, retain) CharacterListController *characterData;
@property (nonatomic, retain) PackageDataStore *packageData;
@property (nonatomic, retain) SharedContentDataStore *sharedData;
@property (nonatomic, readonly) TokenListController *tokenData;
@property (nonatomic, readonly) MapsController *mapsData;
@property (nonatomic, retain) NSArray *installedPackages;
@property (nonatomic, retain) NSArray *availablePackages;
@property (nonatomic, readonly) NSInteger newPackagesFound;
@property (nonatomic, readonly) NSInteger updatedPackagesFound;
@property (nonatomic, readonly, retain) Ruleset *unknownRuleset;
@property (nonatomic, readonly) NSString *docsPath;
@property (nonatomic, readonly) NSString *tempPath;
@property (nonatomic, assign) NSObject<PackageListener> *packageDelegate;

-(id) init;
-(void) checkForDownloadablePackages:(NSObject<PackageListener>*)listener;
-(void) recheckDownloadablePackages;
-(void) checkForFirstRunSetup;
-(void) loadData;

- (Ruleset*)rulesetForName:(NSString*)name;

+(DataManager *) getDataManager;

// ZipArchiveDelegate
- (void)ErrorMessage:(NSString*) msg;

// ModalPickerDelegate
- (BOOL)modalPicker:(ModalPicker*)picker donePicking:(NSArray*) results;
- (void)modalPicker:(ModalPicker*)picker selectionChanged:(NSInteger) newIndex forColumn:(NSInteger)column;

// ModalPickerUses
- (void)pickSystem:(NSObject <ModalPickerDelegate> *)delegate withView:(UIViewController*)view andButton:(UIBarButtonItem*)btn;
- (void)pickSystemAndType:(NSObject <ModalPickerDelegate> *)delegate withView:(UIViewController*)view andButton:(UIBarButtonItem*)btn;
- (void)pickCharacterView:(NSObject <ModalPickerDelegate> *)delegate withView:(UIViewController*)view forCharacter:(Character*)character andButton:(UIBarButtonItem*)btn;
- (void)pickImportSource:(NSObject <ModalPickerDelegate> *)delegate forClass:(Class)c withView:(UIViewController*)view andButton:(UIBarButtonItem*)btn;

// SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error;
- (void)requestDidFinish:(SKRequest *)request;

// UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;

- (void)installPackageAtPath:(NSString*)path;
- (void)uninstallPackage:(NSInteger)index deleteContent:(BOOL)shouldDeleteContent;

- (id)getUserProperty:(NSString*)name;
- (BOOL)setUserProperty:(NSString*)name value:(id)value;
@end

@protocol PackageListener
- (void)packageListObtained:(DataManager *)dm;
@end


