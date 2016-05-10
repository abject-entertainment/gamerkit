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
#import "ContentManager.h"
#import "CharacterDefinition.h"
#import "AppDelegate.h"
#import "Base64.h"
#import "CharacterViewController.h"
#import "CircleImageView.h"
#import "ContentTransformResult.h"

typedef enum : NSUInteger {
	SortOrderUnknown,
	SortOrderSystemTypeName,
	SortOrderName
} CharacterSortOrder;

@interface SectionData : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSUInteger start;
@end
@implementation SectionData
+(SectionData *)sectionWithTitle:(NSString*)title andCount:(NSUInteger)count andStart:(NSUInteger)start
{ return [[SectionData alloc] initWithTitle:title andCount:count andStart:start]; }
-(instancetype)initWithTitle:(NSString*)title andCount:(NSUInteger)count andStart:(NSUInteger)start
{ return ([super init]?_title=title,_count=count,_start=start,self:nil); }
@end

@interface CharacterListController () <CharacterConsumer>
{
	BOOL _refreshing;
}
@property (nonatomic, strong) NSMutableArray<Character*> *characters;
@property (nonatomic, strong) NSMutableArray<SectionData*> *sections;
@property (nonatomic, assign) CharacterSortOrder lastSort;
@end

@implementation CharacterListController

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		_refreshing = NO;
		_lastSort = SortOrderUnknown;
		_characters = [NSMutableArray<Character*> array];
		
		[[ContentManager contentManager] addCharacterConsumer:self];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.collectionView.contentInset = UIEdgeInsetsMake(20, 0, 40, 0);
}

- (void)characterAdded:(Character *)character
{
	if (![_characters containsObject:character])
	{
		[_characters addObject:character];
		_lastSort = SortOrderUnknown;
		[self refreshData];
	}
}

- (void)characterRemoved:(Character *)character
{
	if ([_characters containsObject:character])
	{
		[_characters removeObject:character];
		_lastSort = SortOrderUnknown;
		[self refreshData];
	}
}

