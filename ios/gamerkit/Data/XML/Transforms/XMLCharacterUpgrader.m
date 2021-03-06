//
//  XMLCharacterUpgrader.m
//  gamerkit
//
//  Created by Benjamin Taggart on 2/24/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "XMLCharacterUpgrader.h"
#import "XMLDataContent.h"

#import <libxml/tree.h>

static const NSInteger kCurrentVersion = 2;

@interface XMLDataContent (friend_XMLCharacterUpgrader)
- (void)touch;
- (xmlDocPtr)xmlDoc;
@end

void upgradeV1toV2(XMLDataContent *data);

@implementation XMLCharacterUpgrader

+ (BOOL)upgradeCharacterData:(XMLDataContent*)data
{
	NSInteger version = [data dataVersion];
	if (version < kCurrentVersion)
	{
		[data touch];
		
		if (version == 1)
		{
			// fixup v1 -> v2
			upgradeV1toV2(data);
		}
		
		xmlSetProp(data.xmlDoc->children, (const xmlChar *)"version", (const xmlChar *)[[[NSNumber numberWithLong:kCurrentVersion] stringValue] UTF8String]);
		
		return YES;
	}
	return NO;
}



void upgradeV1toV2(XMLDataContent *data)
{
	// change all <attribute name="ABC"> to <ABC>
	xmlDocPtr xml = data.xmlDoc;
	
	// doc children points to root node
	xmlNodePtr child = xml->children->children;
	
	NSString *system = [data valueAtPath:@"/@system"];
	
	while (child)
	{
		if (strcasecmp((const char *)child->name, "attribute") == 0)
		{
			xmlAttrPtr attr = child->properties;
			
			while (attr)
			{
				if (strcasecmp((const char *)attr->name, "name") == 0)
				{
					xmlNodeSetName(child, attr->children->content);
					xmlRemoveProp(attr);
					
					if (strcasecmp((const char *)child->name, "Powers") &&
						[system compare:@"GSL40"] == NSOrderedSame)
					{
#warning <<AE>> Remove hyphens from node names in powers for GSL40
					}
					break;
				}
				attr = attr->next;
			}
		}
		child = child->next;
	}
	
	if ([system compare:@"HEX10"] == NSOrderedSame)
	{
#warning <<AE>> Fix up skill specialties to be nested in HEX10
	}
}

@end
