//
//  Character.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 2/19/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "Character.h"
#import "Import.h"
#import "CharacterDefinition.h"
#import "DataManager.h"
#import "CharacterListController.h"
#import "Attribute.h"
#import "DataSet.h"
#import "Ruleset.h"
#import "Token.h"
#import "Base64.h"

#include <libxml/parser.h>
#include <libxml/tree.h>

NSString *sanitize(NSString *inStr)
{
	NSMutableString *outStr = [NSMutableString stringWithCapacity:[inStr length] * 2];
	
	unichar lastc = 0;
	for (int i = 0; i < [inStr length]; ++i)
	{
		unichar c = [inStr characterAtIndex:i];
		switch (c)
		{
//			case '<':
//				[outStr appendString:@"&lt;"];
//				break;
//			case '>':
//				[outStr appendString:@"&gt;"];
//				break;
			case '"':
				if (lastc != '\\')
					[outStr appendString:@"\\\""];
				else
					[outStr appendString:@"\""];
				break;
//			case '&':
//				if (((inStr.length < i+5) || [[inStr substringWithRange:NSMakeRange(i, 5)] compare:@"&amp;"] != NSOrderedSame) &&
//					((inStr.length < i+4) || 
//					([[inStr substringWithRange:NSMakeRange(i, 4)] compare:@"&lt;"] != NSOrderedSame &&
//					[[inStr substringWithRange:NSMakeRange(i, 4)] compare:@"&gt;"] != NSOrderedSame)))
//				{
//					[outStr appendString:@"&amp;"];
//				}
//				else
//				{
//					[outStr appendString:@"&"];
//				}
//				break;
			case '\n':
				[outStr appendString:@"\\n"];
				break;
			case '\r':
				break;
			default:
				[outStr appendString:[NSString stringWithCharacters:&c length:1]];
				break;
		}
		lastc = c;
	}
	return [NSString stringWithString:outStr];
}

@implementation Character

- (void)createMiniImage
{
	_miniImage = nil;
	
	NSString *tokData = [self getToken];
	if (tokData)
	{
		UIImage *img = [UIImage imageWithData:[NSData base64DataFromString:[tokData UTF8String]]];
		if (img)
		{
			UIGraphicsBeginImageContext(CGSizeMake(miniSize, miniSize));
			[img drawInRect:CGRectMake(0,0,miniSize,miniSize)];
			img = UIGraphicsGetImageFromCurrentImageContext();
			_miniImage = img;
			UIGraphicsEndImageContext();
		}
	}
}

- (void)unload
{
	if (bFullyLoaded)
	{
		if (bFileDirty)
			[self saveToFile];
		
		cachedXml = nil;
		
		[attributeValues removeAllObjects];
		attributeValues = nil;
		
		bFullyLoaded = NO;
	}
}

- (void)fullyLoad
{
	if (!bFullyLoaded && _file)
	{
		[self initWithFileAtPath:_file fully:YES]->bFullyLoaded = YES;
	}
}

- (id)initForSystem:(NSString*)inSystem andType:(NSString*)inType{
	self = [super init];
	if (self) {
		_name = @"New Character";
		_file = nil;
		_system = inSystem;
		_charType = inType;
		bXmlDirty = YES;
		bFileDirty = YES;
		[self XmlString:nil];
		attributeValues = [[NSMutableDictionary alloc] init];
		
		Ruleset *rules = [[DataManager getDataManager] rulesetForName:_system];
		if (rules)
		{
			[rules addCharacter:self];
		}
		
		bFullyLoaded = YES;
	}
	return self;
}

- (id)initWithFileAtPath:(NSString*)path fully:(BOOL)fullLoad
{
	self = [self init];
	
	bXmlDirty = NO;
	bFileDirty = NO;
	
	cachedXml = nil;
	
	_file = path;
	
	NSString *xml = [self XmlString:nil]; // cache the xml
	self = [self initWithXMLString:xml fully:fullLoad];
	
	bFullyLoaded = fullLoad;
	return self;
}

