//
//  PackageManager.h
//  gamerkit
//
//  Created by Benjamin Taggart on 2/25/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProductCodeListConsumer <NSObject>
- (void)receiveProductCodes:(NSArray * _Nonnull)list;
@end

@interface PackageData : NSObject
@property (nonatomic, readonly, copy) NSString * _Nonnull tag;
@property (nonatomic, readonly, copy) NSString * _Nonnull name;
@property (nonatomic, readonly, copy) NSString * _Nonnull descr;
@property (nonatomic, readonly, assign) int installedVersion;
@property (nonatomic, readonly, assign) int availableVersion;
@property (nonatomic, readonly, copy) NSString * _Nullable price;
@end

@protocol PackageListConsumer <NSObject>
@optional
- (void)installedPackageFound:(PackageData * _Nonnull)package;
- (void)installedPackageLost:(PackageData * _Nonnull)package;
- (void)availablePackageFound:(PackageData * _Nonnull)package;
- (void)availablePackageLost:(PackageData * _Nonnull)package;
@end

@interface PackageManager : NSObject

@property (nonatomic, retain) NSSet<PackageData*> * _Nonnull installedPackages;
@property (nonatomic, retain) NSSet<PackageData*> * _Nonnull availablePackages;

+(PackageManager * _Nonnull)packageManager;

// packages
- (void) addPackageListConsumer:(id<PackageListConsumer> _Nonnull)consumer;
- (void) removePackageListConsumer:(id<PackageListConsumer> _Nonnull)consumer;

- (void) refreshPackageList;
- (void) purchaseRequestedForPackage:(PackageData * _Nonnull)package;

// codes
- (void) addProductCodeListConsumer:(id<ProductCodeListConsumer> _Nonnull)consumer;
- (void) removeProductCodeListConsumer:(id<ProductCodeListConsumer> _Nonnull)consumer;

- (void) submitProductCode:(NSString * _Nonnull)code withCallback:(void (^ _Nullable)(NSString * _Nullable message))callback;

@end
