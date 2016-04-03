//
//  ContentTransformResult.m
//  gamerkit
//
//  Created by Benjamin Taggart on 4/1/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import "ContentTransformResult.h"
#import "ContentObject.h"

@implementation ContentTransformResult

- (void)setSucceeded:(BOOL)succeeded { _succeeded = succeeded; }
- (void)setTitle:(NSString*)title { _title = title; }
- (void)setSubtitle:(NSString *)subtitle { _subtitle = subtitle; }
- (void)setImage:(UIImage *)image { _image = image; }
- (void)setHtml:(NSString *)html { _html = html; }
- (void)setFile:(NSURL *)file { _file = file; }
- (void)setPrintFormatter:(UIPrintFormatter *)printFormatter { _printFormatter = printFormatter; }

- (instancetype)initWithAction:(ContentObjectAction)action
{
	self = [self init];
	if (self)
	{
		_action = action;
		_succeeded = NO;
	}
	return self;
}

@end