- (void)characterUpdated:(Character *)character
{
	if ([_characters containsObject:character])
	{
		[self refreshData];
	}
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	if (_sections == nil || _lastSort == SortOrderUnknown)
	{
		[self updateSort];
	}
	return [_sections count];
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(nonnull NSIndexPath *)indexPath
{
	SystemHeaderCell *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SystemHeader" forIndexPath:indexPath];
	[cell setSystem:_sections[indexPath.section].title];
	
	return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell;
	if (indexPath.row == _sections[indexPath.section].count)
	{
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewCharacter" forIndexPath:indexPath];
	}
	else
	{
		CharacterCell *ccell = (CharacterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Character" forIndexPath:indexPath];
		
		if (ccell != nil)
		{
			if (indexPath.section < _sections.count)
			{
				NSUInteger cidx = _sections[indexPath.section].start + indexPath.row;
				if (cidx < _characters.count)
				{
					Character *ch = _characters[cidx];
					
					[ccell setupForPreview:[ch getPreview]];
					ccell._contentObject = ch;
				}
			}
		}
		cell = ccell;
	}
	
	return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _sections[section].count + 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	ContentManager *cm = [ContentManager contentManager];
	
	if (indexPath.section < _sections.count)
	{
		if (_sections[indexPath.section].count == indexPath.row)
		{ // new character
			UIAlertController *picker = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
			UIPopoverPresentationController *pop = [picker popoverPresentationController];
			pop.sourceView = [collectionView cellForItemAtIndexPath:indexPath];
			pop.sourceRect = pop.sourceView.bounds;
			
			Ruleset *rules = [cm systemForId:_characters[_sections[indexPath.section].start].system];
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
		else
		{
			NSUInteger cidx = _sections[indexPath.section].start + indexPath.row;
			if (cidx < _characters.count)
			{
				[self showCharacter:_characters[cidx]];
			}
		}
	}
	
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)showCharacter:(Character *)ch
{
	CharacterViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CharacterView"];
	if (cvc)
	{
		//cvc.delegate = self;
		
		[cvc displayCharacter:ch withAction:ContentObjectActionReadOnlyWebView];
		cvc.listController = self;
		[self presentViewController:cvc animated:YES completion:nil];
	}
}

- (void)createNewCharacterForSystem:(NSString*)system andType:(NSString*)ctype
{
	ContentManager *dm = [ContentManager contentManager];
	Ruleset *rules = [dm systemForId:system];
	if (rules)
	{
		CharacterDefinition *charDef = [[rules characterTypes] objectForKey:ctype];
		if (charDef)
		{
			Character *ch = [[Character alloc] initForSystem:system andType:ctype];
			
			if (ch)
			{
				[self refreshData];
				[self showCharacter:ch];
				[ch saveFile];
			}
		}
	}
}

- (void)copyRequestedForCharacter: (Character*)character
{
	ContentTransformResult *result = [character applyTransformForAction:ContentObjectActionShare];
	if (result.succeeded)
	{
		Character *ch = [[Character alloc] initWithSharedData:[NSData dataWithContentsOfURL:result.file]];
		[self showCharacter:ch];
		[self refreshData];
	}
}

- (void)deleteContentForCell:(ContentCell *)cell
{
	[[ContentManager contentManager] deleteContent:[cell getContentObject]];
}

- (void)refreshData
{
	if (_refreshing) { return; }
	_refreshing = YES;
	
	dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 500);
	dispatch_after(delay, dispatch_get_main_queue(), ^{
#warning <<AE>> TODO: Change sort order
		static CharacterSortOrder sortOrder = SortOrderSystemTypeName;
		
		if (_lastSort != sortOrder || _sections == nil)
		{
			_lastSort = sortOrder;
			[self updateSort];
		}
		
		[self.collectionView reloadData];
		_refreshing = NO;
	});
}

- (void)updateSort
{
	_sections = [NSMutableArray<SectionData*> array];
	if (_lastSort == SortOrderSystemTypeName)
	{
		NSArray<NSSortDescriptor*> *sortOrder = @[[NSSortDescriptor sortDescriptorWithKey:@"system" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"charType" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
		[_characters sortUsingDescriptors:sortOrder];
		
		ContentManager *cm = [ContentManager contentManager];
		SectionData *sdata = nil;
		
		NSString *lastSystem = nil;
		NSString *lastType = nil;
		NSUInteger i = 0;
		
		for (Character *c in _characters)
		{
			NSString *systemId = c.system;
			NSString *charType = c.charType;
			
			if (![systemId isEqualToString:lastSystem] ||
				![c.charType isEqualToString:lastType])
			{
				if (sdata)
				{ sdata.count = i - sdata.start; }
				
				Ruleset *system = [cm systemForId:systemId];
				CharacterDefinition *cdef = [[system characterTypes] objectForKey:charType];
				
				NSUInteger start = sdata?sdata.start+sdata.count:0;
				SectionData *newSection = [SectionData sectionWithTitle:[NSString stringWithFormat:@"%@ - %@", system.displayName, cdef.displayName] andCount:i-start andStart:start];
				sdata = newSection;
				[_sections addObject:newSection];
				
				lastSystem = systemId;
				lastType = charType;
			}
			
			++i;
		}
		
		if (sdata)
		{ sdata.count = i - sdata.start; }
	}
	else if (_lastSort == SortOrderName)
	{
		NSArray<NSSortDescriptor*> *sortOrder = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
		[_characters sortUsingDescriptors:sortOrder];
		
		SectionData *sdata = nil;
		unichar current = 0;
		NSUInteger i = 0;
		
		for (Character *c in _characters)
		{
			NSString *name = c.name;
			unichar first = [name characterAtIndex:0];
			
			if (first != current)
			{
				NSUInteger start = sdata?sdata.start+sdata.count:0;
				SectionData *newSection = [SectionData sectionWithTitle:[NSString stringWithCharacters:&current length:1] andCount:i-start andStart:start];
				sdata = newSection;
				[_sections addObject:newSection];
				
				current = first;
			}
			++i;
		}
	}
}

- (UIView *)viewForContextMenuForCell:(ContentCell *)cell
{
	if ([cell isKindOfClass:CharacterCell.class])
	{
		return [[CircleImageView alloc] initWithImage:((CharacterCell*)cell).token.image];
	}
	return nil;
}

@end
