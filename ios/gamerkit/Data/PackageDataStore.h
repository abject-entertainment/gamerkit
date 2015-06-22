//
//  PackageDataStore.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 7/7/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/SKPaymentQueue.h>
#import "ProductDetailView.h"

@interface PackageDataStore : NSObject 
<UITableViewDataSource, UITableViewDelegate, SKPaymentTransactionObserver, UIActionSheetDelegate> {
	NSMutableDictionary *packages;
	
	NSFileHandle *downloadFile;
	NSString *downloadPath;
	NSMutableArray *downloadQueue;
}

@property (nonatomic, retain) IBOutlet UIView *storeView;
@property (nonatomic, retain) IBOutlet ProductDetailView *productDetailView;
@property (nonatomic, readonly) UITableView *packageList;
@property (nonatomic, retain) IBOutlet UIView *codeEntryView;
@property (nonatomic, retain) IBOutlet UIButton *codeSubmit;
@property (nonatomic, retain) IBOutlet UITextField *codeField;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *codeSpinner;
@property (nonatomic, retain) IBOutlet UILabel *codeResponse;
@property (nonatomic, retain) IBOutlet UITableViewCell *storeButtons;

- (IBAction) productDetailCancel;
- (IBAction) productDetailBuy;
- (IBAction) productDetailUpdate;
- (IBAction) productDetailDelete;

- (IBAction) submitCode;
- (IBAction) cancelCodeEntry;

- (IBAction) storeRefresh;
- (IBAction) storeCodes;
- (IBAction) storeRestore;

- (void)downloadAndInstallPackage:(NSString *)urlString;

// UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;

// UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

// SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;

// UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;


@end
