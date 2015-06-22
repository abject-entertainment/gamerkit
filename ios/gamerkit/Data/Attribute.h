//
//  Attribute.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 3/10/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef int AttributeRef;
@class DataSet;
@class OptionSet;
@class Ruleset;

//typedef struct _AttributeValue {
//	AttributeRef attr;
//	NSString *value;
//	NSMutableArray *list;
//} AttributeValue;

enum _AttributeValueType {
	AVT_None,
	AVT_YesNo,
	AVT_Integer,
	AVT_String,
	AVT_Option,
	AVT_DataSet
};
typedef enum _AttributeValueType AttributeValueType;

@interface Attribute : NSObject {
	NSString *displayName;
	OptionSet *options;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) AttributeRef uid;
@property (nonatomic, readonly) BOOL isList;
@property (nonatomic, readonly) AttributeValueType valueType;
@property (nonatomic, readonly) DataSet *dataType;

- (id)initWithXmlNode:(void*)node andUid:(int)inUid forRuleset:(Ruleset*)rules;

@end

