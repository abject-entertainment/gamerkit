//
//  LocalDataSource.h
//  gamerkit
//
//  Created by Benjamin Taggart on 7/17/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "DataSource.h"

@interface LocalDataSource : DataSource

- (void)enumerateContentOfType:(DataContentType)type toCallback:(DataContentEnumerationCallback)callback;

@end
