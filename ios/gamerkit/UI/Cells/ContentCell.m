//
//  ContentCell.m
//  gamerkit
//
//  Created by Benjamin Taggart on 11/7/15.
//  Copyright © 2015 Abject Entertainment. All rights reserved.
//

#import "ContentCell.h"

@implementation ContentCell

-(id)getContentObject
{
	if (self.delegate)
	{ return [self.delegate getContentObjectForCell:self]; }
	
	return self._contentObject;
}

@end
