//
//  Import.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 11/17/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "Import.h"
#include <libxml/parser.h>
#include <libxml/tree.h>

#import "Ruleset.h"

@implementation Import

- (id)initWithXmlNode:(void*)node andRuleset:(Ruleset*)inRules
{
	if ((self = [super init]) == nil) return nil;
	
	xmlNodePtr importElement = (xmlNodePtr)node;
	const char *attr;
	
	attr = (const char *)xmlGetProp(importElement, (const xmlChar*)"type");
	if (attr)
	{
		NSString *contentTypeName = [NSString stringWithUTF8String:attr];
		
		_system = inRules.name;
		_contentType = contentTypeName;
		
		xmlFree((void*)attr);
		attr = (const char *)xmlGetProp(importElement, (const xmlChar*)"subtype");
		if (attr) _subtype = [NSString stringWithUTF8String:attr];
		xmlFree((void*)attr);
		attr = (const char *)xmlGetProp(importElement, (const xmlChar*)"display-name");
		if (attr) _displayName = [NSString stringWithUTF8String:attr];
		xmlFree((void*)attr);
		attr = (const char *)xmlGetProp(importElement, (const xmlChar*)"href");
		if (attr) _href = [NSString stringWithUTF8String:attr];
		xmlFree((void*)attr);
		attr = (const char *)xmlGetProp(importElement, (const xmlChar*)"transform");
		if (attr) _transformFile = [NSString stringWithUTF8String:attr];
		xmlFree((void*)attr);
		
		xmlNodePtr child = importElement->children;
		while (child)
		{
			if (strcasecmp("intro", (const char *)child->name) == 0)
			{
				_intro = [NSString stringWithUTF8String:(const char *)child->children->content];
			}
			else if (strcasecmp("instructions", (const char *)child->name) == 0)
			{
				Class regexClass = NSClassFromString(@"NSRegularExpression");
				if (regexClass == nil)
				{
					return nil;
				}
				
				_transformInstructions = [NSMutableArray arrayWithCapacity:10];
				
				xmlNodePtr instruct = child->children;
				while (instruct)
				{
					if (strcasecmp("match", (const char *)instruct->name) == 0)
					{
						ImportInstruction *inst = [[ImportInstruction alloc] init];
						attr = (const char *)xmlGetProp(instruct, (const xmlChar*)"attribute");
						if (attr) inst.attribute = [NSString stringWithUTF8String:attr];
						xmlFree((void*)attr);
						attr = (const char *)xmlGetProp(instruct, (const xmlChar*)"children");
						if (attr) inst.children = [[NSString stringWithUTF8String:attr] componentsSeparatedByString:@" "];
						xmlFree((void*)attr);
						
						if (instruct->children->content && *instruct->children->content != 0)
						{
							NSError *err = nil;
							inst.pattern = [regexClass regularExpressionWithPattern:[NSString stringWithUTF8String:(const char*)instruct->children->content]
																					  options:NSRegularExpressionCaseInsensitive
																						error:&err];
							if (err)
							{
								fprintf(stdout, "Creation of pattern failed: %s\n%s\n", instruct->children->content?(const char*)instruct->children->content:"<NULL>", [[err localizedDescription] UTF8String]);
							}
							else
							{
								[_transformInstructions addObject:inst];
							}
						}
					}					
					instruct = instruct->next;
				}
			}
			child = child->next;
		}
	}
	
	return self;
}

@end

@implementation ImportInstruction

-(id) init
{
	if (self = [super init])
	{
		_attribute = nil;
		_children = nil;
		_pattern = nil;
	}
	return self;
}

@end