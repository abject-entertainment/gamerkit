//
//  CharacterDefinition.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 5/22/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "CharacterDefinition.h"
#import "Attribute.h"
#import "Ruleset.h"
#import "DataManager.h"
#import "Character.h"

#include <string.h>
#include <libxml/parser.h>
#include <libxml/tree.h>

@implementation CharacterDefinition

- (id)initWithXmlNode:(void*)node andRuleset:(Ruleset*)inRules
{
	self = [super init];
	if (self == nil) return nil;
	
	rules = inRules;
	
	xmlNodePtr element = (xmlNodePtr)node;
	
	if (element)
	{
		const char *attr = NULL;
	
		attr = (const char *)xmlGetProp(element, (const xmlChar*)"name");
		if (attr) _name = [NSString stringWithUTF8String:attr];
		xmlFree((void*)attr);
		attr = (const char *)xmlGetProp(element, (const xmlChar*)"display-name");
		if (attr) _displayName = [NSString stringWithUTF8String:attr];
		xmlFree((void*)attr);
		
		xmlNodePtr attrib = element->children;
		NSMutableArray *attribs = [[NSMutableArray alloc] init];
		
		while (attrib)
		{
			AttributeRef aref = [rules loadAttributeRef:attrib];
			if (aref != -1)
				[attribs addObject:[NSNumber numberWithInt:aref]];
			attrib = attrib->next;
		}
		
		_attributeSet = [NSArray arrayWithArray:attribs];
	}
	
	_sheets = [NSMutableDictionary dictionaryWithCapacity:2];
	return self;
}

- (void)addSheet:(CharacterLayout*)sheet {
	if (sheet)
	{
		[_sheets setObject:sheet forKey:sheet.name];
	}
}

- (Attribute*)attributeForName:(NSString*)inName {
	if (rules)
	{
		Attribute* aref = [rules attributeForName:inName];
		if ([_attributeSet containsObject:[NSNumber numberWithInt:aref.uid]])
			return aref;
	}
	return nil;
}

@end
