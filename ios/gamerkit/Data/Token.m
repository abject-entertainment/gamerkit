//
//  Token.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/24/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "Token.h"
#import "DataManager.h"
#import "TokenListController.h"
#import "Base64.h"

#include <libxml/parser.h>
#include <libxml/tree.h>

#define CURRENT_VERSION ((NSUInteger)3)

@implementation Token
@synthesize name, miniImage, file;

- (void)createMiniImage
{
	miniImage = nil;
	
	UIImage *img = _image;
	if (img)
	{
		UIGraphicsBeginImageContext(CGSizeMake(miniSize, miniSize));
		[img drawInRect:CGRectMake(0,0,miniSize,miniSize)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		miniImage = img;
		UIGraphicsEndImageContext();
	}
}

- (void)setImage:(UIImage *)newImage
{ _image = newImage; [self createMiniImage]; }

- (void)unload
{
	if (bFullyLoaded)
	{
		[self writeToFile];
		_image = nil;
	}
	bFullyLoaded = NO;
}

- (void)fullyLoad
{
	if (file && !bFullyLoaded)
	{
		[self initWithFileAtPath:file fully:YES]->bFullyLoaded = YES;
	}
}

- (id)initWithFileAtPath:(NSString *)path fully:(BOOL)fullLoad
{
	self = [self init];
	if (!self) return self;
	
//	const char *testStr = "Man";
//	fprintf(stdout, "Encoding string: %s\n", testStr);
//	NSData *testData = [NSData dataWithBytes:testStr length:3];
//	NSString *encoded = [NSString base64StringFromData:testData length:3];
//	fprintf(stdout, "Encoded data: %s\n", [encoded UTF8String]);
//	testData = [NSData base64DataFromString:[encoded UTF8String]];
//	fprintf(stdout, "Decoded string: %s\n", (char *)[testData bytes]);
	
	file = path;
	NSStringEncoding enc = NSUTF8StringEncoding;
	NSString *xml = [NSString stringWithContentsOfFile:path usedEncoding:&enc error:nil];
	if (xml == nil) return nil;
	
	xmlDocPtr doc = xmlParseDoc((const xmlChar*)[xml UTF8String]);
	if (doc) 
	{
		xmlNodePtr curElem = xmlDocGetRootElement(doc);
		
		if (curElem && strcasecmp((const char *)curElem->name, "token") == 0)
		{
			NSUInteger version;
			const char *prop = NULL;
			
			prop = (const char *)xmlGetProp(curElem, (const xmlChar*)"version");
			if (prop) version = (NSUInteger)atoi(prop);
			else version = 0;
			xmlFree((void*)prop);

			prop = (const char *)xmlGetProp(curElem, (const xmlChar*)"name");
			if (prop)
            {
                name = [NSString stringWithUTF8String:prop];
            }
			xmlFree((void*)prop);

			if (fullLoad || version <= 1)
			{
				prop = (const char *)xmlGetProp(curElem, (const xmlChar*)"img-size");
				if (prop)
				{
					int cnt = atoi(prop);
					xmlFree((void*)prop);
					
					if (cnt > 0)
					{
						// first child is text node
						prop = (const char *)curElem->children->content;
						
						if (prop && cnt)
						{
							NSData *imgData = [NSData base64DataFromString:prop];
							
							if (imgData.length == cnt)
							{
								_image = [[UIImage alloc] initWithData:imgData];
							}
							else {
								fprintf(stdout, "Base64 decode: expected %d bytes, got %lu.\n", cnt, (unsigned long)imgData.length);
							}
						}
					}
				}
			}
			
			if (version >= CURRENT_VERSION)
			{
				if (curElem->children->next)
				{
					curElem = curElem->children->next;
					if (strcasecmp((const char *)curElem->name, "minitoken") == 0)
					{
						prop = (const char *)xmlGetProp(curElem, (const xmlChar*)"img-size");
						if (prop)
						{
							int cnt = atoi(prop);
							xmlFree((void*)prop);
							
							if (cnt > 0)
							{
								// first child is text node
								prop = (const char *)curElem->children->content;
								
								if (prop && cnt)
								{
									NSData *imgData = [NSData base64DataFromString:prop];
									
									if (imgData.length == cnt)
									{
										miniImage = [[UIImage alloc] initWithData:imgData];
									}
									else
									{
										fprintf(stdout, "Base64 decode: expected %d bytes, got %lu.\n", cnt, (unsigned long)imgData.length);
									}
								}
							}
						}
					}
				}
			}
			else
			{
				[self createMiniImage];
				[self writeToFile];
				if (!fullLoad)
				{
					[self unload];
				}
			}
		}
		xmlFreeDoc(doc);
	}
	return self;
}

- (id)initWithImage:(UIImage*)img andName:(NSString*)n
{
	self = [self init];
	if (self)
	{
		name = n;
		_image = img;
		[self createMiniImage];
		bFullyLoaded = YES;
	}
	return self;
}

- (void)writeToFile
{
	[self fullyLoad];
	if (file == nil)
	{
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *path = [[[DataManager getDataManager] docsPath] stringByAppendingPathComponent:@"Media/%08x.token"];
		
		do
		{
			file = [NSString stringWithFormat:path, random()];
		} while ([fm fileExistsAtPath:file]);
	}
	
	NSData *imgData = UIImageJPEGRepresentation(_image,0.85f);
	NSUInteger cnt = imgData.length;
	NSString *base64Data = [NSString base64StringFromData:imgData length:cnt];
	cnt = 3 * ((cnt + 2)/3);
	
	NSData *miniData = UIImagePNGRepresentation(miniImage);
	NSUInteger mcnt = miniData.length;
	NSString *mini64Data = [NSString base64StringFromData:miniData length:mcnt];
	mcnt = 3 * ((mcnt + 2)/3);

	NSMutableString *xml = [NSMutableString stringWithCapacity:cnt];
	[xml appendFormat:@"<token version=\"%lu\" name=\"%@\" img-size=\"%lu\">%@<minitoken img-size=\"%lu\">%@</minitoken></token>", 
			(unsigned long)CURRENT_VERSION,
			name, 
			(unsigned long)cnt, 
			base64Data,
			(unsigned long)cnt,
			mini64Data];
	[xml writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSData*)dataForSharing
{
	int size = 0;
	NSUInteger version = CURRENT_VERSION;
	
	size += sizeof(NSUInteger); // version
	
	NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
	
	size += sizeof(NSUInteger); // length of name
	size += nameData.length; // name
	
	NSData *imgData = UIImageJPEGRepresentation(_image,0.85f);
	
	size += sizeof(NSUInteger); // length of image
	size += imgData.length; // image
	
	
	NSMutableData *data = [NSMutableData dataWithCapacity:size];
	
	[data appendBytes:&version length:sizeof(NSUInteger)];
	NSUInteger len = nameData.length;
	[data appendBytes:&len length:sizeof(NSUInteger)];
	[data appendData:nameData];
	len = imgData.length;
	[data appendBytes:&len length:sizeof(NSUInteger)];
	[data appendData:imgData];
	
	return data;
}

+ (NSString*)contentType
{
	return @"_x-GTTokShare._tcp.";
}

- (id)initWithSharedData:(NSData*)data
{
	self = [self init];
	if (self)
	{
		NSRange range;
		NSUInteger len;
		NSUInteger version;
		
		range.location = 0;
		range.length = sizeof(NSUInteger);
		[data getBytes:&version range:range];
		
		range.location += sizeof(NSUInteger);
		range.length = sizeof(NSUInteger);
		[data getBytes:&len range:range];

		range.location += sizeof(NSUInteger);
		range.length = len;
		name = [[NSString alloc] initWithData:[data subdataWithRange:range] encoding:NSUTF8StringEncoding];
		
		range.location += len;
		range.length = sizeof(NSUInteger);
		[data getBytes:&len range:range];
		
		range.location += sizeof(NSUInteger);
		range.length = len;
		_image = [UIImage imageWithData:[data subdataWithRange:range]];
		
		[self createMiniImage];
		
		[[[DataManager getDataManager] tokenData] addToken:self];
		[self writeToFile];
		
		bFullyLoaded = YES;
	}
	return self;
}

@end
