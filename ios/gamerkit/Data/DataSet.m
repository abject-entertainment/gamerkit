//
//  DataSet.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 5/22/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "DataSet.h"
#import "Ruleset.h"
#import "Attribute.h"

#include <libxml/parser.h>
#include <libxml/tree.h>

@implementation DataSet
@synthesize name, elements;

- (id)initWithXmlNode:(void*)node forRuleset:(Ruleset*)rules
{
	self = [self init];
	if (self && node)
	{
		xmlNodePtr element = (xmlNodePtr)node;

		const char *attr = NULL;
		
		attr = (const char *)xmlGetProp(element, (const xmlChar*)"name");
		if (attr) name = [NSString stringWithUTF8String:attr];
		xmlFree((void*)attr);
			
		elements = [NSMutableArray arrayWithCapacity:3];
		
		xmlNodePtr child = element->children;
		while (child)
		{
			if (strcasecmp((const char *)child->name, "data") == 0)
			{
				Attribute *attribObj = [rules loadAttribute:child withUid:-1];
				if (attribObj)
				{
					[elements addObject:attribObj];
				}
			}
			child = child->next;
		}
	}
	return self;
}

@end
