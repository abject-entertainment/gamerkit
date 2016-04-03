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
#import "ContentManager.h"
#import "Character.h"
#import "CharacterLayout.h"

#include <string.h>
#include <libxml/parser.h>
#include <libxml/tree.h>

@interface Ruleset (friend_CharacterDefinition)
- (AttributeRef)loadAttributeRef:(xmlNodePtr)element;
@end

@interface CharacterDefinition ()
{
	NSMutableDictionary *_sheets;
}
@end

@implementation CharacterDefinition

- (id)initWithXmlNode:(void*)node andRuleset:(Ruleset*)inRules
{
	self = [super init];
	if (self == nil) return nil;
	
	_sheets = [NSMutableDictionary new];
	
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
		
		xmlNodePtr child = element->children;
		while (child)
		{
			if (strcmp((const char *)child->name, "attributes") == 0)
			{
				xmlNodePtr attrib = child->children;
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
			else if (strcmp((const char *)child->name, "sheets") == 0)
			{
				xmlNodePtr sheet = child->children;
				
				while (sheet)
				{
					if (strcmp((const char *)sheet->name, "edit") == 0 ||
						strcmp((const char *)sheet->name, "view") == 0 ||
						strcmp((const char *)sheet->name, "print") == 0)
					{
						CharacterLayout *layout = _sheets[[NSString stringWithUTF8String:(const char *)sheet->name]] = [[CharacterLayout alloc] init];
						
						layout.name = [NSString stringWithUTF8String:(const char *)sheet->name];
						
						layout.displayName = [NSString stringWithUTF8String:(const char *)xmlGetProp(sheet, (const xmlChar *)"name")];
						
						layout.file = [NSString stringWithUTF8String:(const char *)xmlGetProp(sheet, (const xmlChar *)"file")];
					}
					sheet = sheet->next;
				}
			}
			child = child->next;
		}
	}
	
	return self;
}

- (CharacterLayout *)printSheet
{
	CharacterLayout *sheet = _sheets[@"print"];
	if (sheet == nil)
	{ return self.viewSheet; }
	return sheet;
}

- (CharacterLayout *)editSheet
{
	return _sheets[@"edit"];
}

- (CharacterLayout *)viewSheet
{
	CharacterLayout *sheet = _sheets[@"view"];
	if (sheet == nil)
	{ return self.editSheet; }
	return sheet;
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
