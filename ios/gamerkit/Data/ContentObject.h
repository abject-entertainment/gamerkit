//
//  ShareableContent.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/25/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMLDataContent;

typedef enum : NSUInteger {
	ContentObjectActionDefault,
	ContentObjectActionPreview,
	ContentObjectActionWebView,
	ContentObjectActionReadOnlyWebView,
	ContentObjectActionShare,
	ContentObjectActionPrint,
	ContentObjectActionExportToPDF,
	
	ContentObjectActionMAX
} ContentObjectAction;

@class ContentTransform;
@class ContentTransformResult;

@interface ContentObject : NSObject<UIActivityItemSource>

- (instancetype)initWithFile:(NSString*)fileName;

@property (nonatomic, copy, readonly) NSString *fileName;
@property (nonatomic, strong, readonly) XMLDataContent *data;
@property (nonatomic, assign, readonly) BOOL dataIsLoaded;

@property (nonatomic, copy, readonly) NSString *contentPath;

- (void)loadData;
- (void)unloadData;
- (void)saveFile;

- (ContentTransformResult *)getPreview;

- (void)setTransform:(ContentTransform*)transform forAction:(ContentObjectAction)action;
- (ContentTransformResult *)applyTransformForAction:(ContentObjectAction)action;
- (ContentTransformResult *)applyTransform:(ContentTransform*)transform forAction:(ContentObjectAction)action;

- (void)shareFromViewController:(UIViewController*)viewController;

- (id)initWithSharedData:(NSData*)data; // abstract

@end
