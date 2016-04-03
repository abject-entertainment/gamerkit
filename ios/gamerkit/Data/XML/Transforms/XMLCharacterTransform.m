//
//  XMLCharacterTransform.m
//  gamerkit
//
//  Created by Benjamin Taggart on 2/24/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "XMLCharacterTransform.h"
#import "XMLDataContent.h"
#import "ContentManager.h"
#import "Character.h"
#import "Ruleset.h"
#import "CharacterDefinition.h"
#import <JavaScriptCore/JavaScriptCore.h>

#include <libxml/parser.h>
#include <libxml/tree.h>

const NSString *kXPath_Character_Name = @"/character/Name";
const NSString *kXPath_Character_System = @"/character/@system";
const NSString *kXPath_Character_Type = @"/character/@type";
const NSString *kXPath_Character_Token = @"/character/Token";

@interface XMLDataContent (friend_XMLCharacterTransform)

- (xmlDocPtr)xmlDoc;

@end

@interface XMLCharacterTransform ()
{
	JSContext *_js;
}
@end

@implementation XMLCharacterTransform

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_js = [[JSContext alloc] init];
		NSString *jsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
		jsPath = [jsPath stringByAppendingPathComponent:@"Core/displaychar.js"];
		[_js evaluateScript:[NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil]];
	}
	return self;
}

- (NSString *)sanitizeStringForFilename:(NSString *)string
{
	string = [string stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:nil];
	
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9_]+" options:0 error:nil];
	string = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@""];
	
	return string;
}

- (NSDictionary *)transformContentForPreview:(XMLDataContent*)content
{
	ContentManager *cm = [ContentManager contentManager];
	NSString *system = [content valueAtPath:kXPath_Character_System];
	Ruleset *rules = [cm systemForId:system];
	CharacterDefinition *type = rules.characterTypes[[content valueAtPath:kXPath_Character_Type]];
	NSString *subtitle = type?type.displayName:@"";
	
	return @{kXMLTransformKeyAction:[NSNumber numberWithUnsignedInteger:ContentObjectActionPreview],
			 kXMLTransformKeySucceeded: @YES,
			 kXMLTransformKeyTitle:[content valueAtPath:kXPath_Character_Name],
			 kXMLTransformKeySubtitle:subtitle,
			 kXMLTransformKeyImage:[content imageAtPath:kXPath_Character_Token]
			 };
}

- (NSDictionary *)transformContentForSharing:(XMLDataContent*)content
{
	NSString *filePath = NSTemporaryDirectory();
	filePath = [filePath stringByAppendingPathComponent:[self sanitizeStringForFilename:[content valueAtPath:kXPath_Character_Name]]];
	
	[content saveToFile:filePath];
	
	return @{kXMLTransformKeyAction:[NSNumber numberWithUnsignedInteger:ContentObjectActionShare],
			 kXMLTransformKeySucceeded: @YES,
			 kXMLTransformKeyFile: [NSURL URLWithString:filePath]
			 };
}

- (NSDictionary *)transformContentForPrinting:(XMLDataContent*)content
{
	return nil;
}

- (NSDictionary *)transformContentForWebView:(XMLDataContent*)content readOnly:(BOOL)readOnly
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	
	NSNumber *action = [NSNumber numberWithUnsignedInteger:readOnly?ContentObjectActionReadOnlyWebView:ContentObjectActionWebView];
	[result setObject:action forKey:kXMLTransformKeyAction];
	[result setObject:@NO forKey:kXMLTransformKeySucceeded];
	[result setObject:[NSNull null] forKey:kXMLTransformKeyHTML];
	
	xmlDocPtr xml = [content xmlDoc];
	if (xml)
	{
		Ruleset *rules = [[ContentManager contentManager] systemForId:[content valueAtPath:kXPath_Character_System]];
		
		CharacterDefinition *cdef = rules.characterTypes[[content valueAtPath:kXPath_Character_Type]];
		
		CharacterLayout *layout = cdef.editSheet;
		
		if (layout)
		{
//			NSString *html = [NSString stringWithContentsOfFile:layout.file encoding:NSUTF8StringEncoding error:nil];
			
//			result[kXMLTransformKeyHTML] = [HTMLTransformer transformHTML:html withData:content];
			result[kXMLTransformKeySucceeded] = @YES;
		}
	}
	
	return result;
}

- (NSDictionary *)transformContentForExportToPDF:(XMLDataContent*)content
{
	return nil;
}

@end
