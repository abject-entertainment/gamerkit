//
//  Import.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 11/17/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Ruleset;

@interface ImportInstruction : NSObject

@property (nonatomic, assign) NSString *attribute;
@property (nonatomic, assign) NSArray *children;
@property (nonatomic, assign) NSRegularExpression *pattern;
@end

@interface Import : NSObject {
	NSMutableArray *_transformInstructions;
}

@property (nonatomic, assign) NSString *system;
@property (nonatomic, assign) NSString *contentType;
@property (nonatomic, assign) NSString *subtype;
@property (nonatomic, assign) NSString *displayName;
@property (nonatomic, assign) NSString *href;
@property (nonatomic, assign) NSString *intro;
@property (nonatomic, assign) NSString *transformFile;
@property (nonatomic, readonly) NSArray *transformInstructions;

- (id)initWithXmlNode:(void*)node andRuleset:(Ruleset*)inRules;

@end
