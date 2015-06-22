//
//  SharedContentDataStore.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 8/4/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "SharedContentDataStore.h"

#import "DataManager.h"

@implementation SharedContentDataStore

@synthesize findingIndicator, connectionMgr;

- (id)init
{
	DataManager *dm = [DataManager getDataManager];
	if (self = [super init])
	{
		if (dm)
		{
			if (dm.sharedData == nil)
			{
				connectionMgr = [[ConnectionManager alloc] init];
				contentList = [NSMutableArray arrayWithCapacity:10];
				dm.sharedData = self;
			}
		}
	}
	return dm.sharedData;
}

// UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{ currentTable = tableView; return 1; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	currentTable = tableView;
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SharedContentCell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SharedContentCell"];
	}
	
	if (cell != nil)
	{
		NSUInteger idx[2];
		[indexPath getIndexes: idx];
		
		cell.accessoryType = UITableViewCellAccessoryNone;

		if (idx[0] == 0 && idx[1] < contentList.count)
		{
			NSNetService *service = [contentList objectAtIndex:idx[1]];
			if (service)
			{
				cell.textLabel.text = [service name];
			}
			else
			{
				cell.textLabel.text = @"Content Server Lost";
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
		else
		{
			cell.textLabel.text = @"Content Server Lost";
		}
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	currentTable = tableView;
	return contentList.count;
}

// UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	currentTable = tableView;

	NSUInteger idx[2];
	[indexPath getIndexes: idx];
	
	if (idx[0] == 0 && idx[1] < contentList.count)
	{
		NSNetService *service = [contentList objectAtIndex:idx[1]];
		if (service)
		{
			[connectionMgr downloadContentFromService:service];
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// NetServiceConsumer
- (void)connectionManager:(ConnectionManager*)cm foundNetService:(NSNetService*)service
{
	if ([contentList containsObject:service])
		return;
	
	[contentList addObject:service];
}

- (void)connectionManager:(ConnectionManager*)cm lostNetService:(NSNetService*)service
{
	NSUInteger idx = [contentList indexOfObject:service];
	if (idx != NSNotFound)
		[contentList replaceObjectAtIndex:idx withObject:[NSNull null]];
}

- (void)connectionManagerDoneFindingServices:(ConnectionManager*)cm
{
	for (int i = 0; i < contentList.count; ++i)
	{
		if ([contentList objectAtIndex:i] == [NSNull null])
		{
			[contentList removeObjectAtIndex:i--];
		}
	}
	if (currentTable)
		[currentTable reloadData];
	
	if (findingIndicator)
		[findingIndicator stopAnimating];
}

- (void)clearServices
{
	[contentList removeAllObjects];
}

@end
