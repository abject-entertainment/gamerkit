//
//  ContentJSContext.m
//  gamerkit
//
//  Created by Benjamin Taggart on 4/1/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "ContentJSContext.h"
#import <JavaScriptCore/JavaScriptCore.h>

#import "Character.h"
#import "Token.h"

@interface ContentJSContext ()
{
	JSContext *_js;
}
@end

@implementation ContentJSContext

+(ContentJSContext *)contentContext
{
	static ContentJSContext *instance;
	static dispatch_once_t flag;
	dispatch_once(&flag, ^{
		instance = [[ContentJSContext alloc] initPrivate];
	});
	return instance;
}

- (instancetype) init
{
	[NSException raise:@"Singleton" format:@"Use +[ContentJSContext contentContext]"];
	return nil;
}

- (instancetype) initPrivate
{
	self = [super init];
	if (self)
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *docs = [paths objectAtIndex:0];
		
		_js = [[JSContext alloc] init];
		[_js setExceptionHandler:^(JSContext *ctx, JSValue *err) {
			NSLog(@"ContentJSContext EXCEPTION: %@", err);
		}];
		NSString *contentScript = [docs stringByAppendingPathComponent:@"Core/displaychar.js"];
		
		__weak ContentJSContext *this = self;
		
		// set up globals for file access
		_js[@"loadSystemXML"] = ^(NSString *systemName)
		{
			NSString *filename = [docs stringByAppendingPathComponent:[systemName stringByAppendingPathComponent:[systemName stringByAppendingString:@".gtsystem"]]];
			NSString *contents = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
			return contents;
		};
		
		_js[@"loadSheetModule"] = ^(NSString *systemName, NSString *sheetFile)
		{
			NSString *filename = [docs stringByAppendingPathComponent:[systemName stringByAppendingPathComponent:sheetFile]];
			NSString *contents = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
			return contents;
		};
		
		_js[@"requestNewToken"] = ^()
		{
			if (this.tokenRequestDelegate != nil)
			{
				[this.tokenRequestDelegate contextIsRequestingNewToken:this];
			}
		};
		
		[_js evaluateScript:@"var window=this;"];
		
		[_js evaluateScript:[NSString stringWithContentsOfFile:contentScript encoding:NSUTF8StringEncoding error:nil] withSourceURL:[NSURL fileURLWithPath:contentScript]];
	}
	return self;
}

- (NSString *)generateHTMLForCharacter:(Character *)character withAction:(ContentObjectAction)action
{
	if (action == ContentObjectActionDefault)
	{ action = ContentObjectActionReadOnlyWebView; }
	else if (action == ContentObjectActionPreview ||
			 action == ContentObjectActionShare)
	{ return nil; }
	
	NSString *actionString = @[[NSNull null],		// ContentObjectActionDefault
							   [NSNull null],		// ContentObjectActionPreview
							   @"view",				// ContentObjectActionWebView
							   @"view",				// ContentObjectActionReadOnlyWebView
							   [NSNull null],		// ContentObjectActionShare
							   @"print",			// ContentObjectActionPrint
							   @"export"			// ContentObjectActionExportToPDF
							][action];
	
	JSValue *generateHTML = _js[@"generateCharacterHTML"];
	JSValue *html = [generateHTML callWithArguments:@[ actionString, [NSString stringWithContentsOfFile:character.fileName encoding:NSUTF8StringEncoding error:nil]]];
	
	return [html toString];
}

- (NSDictionary *)getPreviewData:(ContentObject *)object
{
	if ([object isKindOfClass:[Character class]])
	{
		JSValue *getPreviewData = _js[@"getCharacterPreviewData"];
		JSValue *preview = [getPreviewData callWithArguments:@[[NSString stringWithContentsOfFile:object.fileName encoding:NSUTF8StringEncoding error:nil]]];
		
		return @{
				 @"name": [preview[@"name"] toString],
				 @"token": [preview[@"token"] toString]
				};
	}
	return nil;
}

- (void)provideToken:(Token *)token
{
	NSData *data = UIImageJPEGRepresentation(token.image, 0.85f);
	NSString *base64data = [data base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength | NSDataBase64EncodingEndLineWithLineFeed];
	
	[_js[@"updateExpectedToken"] callWithArguments:@[base64data]];
}

@end