NSString *GetValueFromNode(xmlNodePtr node)
{
	const char *prop;
	if (node->children) prop = (const char *)node->children->content;
	else return @"";
	if (prop)
	{
		NSString *propValue = [NSString stringWithUTF8String:prop];
		propValue = [propValue stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
		propValue = [propValue stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
		propValue = [propValue stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\\\""];
		propValue = sanitize(propValue);
		return propValue;
	}
	return @"";
}

- (id)initWithXMLString:(NSString*)xml fully:(BOOL)fullLoad
{
	cachedXml = xml;

	xmlDocPtr doc = xmlParseDoc((const xmlChar*)[xml UTF8String]);
	if (doc) 
	{
		xmlNodePtr curElem = xmlDocGetRootElement(doc);
		
		if (curElem && strcasecmp((const char *)curElem->name, "character") == 0)
		{
			const char *prop = NULL;
			
			prop = (const char *)xmlGetProp(curElem, (const xmlChar*)"system");
			if (prop) _system = [NSString stringWithUTF8String:prop];
			xmlFree((void*)prop);
			prop = (const char *)xmlGetProp(curElem, (const xmlChar*)"type");
			if (prop) _charType = [NSString stringWithUTF8String:prop];
			xmlFree((void*)prop);
		}
		
		DataManager *dm = [DataManager getDataManager];
		if (dm)
		{
			Ruleset *rules = [dm rulesetForName:_system];
			if (rules)
			{
				CharacterDefinition *chardef = [rules characterDefinitionForName:_charType];
				
				NSMutableDictionary *attribSet = [[NSMutableDictionary alloc] init];
				xmlNodePtr attrib = curElem->children;
				while (attrib)
				{
					if (strcasecmp((const char *)attrib->name, "attribute") == 0)
					{
						const char *prop = NULL;
						
						prop = (const char *)xmlGetProp(attrib, (const xmlChar*)"name");
						if (prop)
						{
							if (strcmp(prop, "Token") == 0)
							{
								xmlFree((void*)prop);
								if (fullLoad || !_miniImage)
								{
									if (attrib->children) prop = (const char *)attrib->children->content;
									else prop = NULL;
									if (prop)
									{
										NSString *propValue = [NSString stringWithUTF8String:prop];
										[attribSet setObject:propValue forKey:@"Token"];
									}
								}
							}
							else if (strcmp(prop, "Name") == 0)
							{
								Attribute *aref = [chardef attributeForName:[NSString stringWithUTF8String:prop]];
								xmlFree((void*)prop);
								if (attrib->children) prop = (const char *)attrib->children->content;
								else prop = NULL;
								if (prop)
								{
									_name = [NSString stringWithUTF8String:prop];
									[attribSet setObject:_name forKey:[NSNumber numberWithInt:aref.uid]];
								}
							}
							else if (fullLoad)
							{
								Attribute *aref = [chardef attributeForName:[NSString stringWithUTF8String:prop]];
								xmlFree((void*)prop);
								if (aref)
								{
									if (aref.isList)
									{
										NSMutableArray *listItems = [NSMutableArray arrayWithCapacity:4];
										xmlNodePtr item = attrib->children;
										while (item)
										{
											if (strcasecmp((const char *)item->name, "item") == 0)
											{
												if(aref.valueType == AVT_DataSet)
												{
													DataSet *innerType = aref.dataType;
													if (innerType && innerType.elements && innerType.elements.count > 0)
													{
														NSMutableArray *structItems = [NSMutableArray arrayWithCapacity:2];
														
														for (int i = 0; i < innerType.elements.count; ++i)
														{
															Attribute *iAttr = [innerType.elements objectAtIndex:i];
															xmlNodePtr innerItem = item->children;
															NSString *innerValue = @"";
															while (innerItem)
															{
																if (strcasecmp((const char *)innerItem->name, [[iAttr name] UTF8String]) == NSOrderedSame)
																{
																	innerValue = GetValueFromNode(innerItem);
																	break;
																}
																innerItem = innerItem->next;
															}
															if (innerValue == nil)
																innerValue = @"";
															[structItems addObject:innerValue];
														}
														
														[listItems addObject:structItems];
													}
												}
												else 
												{
													NSString *value = GetValueFromNode(item);
													if (value)
														[listItems addObject:value];
												}

											}
											item = item->next;
										}
										[attribSet setObject:listItems forKey:[NSNumber numberWithInt:aref.uid]];
									}
									else
									{
										if(aref.valueType == AVT_DataSet)
										{
											DataSet *innerType = aref.dataType;
											if (innerType && innerType.elements && innerType.elements.count > 0)
											{
												NSMutableArray *structItems = [NSMutableArray arrayWithCapacity:2];
												
												for (int i = 0; i < innerType.elements.count; ++i)
												{
													Attribute *iAttr = [innerType.elements objectAtIndex:i];
													xmlNodePtr innerItem = attrib->children;
													NSString *innerValue = @"";
													while (innerItem)
													{
														if (strcasecmp((const char *)innerItem->name, [[iAttr name] UTF8String]) == NSOrderedSame)
														{
															innerValue = GetValueFromNode(innerItem);
															break;
														}
														innerItem = innerItem->next;
													}
													[structItems addObject:innerValue];
												}
												
												[attribSet setObject:structItems forKey:[NSNumber numberWithInt:aref.uid]];
											}
										}
										else 
										{
											NSString *value = GetValueFromNode(attrib);
											if (value)
												[attribSet setObject:value forKey:[NSNumber numberWithInt:aref.uid]];
										}
									}
								}
							}
							else {
								xmlFree((void*)prop);
							}

						}
					}
					attrib = attrib->next;
				}
				
				if (attributeValues)
				{
					[attributeValues removeAllObjects];
				}
				attributeValues = attribSet;

				[self createMiniImage];
				if (!fullLoad)
					[self unload];
			}
		}
		
		xmlFreeDoc(doc);
	}
	fprintf(stdout, "Character %s loaded for system %s\n", [_name UTF8String], [_system UTF8String]);

	bXmlDirty = YES;
//	[self XmlString:nil];
	
	if (_file == nil && fullLoad)
	{
		bFileDirty = YES;
		[self saveToFile];
	}
	
	bFullyLoaded = fullLoad;
	
	return self;
}

- (CharacterLayout *) createSheet {
	DataManager *dm = [DataManager getDataManager];
	if (dm)
	{
		Ruleset *rules = [dm.systems objectForKey:_system];
		if (rules)
		{
			CharacterDefinition *cd = [rules.characterTypes objectForKey:_charType];
			if (cd)
			{
				if (cd.createSheet)
					return [rules.characterSheets objectForKey:cd.createSheet];
				else if (cd.editSheet)
					return [rules.characterSheets objectForKey:cd.editSheet];
				else if (cd.trackSheet)
					return [rules.characterSheets objectForKey:cd.trackSheet];
				else return nil;
			}
		}
	}
	return nil;
}

- (CharacterLayout *) editSheet {
	DataManager *dm = [DataManager getDataManager];
	if (dm)
	{
		Ruleset *rules = [dm.systems objectForKey:_system];
		if (rules)
		{
			CharacterDefinition *cd = [rules.characterTypes objectForKey:_charType];
			if (cd)
			{
				if (cd.editSheet)
					return [rules.characterSheets objectForKey:cd.editSheet];
				else if (cd.createSheet)
					return [rules.characterSheets objectForKey:cd.createSheet];
				else if (cd.trackSheet)
					return [rules.characterSheets objectForKey:cd.trackSheet];
				else return nil;
			}
		}
	}
	return nil;
}

- (CharacterLayout *) trackSheet {
	DataManager *dm = [DataManager getDataManager];
	if (dm)
	{
		Ruleset *rules = [dm.systems objectForKey:_system];
		if (rules)
		{
			CharacterDefinition *cd = [rules.characterTypes objectForKey:_charType];
			if (cd)
			{
				if (cd.trackSheet)
					return [rules.characterSheets objectForKey:cd.trackSheet];
				else if (cd.editSheet)
					return [rules.characterSheets objectForKey:cd.editSheet];
				else if (cd.createSheet)
					return [rules.characterSheets objectForKey:cd.createSheet];
				else return nil;
			}
		}
	}
	return nil;
}

- (NSString*)XmlString: (NSString*)xsltInstruction {
	if (bXmlDirty)
	{
		[self fullyLoad];
		NSString *xml = [NSString stringWithFormat:@"<?xml version=\"1.0\"?>\n%@\n\n<character system=\"%@\" type=\"%@\">\n", (xsltInstruction==nil)?@"":xsltInstruction, _system, _charType];
		
		DataManager *dm = [DataManager getDataManager];
		Ruleset *rules = [dm rulesetForName:_system];
		if (dm && rules && attributeValues)
		{
			CharacterDefinition *charDef = [rules characterDefinitionForName:_charType];
			
			for (int i = 0; i < charDef.attributeSet.count; ++i)
			{
				Attribute *attrib = [rules attributeForRef:[[charDef.attributeSet objectAtIndex:i] intValue]];
				if (attrib)
				{
					if (attrib.isList)
					{
						NSArray *listValues = [attributeValues objectForKey:[NSNumber numberWithInt:attrib.uid]];
						
						xml = [xml stringByAppendingFormat:@"\t<attribute name=\"%@\">\n", [attrib name]];
						for (int j = 0; j < listValues.count; ++j)
						{
							if (attrib.valueType == AVT_DataSet)
							{
								xml = [xml stringByAppendingString:@"\t\t<item>\n"];
								
								DataSet *innerType = attrib.dataType;
								if (innerType && innerType.elements && innerType.elements.count > 0)
								{
									NSArray *innerValues = [listValues objectAtIndex:j];
									for (int k = 0; k < innerType.elements.count; ++k)
									{
										NSString *value = sanitize([innerValues objectAtIndex:k]);
										xml = [xml stringByAppendingFormat:@"\t\t\t<%@><![CDATA[%@]]></%@>\n", 
											   [[innerType.elements objectAtIndex:k] name],
											   value,
											   [[innerType.elements objectAtIndex:k] name]];
									}
								}

								xml = [xml stringByAppendingString:@"\t\t</item>\n"];
							}
							else
							{
								NSString *value = sanitize([listValues objectAtIndex:j]);
								xml = [xml stringByAppendingFormat:@"\t\t<item><![CDATA[%@]]></item>\n", value];
							}

						}
						xml = [xml stringByAppendingString:@"\t</attribute>\n"];
					}
					else
					{
						if (attrib.valueType == AVT_DataSet)
						{
							xml = [xml stringByAppendingFormat:@"\t<attribute name=\"%@\">\n", [attrib name]];
							
							DataSet *innerType = attrib.dataType;
							if (innerType && innerType.elements && innerType.elements.count > 0)
							{
								NSArray *innerValues = [attributeValues objectForKey:[NSNumber numberWithInt:attrib.uid]];
								for (int j = 0; j < innerType.elements.count; ++j)
								{
									NSString *value = sanitize([innerValues objectAtIndex:j]);
									xml = [xml stringByAppendingFormat:@"\t\t<%@><![CDATA[%@]]></%@>\n", 
										   [[innerType.elements objectAtIndex:j] name],
										   value,
										   [[innerType.elements objectAtIndex:j] name]];
								}
							}
							
							xml = [xml stringByAppendingString:@"\t</attribute>\n"];
						}
						else
						{
							NSString *value = sanitize([attributeValues objectForKey:[NSNumber numberWithInt:attrib.uid]]);
							if (value)
							{
								xml = [xml stringByAppendingFormat:@"\t<attribute name=\"%@\"><![CDATA[%@]]></attribute>\n", [attrib name], value];
							}
						}
					}
				}
			}
		}
		
		NSString *value = [attributeValues objectForKey:@"Token"];
		if (value)
		{
			xml = [xml stringByAppendingFormat:@"\t<attribute name=\"Token\"><![CDATA[%@]]></attribute>\n", value];
		}
		
		cachedXml = [xml stringByAppendingString:@"</character>\n"];
		bXmlDirty = NO;
	}
	else if (cachedXml == nil)
	{
		NSError *error = nil;
		NSStringEncoding enc = NSUTF8StringEncoding;
		cachedXml = [NSString stringWithContentsOfFile:_file usedEncoding:&enc error:&error];
		if (error)
		{
			fprintf(stdout, "Error loading character file: \"%s\"\n", [[error localizedDescription] UTF8String]);
			cachedXml = nil;
		}
	}
	
	return cachedXml;
}

extern BOOL bPad;

- (NSString*)HTMLString: (CharacterLayout*)layout {
	NSString *path = [[DataManager getDataManager] docsPath];
	NSString *sheet_file = [layout.file objectForKey:(bPad?@"ipad":@"iphone")];
	path = [sheet_file substringFromIndex:path.length];
	NSString *xslt = [NSString stringWithFormat:@"<?xml-stylesheet type=\"text/xsl\" href=\"..%@\"?>", path];
	bXmlDirty = YES;
	NSString *xml = [self XmlString:xslt]; // force cache the xml
	return xml;
}

- (void)import:(Import*)selectedImport fromText:(NSString*)html
{
//	fprintf(stdout, "Importing from html: \n%s\n", [html UTF8String]);
	DataManager *dm = [DataManager getDataManager];
	if (dm)
	{
		Ruleset *rules = [dm rulesetForName:_system];
		if (rules)
		{
			CharacterDefinition *chardef = [rules characterDefinitionForName:_charType];
			
			NSMutableDictionary *attribSet = [[NSMutableDictionary alloc] init];

			for (int i = 0; i < selectedImport.transformInstructions.count; ++i)
			{
				ImportInstruction *instruct = [selectedImport.transformInstructions objectAtIndex:i];
				Attribute *aref = [chardef attributeForName:instruct.attribute];
				
				if (aref && instruct.pattern)
				{
					if (aref.isList)
					{
						int indexSlot = -1;
						int valueSlot = 1;
						
						if (instruct.children && instruct.children.count > 0)
						{
							for (int j = 0; j < instruct.children.count; ++j)
							{
								if ([[instruct.children objectAtIndex:j] caseInsensitiveCompare:@"__index__"] == NSOrderedSame)
								{
									indexSlot = j+1;
								}
								else if ([[instruct.children objectAtIndex:j] caseInsensitiveCompare:@"__value__"] == NSOrderedSame)
								{
									valueSlot = j+1;
								}
							}
						}
						
						NSMutableArray *listItems = [NSMutableArray arrayWithCapacity:4];
						fprintf(stdout, "Checking: %s\n", [instruct.pattern.pattern UTF8String]);
						NSArray *results = [instruct.pattern matchesInString:html options:0 range:NSMakeRange(0,html.length)];
						if (results)
						{
							for (int i = 0; i < results.count; ++i)
							{
								NSTextCheckingResult *result = [results objectAtIndex:i];
								
								if (result && result.range.location != NSNotFound)
								{
									fprintf(stdout, "Matched: %s %d\n", [[html substringWithRange:result.range] UTF8String], i);
									if (aref.valueType == AVT_DataSet && instruct.children)
									{
										DataSet *innerType = aref.dataType;
										if (innerType && innerType.elements)
										{
											NSMutableArray *structItems = [NSMutableArray arrayWithCapacity:innerType.elements.count];
											for (int j = 0; j < innerType.elements.count; ++j)
											{
												NSString *innerValue = @"";
												Attribute *iAttr = [innerType.elements objectAtIndex:j];
												for (int k = 0; k < instruct.children.count; ++k)
												{
													if ([[instruct.children objectAtIndex:k] caseInsensitiveCompare:iAttr.name] == NSOrderedSame)
													{
														NSRange range = [result rangeAtIndex:k+1];
														if (range.location != NSNotFound)
														{
															innerValue = [html substringWithRange:range];
															if (iAttr.valueType == AVT_YesNo)
																innerValue = innerValue.length>0?@"true":@"false";
														}
														break;
													}
												}
												if (innerValue == nil)
													innerValue = @"";
												[structItems addObject:innerValue];
											}
											[listItems addObject:structItems];
										}
									}
									else
									{
										NSRange range = [result rangeAtIndex:valueSlot];
										if (range.location != NSNotFound)
										{
											NSString *value = [html substringWithRange:range];
											if (value)
											{
												if (aref.valueType == AVT_YesNo)
													value = value.length>0?@"true":@"false";
												[listItems addObject:value];
											}
										}
									}
								}
							}
						}
						[attribSet setObject:listItems forKey:[NSNumber numberWithInt:aref.uid]];
					}
					else
					{
						fprintf(stdout, "Checking: %s\n", [instruct.pattern.pattern UTF8String]);
						NSTextCheckingResult *result = [instruct.pattern firstMatchInString:html options:0 range:NSMakeRange(0,html.length)];
						if (result && result.range.location != NSNotFound)
						{
							fprintf(stdout, "Matched: %s\n", [[html substringWithRange:result.range] UTF8String]);
							if (aref.valueType == AVT_DataSet && instruct.children)
							{
								DataSet *innerType = aref.dataType;
								if (innerType && innerType.elements)
								{
									NSMutableArray *structItems = [NSMutableArray arrayWithCapacity:innerType.elements.count];
									for (int j = 0; j < innerType.elements.count; ++j)
									{
										NSString *innerValue = @"";
										Attribute *iAttr = [innerType.elements objectAtIndex:j];
										for (int k = 0; k < instruct.children.count; ++k)
										{
											if ([[instruct.children objectAtIndex:k] caseInsensitiveCompare:iAttr.name] == NSOrderedSame)
											{
												NSRange range = [result rangeAtIndex:k+1];
												if (range.location != NSNotFound)
												{
													innerValue = [html substringWithRange:range];
													if (iAttr.valueType == AVT_YesNo)
														innerValue = innerValue.length>0?@"true":@"false";
												}
												break;
											}
										}
										if (innerValue == nil)
											innerValue = @"";
										[structItems addObject:innerValue];
									}
									[attribSet setObject:structItems forKey:[NSNumber numberWithInt:aref.uid]];
								}
							}
							else
							{
								NSRange range = [result rangeAtIndex:1];
								if (range.location != NSNotFound)
								{
									NSString *value = [html substringWithRange:range];
									if (value)
									{
										if (aref.valueType == AVT_YesNo)
											value = value.length>0?@"true":@"false";
										[attribSet setObject:value forKey:[NSNumber numberWithInt:aref.uid]];
									}
								}
							}
						}
					}
				}
			}
			if (attributeValues)
			{
				[attributeValues removeAllObjects];
			}
			attributeValues = attribSet;
		}
	}
	bXmlDirty = YES;
	//fprintf(stdout, "Character XML:\n%s\n", [[self XmlString:@""] UTF8String]);
	bXmlDirty = YES;
}

- (NSURL*)baseURL {
	return [NSURL fileURLWithPath:[[[DataManager getDataManager] docsPath] stringByAppendingPathComponent:@"Sheets"]];
}

- (NSString*)getAttributeValue:(NSString *)attr_name withIndex:(NSInteger)array_index withSubAttr:(NSString *)sub_attr forVersion:(NSInteger)version fromWebView:(UIWebView*)web_view
{
	if (version == 0)
	{
		if (array_index >= 0)
		{
			if (sub_attr)
			{
				return [web_view stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"GetTextValueArray(\"%@_%@\", %ld)", attr_name, sub_attr, (long)array_index]];
			}
			else
			{
				return [web_view stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"GetTextValueArray(\"%@\", %ld)", attr_name, (long)array_index]];
			}
		}
		else
		{
			if (sub_attr)
			{
				return [web_view stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"GetTextValue(\"%@_%@\")", attr_name, sub_attr]];
			}
			else
			{
				return [web_view stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"GetTextValue(\"%@\")", attr_name]];
			}
		}
	}
	else if (version == 1)
	{
		if (array_index >= 0)
		{
			attr_name = [NSString stringWithFormat:@"%@[%ld]", attr_name, (long)array_index];
		}
		if (sub_attr)
		{
			attr_name = [NSString stringWithFormat:@"%@.%@", attr_name, sub_attr];
		}
		return [web_view stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"GetAttributeValue(\"%@\")", attr_name]];
	}
	
	return @"[[empty]]";
}

