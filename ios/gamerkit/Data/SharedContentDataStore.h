//
//  SharedContentDataStore.h
//  RPG Toolkit
//
//  Created by Ben Taggart on 8/4/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ConnectionManager.h"

@interface SharedContentDataStore : NSObject <UITableViewDelegate, UITableViewDataSource, NetServiceConsumer> {
	UITableView *currentTable;
	
	NSMutableArray *contentList;
}

@property (readonly) IBOutlet UIActivityIndicatorView* findingIndicator;
@property (readonly) ConnectionManager* connectionMgr;

- (id)init;

// UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

// UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

// NetServiceConsumer
- (void)connectionManager:(ConnectionManager*)cm foundNetService:(NSNetService*)service;
- (void)connectionManager:(ConnectionManager*)cm lostNetService:(NSNetService*)service;
- (void)connectionManagerDoneFindingServices:(ConnectionManager*)cm;
- (void)clearServices;

@end
