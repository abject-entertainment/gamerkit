//
//  Map.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/31/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "Map.h"
#import "DataManager.h"
#import "Base64.h"
#import "MapsController.h"
#import "Token.h"

#include <libxml/parser.h>
#include <libxml/tree.h>

#define CURRENT_VERSION ((NSUInteger)2)

@implementation Map

- (void)createMiniImage
{
	_miniImage = nil;
	
	UIImage *img = self.image;
	if (img)
	{
		UIGraphicsBeginImageContext(CGSizeMake(miniSize, miniSize));
		[img drawInRect:CGRectMake(0,0,miniSize,miniSize)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		_miniImage = img;
		UIGraphicsEndImageContext();
	}
}

- (void)setImage:(UIImage*)newImage { _image = newImage; [self createMiniImage]; }

- (void)unload
{
	if (bFullyLoaded)
	{
		_image = nil;
		bFullyLoaded = NO;
	}
}

- (void)fullyLoad
{
	if (!bFullyLoaded && self.path)
	{
		Map *_self = [self initWithFileAtPath:self.path fully:YES];
		_self->bFullyLoaded = YES;
	}
}

- (id)init
{
	self = [super init];
	if (self)
	{
		self.image = nil;
		self.name = nil;
		bFullyLoaded = NO;
	}
	return self;
}

- (id)initWithFileAtPath:(NSString*)inPath fully:(BOOL)fullLoad
{
	self = [self init];
	_path = inPath;
	
	NSStringEncoding enc = NSUTF8StringEncoding;
	NSString *xml = [NSString stringWithContentsOfFile:self.path usedEncoding:&enc error:nil];
	if (xml == nil) return nil;
	
	xmlDocPtr doc = xmlParseDoc((const xmlChar*)[xml UTF8String]);
	if (doc) 
	{
		xmlNodePtr curElem = xmlDocGetRootElement(doc);
		
		if (curElem && strcasecmp((const char *)curElem->name, "map") == 0)
		{
			NSUInteger version;
			const char *prop = NULL;
			
			prop = (const char *)xmlGetProp(curElem, (const xmlChar*)"version");
			if (prop) version = (NSUInteger)atoi(prop);
			else version = 0;
			xmlFree((void*)prop);
			
			prop = (const char *)xmlGetProp(curElem, (const xmlChar*)"name");
			if (prop) _name = [NSString stringWithUTF8String:prop];
			xmlFree((void*)prop);
			
			prop = (const char *)xmlGetProp(curElem, (const xmlChar*)"offsetx");
			if (prop) _gridOffset.x = atof(prop);
			xmlFree((void*)prop);

			prop = (const char *)xmlGetProp(curElem, (const xmlChar*)"offsety");
			if (prop) _gridOffset.y = atof(prop);
			xmlFree((void*)prop);

			prop = (const char *)xmlGetProp(curElem, (const xmlChar*)"scale");
			if (prop) _gridScale = atof(prop);
			if (_gridScale <= 0.0f) _gridScale = 1.0f;
			xmlFree((void*)prop);

			if (fullLoad || version < 2)
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
								fprintf(stdout, "Base64 decode: expeded %d bytes, got %lu.\n", cnt, (unsigned long)imgData.length);
							}
						}
					}
				}
			}

			if (version > 1)
			{
				if (curElem->children->next)
				{
					curElem = curElem->children->next;
					if (strcasecmp((const char *)curElem->name, "minimap") == 0)
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
										_miniImage = [[UIImage alloc] initWithData:imgData];
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

- (void)writeToFile
{
	[self fullyLoad];
	if (_path == nil)
	{
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *file = [[[DataManager getDataManager] docsPath] stringByAppendingPathComponent:@"Media/%08x.map"];
		
		do
		{
			_path = [NSString stringWithFormat:file, random()];
		} while ([fm fileExistsAtPath:_path]);
	}

	NSData *imgData = UIImagePNGRepresentation(_image);
	NSUInteger cnt = imgData.length;
	NSString *base64Data = [NSString base64StringFromData:imgData length:cnt];
	cnt = 3 * ((cnt + 2)/3);
	
	NSData *miniData = UIImagePNGRepresentation(_miniImage);
	NSUInteger mcnt = miniData.length;
	NSString *mini64Data = [NSString base64StringFromData:miniData length:mcnt];
	mcnt = 3 * ((mcnt + 2)/3);

	NSString *xml = [NSString stringWithFormat:@"<map version=\"%lu\" name=\"%@\" offsetx=\"%f\" offsety=\"%f\" scale=\"%f\" img-size=\"%lu\">%@<minimap img-size=\%lud\">%@</minimap></map>",
					 (unsigned long)CURRENT_VERSION,
					 _name,
					 _gridOffset.x,
					 _gridOffset.y,
					 _gridScale,
					 (unsigned long)cnt,
					 base64Data,
					 (unsigned long)mcnt,
					 mini64Data];

	[xml writeToFile:_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSData*)dataForSharing
{
	int size = 0;
	NSUInteger version = CURRENT_VERSION;
	
	size += sizeof(NSUInteger); // version
	
	NSData *nameData = [_name dataUsingEncoding:NSUTF8StringEncoding];
	
	size += sizeof(NSUInteger); // length of name
	size += nameData.length; // name
	
	UIImage *img = _image;
	NSData *imgData = img?UIImageJPEGRepresentation(img, 0.85f):nil;
	
	size += sizeof(NSUInteger); // length of image
	size += imgData?imgData.length:0; // image
	
	size += sizeof(CGPoint); // gridOffset
	size += sizeof(CGFloat); // gridScale
	
	NSMutableData *data = [NSMutableData dataWithCapacity:size];
	
	[data appendBytes:&version length:sizeof(NSUInteger)];
	NSUInteger len = nameData.length;
	[data appendBytes:&len length:sizeof(NSUInteger)];
	[data appendData:nameData];
	len = imgData?imgData.length:0;
	[data appendBytes:&len length:sizeof(NSUInteger)];
	if (len) [data appendData:imgData];
	[data appendBytes:&_gridOffset length:sizeof(CGPoint)];
	[data appendBytes:&_gridScale length:sizeof(CGFloat)];
	
	[self createMiniImage];
	return data;
}

+ (NSString*)contentType
{
	return @"_x-GTMapShare._tcp.";
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
		_name = [[NSString alloc] initWithData:[data subdataWithRange:range] encoding:NSUTF8StringEncoding];
		
		range.location += len;
		range.length = sizeof(NSUInteger);
		[data getBytes:&len range:range];
		
		range.location += sizeof(NSUInteger);
		range.length = len;
		_image = [UIImage imageWithData:[data subdataWithRange:range]];
		
		range.location += len;
		range.length = sizeof(CGPoint);
		[data getBytes:&_gridOffset range:range];
		
		range.location += sizeof(CGPoint);
		range.length = sizeof(CGFloat);
		[data getBytes:&_gridScale range:range];
		
		[self createMiniImage];
		
		[[[DataManager getDataManager] mapsData] addMap:self];
		[self writeToFile];
	}
	return self;
}

@end