- (void)saveFromWebView:(UIWebView*)webView {
	DataManager *dm = [DataManager getDataManager];
	Ruleset *rules = [dm rulesetForName:_system];

	NSInteger version = 0;
	if ([[webView stringByEvaluatingJavaScriptFromString:@"window.GetAttributeValue == undefined"] caseInsensitiveCompare:@"false"] == NSOrderedSame)
	{
		version = 1;
	}
	else if ([[webView stringByEvaluatingJavaScriptFromString:@"window.GetTextValue == undefined"] caseInsensitiveCompare:@"true"] == NSOrderedSame ||
		[[webView stringByEvaluatingJavaScriptFromString:@"window.GetTextValueArray == undefined"] caseInsensitiveCompare:@"true"] == NSOrderedSame)
	{
		return;
	}
	
	NSString *newName = [self getAttributeValue:@"Name" withIndex:-1 withSubAttr:nil forVersion:version fromWebView:webView];
	if ([newName caseInsensitiveCompare:@"[[empty]]"] != NSOrderedSame)
	{
		_name = newName;
	}

	if (dm && rules && attributeValues)
	{
		CharacterDefinition *charDef = [rules characterDefinitionForName:_charType];

		for (int i = 0; i < charDef.attributeSet.count; ++i)
		{
			Attribute *attrib = [rules attributeForRef:[[charDef.attributeSet objectAtIndex:i] intValue]];
			if (attrib)
			{
				if (attrib.isList)
				{
					int index = 0;
					NSString *newValue = nil;
					NSMutableArray *listValues = [attributeValues objectForKey:[NSNumber numberWithInt:attrib.uid]];
					if (listValues == nil)
					{
						listValues = [NSMutableArray arrayWithCapacity:5];
						[attributeValues setObject:listValues forKey:[NSNumber numberWithInt:attrib.uid]];
					}
					
					do {
						if (attrib.valueType == AVT_DataSet)
						{
							DataSet *innerType = attrib.dataType;
							if (innerType && innerType.elements && innerType.elements.count > 0)
							{
								NSMutableArray *innerValues = nil;
								if (index >= listValues.count)
								{
									innerValues = [NSMutableArray arrayWithCapacity:innerType.elements.count];
									[listValues addObject:innerValues];
								}
								else
								{
									innerValues = [listValues objectAtIndex:index];
								}
								
								for (int i = 0; i < innerType.elements.count; ++i) 
								{
									newValue = [self getAttributeValue:attrib.name withIndex:index withSubAttr:[[innerType.elements objectAtIndex:i] name] forVersion:version fromWebView:webView];
									if (newValue)
									{
										if ([newValue compare:@"[[outofbounds]]"] == NSOrderedSame)
										{
											if (innerValues.count > i)
												[innerValues removeObjectsInRange:NSMakeRange(i, innerValues.count-i)];
											break;
										}
										else if ([newValue compare:@"[[empty]]"] == NSOrderedSame)
										{
											if (i >= innerValues.count)
												[innerValues addObject:@""];
										}
										else
										{
											if (i >= innerValues.count)
												[innerValues addObject:newValue];
											else
												[innerValues replaceObjectAtIndex:i withObject:newValue];
											bFileDirty = YES;
											bXmlDirty = YES;
										}
									}
								}
							}
						}
						else
						{
							newValue = [self getAttributeValue:attrib.name withIndex:index withSubAttr:nil forVersion:version fromWebView:webView];
							if (newValue && 
								[newValue compare:@"[[outofbounds]]"] != NSOrderedSame)
							{
								if ([newValue compare:@"[[empty]]"] == NSOrderedSame)
								{
									if (index >= listValues.count)
										[listValues addObject:@""];
								}
								else if (index >= listValues.count)
									[listValues addObject:newValue];
								else
									[listValues replaceObjectAtIndex:index withObject:newValue];
								bFileDirty = YES;
								bXmlDirty = YES;
							}
						}
						
						if ([newValue compare:@"[[outofbounds]]"] == NSOrderedSame && listValues.count > index)
						{
							[listValues removeObjectsInRange:NSMakeRange(index, listValues.count - index)];
						}

						++index;
					} while ([newValue compare:@"[[outofbounds]]"] != NSOrderedSame);
				}
				else
				{
					if (attrib.valueType == AVT_DataSet)
					{
						DataSet *innerType = attrib.dataType;
						if (innerType && innerType.elements && innerType.elements.count > 0)
						{
							NSMutableArray *innerValues = [NSMutableArray arrayWithCapacity:innerType.elements.count];
							[attributeValues setObject:innerValues forKey:[NSNumber numberWithInt:attrib.uid]];
							for (int i = 0; i < innerType.elements.count; ++i) 
							{
								[innerValues addObject:@""];
								NSString *newValue = [self getAttributeValue:attrib.name withIndex:-1 withSubAttr:[[innerType.elements objectAtIndex:i] name] forVersion:version fromWebView:webView];
								if (newValue && [newValue compare:@"[[empty]]"] != NSOrderedSame)
								{
									[innerValues replaceObjectAtIndex:i withObject:newValue];
									bFileDirty = YES;
									bXmlDirty = YES;
								}
							}
						}
					}
					else
					{
						NSString *newValue = [self getAttributeValue:attrib.name withIndex:-1 withSubAttr:nil forVersion:version fromWebView:webView];
						if (newValue && [newValue compare:@"[[empty]]"] != NSOrderedSame)
						{
							[attributeValues setObject:newValue forKey:[NSNumber numberWithInt:attrib.uid]];
							bFileDirty = YES;
							bXmlDirty = YES;
						}
					}
				}
			}
		}
	}
	
	bXmlDirty = YES;
	[self saveToFile];
}

