//
//  DataSource.m
//  gamerkit
//
//  Created by Benjamin Taggart on 7/17/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataSource.h"

NSMutableArray *s_DataSources = nil;

@implementation DataContent

+ (DataContent *)title:(NSString *)title subtitle:(NSString *)subtitle description:(NSString *)description image:(UIImage *)image
{
	DataContent *dc = [DataContent alloc];
	dc->title = title;
	dc->subtitle = subtitle;
	dc->description = description;
	dc->image = image;
	
	return dc;
}

@end

@implementation DataSource

- (void)enumerateContentOfType:(DataContentType)type toCallback:(DataContentEnumerationCallback)callback
{ assert(!"Subclass missing method override."); }

+ (void)addDataSource:(DataSource*)source
{
	if (s_DataSources == nil)
	{ s_DataSources = [NSMutableArray arrayWithCapacity:2]; }
}

+ (void)enumerateContentOfType:(DataContentType)type toCallback:(DataContentEnumerationCallback)callback
{
	if (s_DataSources != nil)
	{
		for (int i = 0; i < s_DataSources.count; ++i)
		{
			[[s_DataSources objectAtIndex:i] enumerateContentOfType:type toCallback:callback];
		}
	}
}

@end