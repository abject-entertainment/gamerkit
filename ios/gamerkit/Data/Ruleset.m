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
#import "DataManager.h"
#import "CharacterDefinition.h"
#import "CharacterLayout.h"
#import "Import.h"
#import "OptionSet.h"

@implementation Ruleset

- (id)init
{
	self = [super init];
	
	if (self)
	{
		dataSets = nil;
		attributesByName = nil;
		attributesById = nil;
		_characterTypes = nil;
		_characterSheets = nil;
		
		supplementFiles = [[NSMutableArray alloc] init];
		_characters = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithName:(NSString*)inName andDisplayName:(NSString*)inDisplayName
{
	self = [self init];
	
	_file = nil;
	_name = inName;
	_displayName = inDisplayName;
	
	return self;
}

- (id)initWithFileAtPath:(NSString*)path {
	self = [self init];
	
	_file = path;

	xmlDocPtr doc = xmlReadFile([_file UTF8String], NULL, 0);
	if (doc) 
	{
		xmlNodePtr curElem = xmlDocGetRootElement(doc);
		
		if (curElem && strcasecmp((const char *)curElem->name, "ruleset") == 0)
		{
			const xmlChar *prop = xmlGetProp(curElem, (const xmlChar*)"name");
			_name = [NSString stringWithUTF8String:(const char *)prop];
			xmlFree((void*)prop);
			prop = xmlGetProp(curElem, (const xmlChar*)"display-name");
			_displayName = [NSString stringWithUTF8String:(const char *)prop];
			xmlFree((void*)prop);
		}
		
		xmlFreeDoc(doc);
	}
	
	[self load];
	
	return self;
}

- (void)loadSupplementFromFile:(NSString*)path
{
	NSString *oldFile = _file;
	_file = path;
	[self load];
	_file = oldFile;
	[supplementFiles addObject:path];
}

- (bool)load {
	xmlDocPtr doc = xmlReadFile([_file UTF8String], NULL, 0);
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
				if (dataSets == nil)
					dataSets = [[NSMutableDictionary alloc] init];

				xmlNodePtr dataSet = curElem->children;
				while (dataSet)
				{
					elemName = dataSet->name;
					if (strcasecmp((const char *)elemName, "dataset") == 0)
					{
						// construct a data set object and read in data elements
						DataSet *dataSetObj = [self loadDataSet:dataSet];
						if (dataSetObj)
							[dataSets setObject:dataSetObj forKey:dataSetObj.name];
					}
					dataSet = dataSet->next;
				}
			}
			else if (strcasecmp((const char *)elemName, "attributes") == 0)
			{
				if (attributesByName == nil)
					attributesByName = [[NSMutableDictionary alloc] init];
				if (attributesById == nil)
					attributesById = [[NSMutableDictionary alloc] init];

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
							[attributesByName setObject:attribObj forKey:[attribObj name]];
							[attributesById setObject:attribObj forKey:[NSNumber numberWithInt:curUid]];
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
			else if (strcasecmp((const char *)elemName, "character-sheets") == 0)
			{
				if (_characterSheets == nil)
					_characterSheets = [[NSMutableDictionary alloc] init];

				NSString *docsPath = [[DataManager getDataManager] docsPath];
				docsPath = [docsPath stringByAppendingPathComponent:@"Sheets"];

				xmlNodePtr charSheet = curElem->children;
				while (charSheet)
				{
					elemName = charSheet->name;
					if (strcasecmp((const char *)elemName, "character-sheet") == 0)
					{
						// construct a character sheet layout object and read in layout data
						CharacterLayout *charSheetObj = [self loadCharacterLayout:charSheet withDocsPath:docsPath];
						if (charSheetObj)
							[_characterSheets setObject:charSheetObj forKey:charSheetObj.name];
					}
					charSheet = charSheet->next;
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
	dataSets = nil;
	attributesByName = nil;
	attributesById = nil;
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

- (CharacterLayout *)loadCharacterLayout:(xmlNode*)element withDocsPath:(NSString*)docsPath {
	const char *attr = NULL;
	CharacterLayout *layout = [[CharacterLayout alloc] init];
	
	attr = (const char *)xmlGetProp(element, (const xmlChar*)"name");
	if (attr) layout.name = [NSString stringWithUTF8String:attr];
	xmlFree((void*)attr);
	attr = (const char *)xmlGetProp(element, (const xmlChar*)"type");
	if (attr) layout.charType = [NSString stringWithUTF8String:attr];
	xmlFree((void*)attr);
	attr = (const char *)xmlGetProp(element, (const xmlChar*)"display-name");
	if (attr) layout.displayName = [NSString stringWithUTF8String:attr];
	xmlFree((void*)attr);
	
	xmlNodePtr child = element->children;
	while (child)
	{
		if (strcasecmp((const char*)child->name, "file") == 0)
		{
			NSString *platform = nil;
			NSString *ref = nil;
			
			attr = (const char *)xmlGetProp(child, (const xmlChar*)"platform");
			if (attr) platform = [NSString stringWithUTF8String:attr];
			xmlFree((void*)attr);
			attr = (const char *)xmlGetProp(child, (const xmlChar*)"ref");
			if (attr) ref = [docsPath stringByAppendingPathComponent:[NSString stringWithUTF8String:attr]];
			xmlFree((void*)attr);
			
			if (platform && ref)
			{
				[layout.file setObject:ref forKey:platform];
			}
		}
		child = child->next;
	}
	
	// check usage
	if (layout.charType)
	{
		BOOL create = NO, edit = NO, track = NO;
		
		attr = (const char *)xmlGetProp(element, (const xmlChar*)"use-for-create");
		if (attr && strcasecmp(attr, "true") == 0) create = YES;
		xmlFree((void*)attr);
		attr = (const char *)xmlGetProp(element, (const xmlChar*)"use-for-edit");
		if (attr && strcasecmp(attr, "true") == 0) edit = YES;
		xmlFree((void*)attr);
		attr = (const char *)xmlGetProp(element, (const xmlChar*)"use-for-track");
		if (attr && strcasecmp(attr, "true") == 0) track = YES;
		xmlFree((void*)attr);

		NSArray *types = [layout.charType componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		for (int i = 0; i < types.count; ++i)
		{
			CharacterDefinition *cd = [_characterTypes objectForKey:[types objectAtIndex:i]];
			if (cd)
			{
				[cd addSheet:layout];
				if (create) cd.createSheet = layout.name;
				if (edit) cd.editSheet = layout.name;
				if (track) cd.trackSheet = layout.name;
			}
		}
	}
	
	return layout;
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
	if (attributesByName)
	{
		return [attributesByName objectForKey:inName];
	}
	return nil;
}

- (Attribute*)attributeForRef:(AttributeRef)ref {
	if (attributesById)
	{
		return [attributesById objectForKey:[NSNumber numberWithInt:ref]];
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

- (void)deleteThisSystemAndItsContent:(BOOL)shouldDeleteContent
{
	DataManager *dm = [DataManager getDataManager];
	
	if (shouldDeleteContent)
	{
		NSFileManager *fm = [NSFileManager defaultManager];
		for (int i = 0; i < _characters.count; ++i)
		{
			[fm removeItemAtPath:[[_characters objectAtIndex:i] file] error:nil];
		}
	}
	else
	{
		Ruleset *unkRules = [dm unknownRuleset];
		for (int i = 0; i < _characters.count; ++i)
		{
			[unkRules addCharacter:[_characters objectAtIndex:i]];
		}
	}
	[self unload];
}

- (DataSet*)dataSetForName:(NSString *)inName
{
	if (dataSets && inName)
	{
		return [dataSets objectForKey:inName];
	}
	return nil;
}

@end