- (void)generateFileName {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *path = [[DataManager getDataManager] docsPath];
	path = [path stringByAppendingPathComponent:@"Characters/%08x.char"];
	NSString *fileName = nil;
	
	do
	{
		fileName = [NSString stringWithFormat:path, random()];
	} while ([fm fileExistsAtPath:fileName]);
	
	_file = fileName;
}

- (void)saveToFile {
	if (bFileDirty == NO) return;
	
	[self fullyLoad];
	
	NSString *xml = [self XmlString:nil]; // cache the xml
	
	if (_file == nil)
	{
		[self generateFileName];
	}
	
	NSError *error = nil;
	[xml writeToFile:_file atomically:YES encoding:NSUTF8StringEncoding error:&error];
	if (error)
	{
		fprintf(stdout, "Error saving file: '%s'\n\t%s\n\t%s\n", [_file UTF8String], [[error localizedDescription] UTF8String], [[error localizedFailureReason] UTF8String]);
	}
	bFileDirty = NO;
}

- (NSData*)dataForSharing
{
	return [[self XmlString:nil] dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString*)contentType
{
#ifdef SINGLE_SYSTEM_SUPPORT
	return @"_x-" SINGLE_SYSTEM @"CharShare._tcp.";
#else
	return @"_x-GTCharShare._tcp.";
#endif
}

- (id)initWithSharedData:(NSData*)data
{
	NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	self = [self initWithXMLString:xmlString fully:YES];
	if (self)
	{
		Ruleset *rules = [[DataManager getDataManager] rulesetForName:_system];
		if (rules) [rules addCharacter:self];
		[[[DataManager getDataManager] characterData] refreshData];
		[self saveToFile];
	}
	return self;
}

- (NSString*)setToken:(Token*)token
{
	NSData *imgData = UIImageJPEGRepresentation(token.image,0.85f);
	NSString *base64 = [NSString base64StringFromData:imgData length:imgData.length];
	[attributeValues setObject:base64 forKey:@"Token"];
	[self createMiniImage];
	bXmlDirty = YES;
	bFileDirty = YES;
	return base64;
}

- (NSString*)getToken
{
	return [attributeValues objectForKey:@"Token"];
}

@end
