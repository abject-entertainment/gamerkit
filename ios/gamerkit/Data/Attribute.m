//
//  Attribute.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 3/10/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "Attribute.h"
#import "OptionSet.h"
#import "DataSet.h"
#import "Ruleset.h"

#include <string.h>
#include <libxml/parser.h>
#include <libxml/tree.h>


@implementation Attribute

- (id)initWithXmlNode:(void*)node andUid:(int)inUid forRuleset:(Ruleset*)rules {
	if (self = [super init]) {
		_uid = inUid;
		
		xmlNodePtr element = (xmlNodePtr)node;
		
		if (element)
		{
			const char *attr = NULL;
			
			attr = (const char *)xmlGetProp(element, (const xmlChar*)"name");
			if (attr) _name = [NSString stringWithUTF8String:attr];
			xmlFree((void*)attr);
			attr = (const char *)xmlGetProp(element, (const xmlChar*)"display-name");
			if (attr) displayName = [NSString stringWithUTF8String:attr];
			xmlFree((void*)attr);
			//attr = (const char *)xmlGetProp(element, (const xmlChar*)"id");
			//if (attr) uid = atoi(attr);
			attr = (const char *)xmlGetProp(element, (const xmlChar*)"value-type");
			if (attr)
			{
				const char *tmp_attr = attr;
				if (strncasecmp(attr, "list(", 5) == 0)
				{
					_isList = YES;
					attr += 5;
				}
				else 
				{
					_isList = NO;
				}

				if (strncasecmp(attr, "int", 3) == 0) _valueType = AVT_Integer;
				else if (strncasecmp(attr, "+int", 4) == 0) _valueType = AVT_Integer; // TODO: with explicity +/- formatting
				else if (strncasecmp(attr, "string", 6) == 0) _valueType = AVT_String;
				else if (strncasecmp(attr, "option", 6) == 0) _valueType = AVT_Option;
				else if (strncasecmp(attr, "option...", 9) == 0) _valueType = AVT_Option; // TODO: not restricted to explicit options
				else if (strncasecmp(attr, "bool", 4) == 0) _valueType = AVT_YesNo;
				else
				{
					_valueType = AVT_DataSet;
				}
				
				if (_valueType == AVT_Option)
				{
					options = [[OptionSet alloc] initWithXmlNode:element->children];
				}
				else if (_valueType == AVT_DataSet)
				{
					unsigned long len = strlen(attr);
					if (_isList) --len; // remove trailing ")"
					
					_dataType = [rules dataSetForName:[[NSString alloc] initWithBytes:attr length:len encoding:NSUTF8StringEncoding]];
				}
				else 
				{
					options = nil;
				}
				xmlFree((void*)tmp_attr);
			}
		}
	}
	return self;
}

@end
