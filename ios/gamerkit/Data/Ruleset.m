//
//  Ruleset.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 2/19/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#include <string.h>
#include <libxml/parser.h>
#include <libxml/tree.h>

#import "Ruleset.h"
#import "Attribute.h"
#import "DataSet.h"
#import "ContentManager.h"
#import "CharacterDefinition.h"
#import "CharacterLayout.h"
#import "Import.h"
#import "OptionSet.h"

#include "XMLDataContent.h"

static const NSString *kXPath_Ruleset_Name = @"/ruleset/@name";
static const NSString *kXPath_Ruleset_DisplayName = @"/ruleset/@display-name";

@interface XMLDataContent (friend_Ruleset)
- (xmlDocPtr)xmlDoc;
@end

@interface Ruleset ()
{
	NSMutableDictionary *_dataSets;
	NSMutableDictionary *_attributesByName;
	NSMutableDictionary *_attributesById;
	
	NSMutableArray *_supplementFiles;
	
	NSMutableDictionary *_characterTypes;
	NSMutableDictionary *_characterSheets;
}
@end

@implementation Ruleset

- (id)init
{
	self = [super init];
	
	if (self)
	{
		_dataSets = nil;
		_attributesByName = nil;
		_attributesById = nil;
		_characterTypes = nil;
		_characterSheets = nil;
		
		_supplementFiles = [[NSMutableArray alloc] init];
		_characters = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithName:(NSString*)inName andDisplayName:(NSString*)inDisplayName
{
	self = [self init];
	if (self)
	{
		_name = inName;
		_displayName = inDisplayName;
		_characterTypes = [NSMutableDictionary dictionary];
		_characterSheets = [NSMutableDictionary dictionary];
	}
	return self;
}

- (instancetype)initWithFile:(NSString *)fileName
{
	self = [super initWithFile:fileName];
	if (self)
	{
		[self load];
	}
	return self;
}

- (NSString*)contentPath
{
	return self.name;
}

- (void)loadSupplementFromFile:(NSString*)path
{
#warning <<AE>> Supplemental rules not implemented;
}

- (bool)load {
	[self loadData];
	
	_name = [self.data valueAtPath:kXPath_Ruleset_Name];
	_displayName = [self.data valueAtPath:kXPath_Ruleset_DisplayName];
	
	xmlDocPtr doc = [self.data xmlDoc];
	if (doc) 
	{
		xmlNodePtr curElem = xmlDocGetRootElement(doc);
	
		if (curElem == NULL || strcasecmp((const char *)curElem->name, "ruleset") != 0)
		{
			return false;
		}

		curElem = curElem->children;
		while (curElem)
		{
			const xmlChar *elemName = curElem->name;
			if (strcasecmp((const char *)elemName, "datasets") == 0)
			{
				if (_dataSets == nil)
					_dataSets = [[NSMutableDictionary alloc] init];

				xmlNodePtr dataSet = curElem->children;
				while (dataSet)
				{
					elemName = dataSet->name;
					if (strcasecmp((const char *)elemName, "dataset") == 0)
					{
						// construct a data set object and read in data elements
						DataSet *dataSetObj = [self loadDataSet:dataSet];
						if (dataSetObj)
							[_dataSets setObject:dataSetObj forKey:dataSetObj.name];
					}
					dataSet = dataSet->next;
				}
			}
			else if (strcasecmp((const char *)elemName, "attributes") == 0)
			{
				if (_attributesByName == nil)
					_attributesByName = [[NSMutableDictionary alloc] init];
				if (_attributesById == nil)
					_attributesById = [[NSMutableDictionary alloc] init];

				int curUid = 0;
				xmlNodePtr attrib = curElem->children;
				while (attrib)
				{
					elemName = attrib->name;
					if (strcasecmp((const char *)elemName, "attribute") == 0)
					{
						// construct an attribute object and read in properties
						Attribute *attribObj = [self loadAttribute:attrib withUid:curUid];
						if (attribObj)
						{
							[_attributesByName setObject:attribObj forKey:[attribObj name]];
							[_attributesById setObject:attribObj forKey:[NSNumber numberWithInt:curUid]];
							++curUid;
						}
					}
					attrib = attrib->next;
				}
			}
			else if (strcasecmp((const char *)elemName, "character-types") == 0)
			{
				if (_characterTypes == nil)
					_characterTypes = [[NSMutableDictionary alloc] init];

				xmlNodePtr charType = curElem->children;
				while (charType)
				{
					elemName = charType->name;
					if (strcasecmp((const char *)elemName, "character-type") == 0)
					{
						// construct a character definition object and read in attributes
						CharacterDefinition *charTypeObj = [self loadCharacterDefinition:charType];
						if (charTypeObj)
							[_characterTypes setObject:charTypeObj forKey:[charTypeObj name]];
					}
					charType = charType->next;
				}
			}
			else if (strcasecmp((const char *)elemName, "imports") == 0)
			{
				if (_imports == nil)
					_imports = [[NSMutableDictionary alloc] init];
				/* TODO: fix imports (race condition?)
				xmlNodePtr importElement = curElem->children;
				while (importElement)
				{
					elemName = importElement->name;
					if (strcasecmp((const char *)elemName, "import") == 0)
					{
						Import *newImport = [[Import alloc] initWithXmlNode:importElement andRuleset:self];
						if (newImport)
						{
							NSMutableArray *importList = [_imports objectForKey:newImport.contentType];
							if (importList == nil)
							{
								importList = [NSMutableArray arrayWithCapacity:1];
								[_imports setObject:importList forKey:newImport.contentType];
							}
						
							[importList addObject:newImport];
						}
					}
					importElement = importElement->next;
				}
				*/
			}
			curElem = curElem->next;
		}
		
		xmlFreeDoc(doc);
	}
	
	return true;
}

- (void)unload {
	_dataSets = nil;
	_attributesByName = nil;
	_attributesById = nil;
	_characterTypes = nil;
	_characterSheets = nil;
	_characters = nil;
}

// root type load functions
- (DataSet *)loadDataSet:(xmlNodePtr)element {
	DataSet *dataSet = [[DataSet alloc] initWithXmlNode:element forRuleset:self];
	return dataSet;
}

- (Attribute *)loadAttribute:(xmlNodePtr)element withUid:(int)inUid {
	Attribute *attribute = [[Attribute alloc] initWithXmlNode:element andUid:inUid forRuleset:self];
	return attribute;
}

- (CharacterDefinition *)loadCharacterDefinition:(xmlNodePtr)element {
	CharacterDefinition *def = [[CharacterDefinition alloc] initWithXmlNode:element andRuleset:self];
	return def;
}

- (EncounterElement *)loadEncounterElement:(xmlNodePtr)element {
	return NULL;
}

// sub-type load functions
- (AttributeRef)loadAttributeRef:(xmlNodePtr)element {
	if (element && strcasecmp((const char *)element->name, "attribute") == 0)
	{
		const char *aname = (const char *)xmlGetProp(element, (const xmlChar*)"name");
		if (aname)
		{
			AttributeRef ref = [self attributeRefForName:[NSString stringWithUTF8String:aname]];
			xmlFree((void*)aname);
			return ref;
		}
	}
	return -1;
}

- (OptionSet *)loadOptionSet:(xmlNodePtr)firstElement {
	return NULL;
}

- (AttributeRef)attributeRefForName:(NSString*)attrName {
	Attribute *attr = [self attributeForName:attrName];
	if (attr)
		return attr.uid;
	return -1;
}

- (Attribute*)attributeForName:(NSString*)inName {
	if (_attributesByName)
	{
		return [_attributesByName objectForKey:inName];
	}
	return nil;
}

- (Attribute*)attributeForRef:(AttributeRef)ref {
	if (_attributesById)
	{
		return [_attributesById objectForKey:[NSNumber numberWithInt:ref]];
	}
	return nil;
}

- (CharacterDefinition*)characterDefinitionForName:(NSString*)inName {
	if (_characterTypes)
	{
		return [_characterTypes objectForKey:inName];
	}
	return nil;
}

- (void)addCharacter:(Character*)c
{
	[_characters addObject:c];
}

- (void)deleteCharacter:(Character*)c
{
	NSUInteger idx = [_characters indexOfObject:c];
	if (idx != NSNotFound && idx < _characters.count)
		[_characters removeObjectAtIndex:idx];
}

- (DataSet*)dataSetForName:(NSString *)inName
{
	if (_dataSets && inName)
	{
		return [_dataSets objectForKey:inName];
	}
	return nil;
}

@end
