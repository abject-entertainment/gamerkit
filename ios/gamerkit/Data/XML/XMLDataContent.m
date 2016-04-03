//
//  XMLDataContent.m
//  gamerkit
//
//  Created by Benjamin Taggart on 2/23/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "XMLDataContent.h"
#include <libxml/parser.h>
#include <libxml/tree.h>
#include <libxml/xpath.h>

NSString *sanitizeContentString(NSString *string);
NSString *getContentFromNode(xmlNodePtr node);
const xmlChar *toXmlStr(const NSString *nsStr);
NSString *toNSString(const xmlChar *xmlStr);

@interface XMLDataContent()
{
	xmlDocPtr _xmlDoc;
	xmlXPathContextPtr _xPath;
}
@end

@implementation XMLDataContent

- (instancetype)initWithXmlString:(NSString *)xml
{
	self = [super init];
	if (self)
	{
		_xmlDoc = xmlParseDoc(toXmlStr(xml));
		if (_xmlDoc)
		{
			_xPath = xmlXPathNewContext(_xmlDoc);
		}
	}
	return self;
}

- (instancetype)initWithData:(NSData *)data
{
	return [self initWithXmlString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

- (instancetype)initWithFileAtPath:(NSString *)filepath
{
	return [self initWithData:[NSData dataWithContentsOfFile:filepath]];
}

- (void)dealloc
{
	if (_xPath)
	{ xmlXPathFreeContext(_xPath); }
	if (_xmlDoc)
	{ xmlFreeDoc(_xmlDoc); }
}

- (void)touch
{ _dirty = YES; }

- (BOOL)valid
{ return _xmlDoc != nil; }

- (xmlDocPtr)xmlDoc
{ return _xmlDoc; }

- (NSInteger)dataVersion
{
	NSString *version = [self valueAtPath:@"/@version"];
	if (version)
	{ return [version integerValue]; }
	return 1;
}

- (NSString*)valueAtPath:(const NSString*)xpath
{
	NSString *found = nil;
	
	xmlXPathObjectPtr result = xmlXPathEvalExpression(toXmlStr(xpath), _xPath);
	if (result)
	{
		if (!xmlXPathNodeSetIsEmpty(result->nodesetval))
		{
			xmlChar *value = xmlNodeListGetString(_xmlDoc, result->nodesetval->nodeTab[0]->xmlChildrenNode, 1);
			found = toNSString(value);
			xmlFree(value);
		}
		
		xmlXPathFreeObject(result);
	}
	
	return found;
}

- (UIImage*)imageAtPath:(const NSString*)xpath
{
	NSString *raw = [self valueAtPath:xpath];
	if (raw)
	{
		return [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:raw options:NSDataBase64DecodingIgnoreUnknownCharacters]];
	}
	return nil;
}

- (UIImage*)imageWithSize:(CGSize)size atPath:(const NSString*)xpath
{
	return nil;
}

- (BOOL)setValue:(NSString*)value atPath:(const NSString*)xpath
{
	BOOL found = NO;
	
	xmlXPathObjectPtr result = xmlXPathEvalExpression(toXmlStr(xpath), _xPath);
	if (!xmlXPathNodeSetIsEmpty(result->nodesetval))
	{
		xmlNodeSetContent(result->nodesetval->nodeTab[0], toXmlStr(value));
		found = YES;
		[self touch];
	}
	
	xmlXPathFreeObject(result);
	return found;
}

- (BOOL)setImage:(UIImage*)value atPath:(const NSString*)xpath
{
	NSData *data = UIImageJPEGRepresentation(value, 0.85f);
	return [self setValue:[data base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength | NSDataBase64EncodingEndLineWithLineFeed] atPath:xpath];
}

- (void)saveToFile:(NSString *)filepath
{
	xmlSaveFile([filepath UTF8String], _xmlDoc);
	_dirty = NO;
}

- (NSString*)saveToString
{
	/*
	xmlOutputBufferPtr ob = xmlAllocOutputBuffer(NULL);
	xmlSaveFileTo(ob, _xmlDoc, NULL);

	const xmlChar *result = xmlOutputBufferGetContent(ob);
	NSString *output = [NSString stringWithUTF8String:(const char *)result];
	
	xmlFree((void*)result);
	xmlOutputBufferClose(ob);
	
	return output;
	 */
	
	xmlChar *s;
	int size;
	
	xmlDocDumpMemory(_xmlDoc, &s, &size);
	if (s)
	{
		NSString *result = [NSString stringWithUTF8String:(const char *)s];
		xmlFree(s);
		return result;
	}
	return nil;
}

@end

NSString *sanitizeContentString(NSString *inStr)
{
	NSMutableString *outStr = [NSMutableString stringWithCapacity:[inStr length] * 2];
	
	unichar lastc = 0;
	for (int i = 0; i < [inStr length]; ++i)
	{
		unichar c = [inStr characterAtIndex:i];
		switch (c)
		{
				//			case '<':
				//				[outStr appendString:@"&lt;"];
				//				break;
				//			case '>':
				//				[outStr appendString:@"&gt;"];
				//				break;
			case '"':
				if (lastc != '\\')
					[outStr appendString:@"\\\""];
				else
					[outStr appendString:@"\""];
				break;
				//			case '&':
				//				if (((inStr.length < i+5) || [[inStr substringWithRange:NSMakeRange(i, 5)] compare:@"&amp;"] != NSOrderedSame) &&
				//					((inStr.length < i+4) ||
				//					([[inStr substringWithRange:NSMakeRange(i, 4)] compare:@"&lt;"] != NSOrderedSame &&
				//					[[inStr substringWithRange:NSMakeRange(i, 4)] compare:@"&gt;"] != NSOrderedSame)))
				//				{
				//					[outStr appendString:@"&amp;"];
				//				}
				//				else
				//				{
				//					[outStr appendString:@"&"];
				//				}
				//				break;
			case '\n':
				[outStr appendString:@"\\n"];
				break;
			case '\r':
				break;
			default:
				[outStr appendString:[NSString stringWithCharacters:&c length:1]];
				break;
		}
		lastc = c;
	}
	return [NSString stringWithString:outStr];
}

NSString *getValueFromNode(xmlNodePtr node)
{
	const char *prop;
	if (node->children) prop = (const char *)node->children->content;
	else return @"";
	if (prop)
	{
		NSString *propValue = [NSString stringWithUTF8String:prop];
		propValue = [propValue stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
		propValue = [propValue stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
		propValue = [propValue stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\\\""];
		propValue = sanitizeContentString(propValue);
		return propValue;
	}
	return @"";
}

const xmlChar *toXmlStr(const NSString *nsStr)
{
	return (const xmlChar*)[nsStr UTF8String];
}

NSString *toNSString(const xmlChar *xmlStr)
{
	return [NSString stringWithUTF8String:(const char *)xmlStr];
}

