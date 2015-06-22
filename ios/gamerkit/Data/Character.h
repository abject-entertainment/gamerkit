//
//  Character.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 2/19/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharacterLayout.h"
#import "ShareableContent.h"

@class Token;
@class UIImage;
@class Import;

@interface Character : ShareableContent {
	NSString *cachedXml;
	NSMutableDictionary *attributeValues;

	bool bFileDirty;
	bool bXmlDirty;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *system;
@property (nonatomic, readonly, copy) NSString *charType;
@property (nonatomic, readonly, copy) NSString *file;

@property (readonly) CharacterLayout *createSheet;
@property (readonly) CharacterLayout *editSheet;
@property (readonly) CharacterLayout *trackSheet;

@property (readonly) UIImage *miniImage;

- (id)initForSystem:(NSString*)system andType:(NSString*)type;
- (id)initWithFileAtPath:(NSString*)path fully:(BOOL)fullLoad;
- (id)initWithXMLString:(NSString*)xml fully:(BOOL)fullLoad;
- (void)saveFromWebView:(UIWebView*)webView;
- (void)import:(Import*)selectedImport fromText:(NSString*)html;
- (void)generateFileName;
- (void)saveToFile;

- (NSString*)setToken:(Token*)token;
- (NSString*)getToken;

- (NSString*)XmlString: (NSString*)xsltInstruction;
- (NSString*)HTMLString: (CharacterLayout*)layout;
- (NSURL*)baseURL;

- (NSData*)dataForSharing;
+ (NSString*)contentType;
- (id)initWithSharedData:(NSData*)data;
@end
