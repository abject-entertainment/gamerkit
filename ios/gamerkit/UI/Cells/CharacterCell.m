//
//  CharacterTableCell.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 2/19/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "CharacterCell.h"
#import "ContentObject.h"
#import "ContentTransformResult.h"

@implementation CharacterCell

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
	}
	return self;
}

- (void)setupForPreview:(ContentTransformResult *)preview
{
	_name.text = preview.title;
	_summary.text = preview.subtitle;
	_token.image = preview.image;
}

@end
