//
//  DataSet.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 5/22/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Ruleset;

typedef struct _DataType {
} DataType;

@interface DataSet : NSObject {
	NSString *name;
	NSMutableArray *elements;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, readonly) NSArray *elements;

- (id)initWithXmlNode:(void*)node forRuleset:(Ruleset*)rules;

@end
