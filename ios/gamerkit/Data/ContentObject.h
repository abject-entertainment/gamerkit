//
//  ShareableContent.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/25/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BNHtmlPdfKit/BNHtmlPdfKit.h>

@class XMLDataContent;
@class XMLDataTransform;

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



@interface ContentTransformResult : NSObject

@property (nonatomic, readonly, assign) ContentObjectAction action;
@property (nonatomic, readonly, assign) BOOL succeeded;

// preview
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly, strong) UIImage *image;

// webview, readonlywebview
@property (nonatomic, readonly, copy) NSString *html;

// share, exporttopdf
@property (nonatomic, readonly, strong) NSURL *file;

// print
@property (nonatomic, readonly, strong) UIPrintFormatter *printFormatter;

@end



@interface ContentObject : NSObject<UIActivityItemSource, BNHtmlPdfKitDelegate>

- (instancetype)initWithFile:(NSString*)fileName;

@property (nonatomic, copy, readonly) NSString *fileName;
@property (nonatomic, strong, readonly) XMLDataContent *data;
@property (nonatomic, copy, readonly) BOOL dataIsLoaded;

- (void)loadData;
- (void)unloadData;

- (void)setTransform:(XMLDataTransform*)transform forAction:(ContentObjectAction)action;
- (ContentTransformResult *)transformForAction:(ContentObjectAction)action;

- (void)shareFromViewController:(UIViewController*)viewController;

- (id)initWithSharedData:(NSData*)data; // abstract

@end
