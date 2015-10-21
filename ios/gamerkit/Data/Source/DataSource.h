//
//  DataSource.h
//  gamerkit
//
//  Created by Benjamin Taggart on 7/17/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum _DataContentType {
	TYPE_System,
	TYPE_Character,
	TYPE_Map,
	TYPE_Token
} DataContentType;

@interface DataContent : NSObject {
	NSString *title;
	NSString *subtitle;
	NSString *description;
	UIImage *image;
	
	id source;
	id sourceData;
}
+ (DataContent *)title:(NSString *)title subtitle:(NSString *)subtitle description:(NSString *)description image:(UIImage *)image;
@end

typedef void (*DataContentEnumerationCallback)(DataContentType type, NSArray *content);
typedef void (*DataContentGetCallback)(DataContent *summary, id content);

@interface DataSource : NSObject

- (void)enumerateContentOfType:(DataContentType)type toCallback:(DataContentEnumerationCallback)callback;

+ (void)addDataSource:(DataSource*)source;
+ (void)enumerateContentOfType:(DataContentType)type toCallback:(DataContentEnumerationCallback)callback;

@end
