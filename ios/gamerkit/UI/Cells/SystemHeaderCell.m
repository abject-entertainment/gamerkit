//
//  SystemHeaderCell.m
//  gamerkit
//
//  Created by Benjamin Taggart on 5/30/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "SystemHeaderCell.h"

@implementation SystemHeaderCell

- (void)setSystem:(NSString *)name {
	if (_systemName)
	{ _systemName.text = name; }
}

@end
