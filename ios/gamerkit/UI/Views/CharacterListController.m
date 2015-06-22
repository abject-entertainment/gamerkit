//
//  CharacterDataStore.m
//  RPG Toolkit
//
//  Created by Ben Taggart on 2/13/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "CharacterListController.h"
#import "CharacterCell.h"
#import "SystemHeaderCell.h"
#import "Ruleset.h"
#import "Character.h"
#import "Import.h"
#import "DataManager.h"
#import "CharacterDefinition.h"
#import "SharedContentDataStore.h"
#import "AppDelegate.h"
#import "Base64.h"
#import "DiceView.h"
#import "PagesController.h"

@implementation CharacterListController

NSInteger comparator(id obj1, id obj2, void* context)
{
	DataManager *dm = [DataManager getDataManager];
	return (NSInteger)[[[dm.systems objectForKey:obj1] displayName] caseInsensitiveCompare:[[dm.systems objectForKey:obj2] displayName]];
}

- (void)getKeys
{
	DataManager *dm = [DataManager getDataManager];
	systemKeys = [dm.systems allKeys];
	NSMutableArray *sk = [NSMutableArray arrayWithCapacity:systemKeys.count];
	NSInteger ui = [systemKeys indexOfObject:dm.unknownRuleset.name];
	for (int i = 0; i < systemKeys.count; ++i)
	{
		if (i == ui) continue;
		[sk addObject:[systemKeys objectAtIndex:i]];
	}
	[sk sortUsingFunction:comparator context:NULL];
	if (dm.unknownRuleset.characters.count != 0)
	{
		[sk addObject:dm.unknownRuleset.name];
	}
	systemKeys = [NSArray arrayWithArray:sk];
}

- (void)viewDidLoad
{
	DataManager *dm = [DataManager getDataManager];
	if (dm)
	{
		[self getKeys];
		if (dm.characterData == nil)
		{
			dm.characterData = self;
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [systemKeys count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [systemKeys objectAtIndex:section];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger systemIndex = indexPath.section;
	NSInteger charIndex = indexPath.row;
	Ruleset *rules = [[[DataManager getDataManager] systems] objectForKey:[systemKeys objectAtIndex:systemIndex]];
	
	UITableViewCell *cell;
	if (charIndex == rules.characters.count)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"NewCharacter" forIndexPath:indexPath];
	}
	else
	{
		CharacterCell *ccell = (CharacterCell *)[tableView dequeueReusableCellWithIdentifier:@"Character" forIndexPath:indexPath];
		
		if (ccell != nil)
		{
			NSUInteger idx[2];
			[indexPath getIndexes: idx];
			DataManager *dm = [DataManager getDataManager];
			
			if (idx[0] < systemKeys.count)
			{
				Ruleset *rules = [dm.systems objectForKey:[systemKeys objectAtIndex:idx[0]]];
				if (idx[1] < rules.characters.count)
				{
					Character *ch = [rules.characters objectAtIndex:idx[1]];
					
					ccell.name.text = [ch name];
					ccell.summary.text = [[rules.characterTypes objectForKey:ch.charType] displayName];
					UIImage *imgData = ch.miniImage;
					ccell.token.image = imgData;
					ccell.data = ch;
				}
			}
		}
		cell = ccell;
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	Ruleset *rules = [[[DataManager getDataManager] systems] objectForKey:[systemKeys objectAtIndex:section]];
	return rules.characters.count + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DataManager *dm = [DataManager getDataManager];
	
	if (indexPath.section < systemKeys.count)
	{
		Ruleset *rules = [dm.systems objectForKey:[systemKeys objectAtIndex:indexPath.section]];
		if (indexPath.row < rules.characters.count)
		{
			Character *ch = [rules.characters objectAtIndex:indexPath.row];
			[[PagesController getPages] addPageForCharacter:ch];
		}
		else
		{ // new character
			UIAlertController *picker = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
			UIPopoverPresentationController *pop = [picker popoverPresentationController];
			pop.sourceView = [tableView cellForRowAtIndexPath:indexPath];
			pop.sourceRect = pop.sourceView.bounds;
			
			NSEnumerator *en = [[rules characterTypes] objectEnumerator];
			NSObject *value;
			while ((value = [en nextObject]))
			{
				NSString *ctype = ((CharacterDefinition*)value).name;
				UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"New %@", ((CharacterDefinition*)value).displayName] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
					[self createNewCharacterForSystem:rules.name andType:ctype];
				}];
				[picker addAction:action];
			}
			
			[self presentViewController:picker animated:YES completion:nil];
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DataManager *dm = [DataManager getDataManager];
	if (indexPath.section < systemKeys.count)
	{
		Ruleset *rules = [dm.systems objectForKey:[systemKeys objectAtIndex:indexPath.section]];
		if (indexPath.row < rules.characters.count)
		{
			CharacterListController *this = self;
			Character *character = [rules.characters objectAtIndex:indexPath.row];
			return @[
				[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
					// confirm delete
					[this deleteRequestedForCharacter:character];
				}],
				[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Share" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
					// share character
					[this shareRequestedForCharacter:character];
				}],
				[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Copy" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
					[this copyRequestedForCharacter:character];
				}]
			];
		}
	}
	return @[];
}

- (void)createNewCharacterForSystem:(NSString*)system andType:(NSString*)ctype
{
	DataManager *dm = [DataManager getDataManager];
	Ruleset *rules = [dm.systems objectForKey:system];
	if (rules)
	{
		CharacterDefinition *charDef = [[rules characterTypes] objectForKey:ctype];
		if (charDef)
		{
			Character *ch = [[Character alloc] initForSystem:system andType:ctype];
			
			if (ch)
			{
				[[PagesController getPages] addPageForCharacter:ch];
				[self refreshData];
			}
		}
	}
}

- (void)copyRequestedForCharacter: (Character*)character
{
	Character *ch = [[Character alloc] initWithSharedData:[character dataForSharing]];
	[[PagesController getPages] addPageForCharacter:ch];
	[self refreshData];
}

- (void)shareRequestedForCharacter: (Character*)character
{
}

- (void)deleteRequestedForCharacter: (Character*)character
{
}

- (void)refreshData
{
	[self getKeys];
	if ([self.view isKindOfClass:[UICollectionView class]])
	{ [(UICollectionView *)self.view reloadData]; }
}

@end
