//
//  TokenListController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 6/10/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "TokenListController.h"
#import "DataManager.h"
#import "Token.h"
#import "TokenEditController.h"
#import "TokenCell.h"
#import "DismissSegue.h"

@interface TokenListController ()
{
	NSMutableArray *_tokens;
	UILongPressGestureRecognizer *_editRecognizer;
	UIViewController<TokenSelectionDelegate> *_selectionDelegate;
}

@end

@implementation TokenListController

+ (void)selectTokenForDelegate:(UIViewController<TokenSelectionDelegate> *)tokenSelectionDelegate
{
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	if (sb)
	{
		TokenListController *tlc = [sb instantiateViewControllerWithIdentifier:@"TokenList"];
		if (tlc)
		{
			tlc->_selectionDelegate = tokenSelectionDelegate;
			[tokenSelectionDelegate presentViewController:tlc animated:YES completion:nil];
		}
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view.
	NSFileManager *fm = [NSFileManager defaultManager];
	DataManager *dm = [DataManager getDataManager];
	NSString *path = [dm.docsPath stringByAppendingPathComponent:@"Media"];
	
	if (![fm fileExistsAtPath:path])
		[fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
	
	NSArray *files = [fm contentsOfDirectoryAtPath:path error:nil];
	NSEnumerator *enumerator = [files objectEnumerator];
	NSString *file;
	
	_tokens = [NSMutableArray arrayWithCapacity:files.count];
	while ((file = [enumerator nextObject]))
	{
		if ([file hasSuffix: @".token"])
		{
			Token *t = [[Token alloc] initWithFileAtPath:[path stringByAppendingPathComponent:file] fully:NO];
			if (t)
			{
				[_tokens addObject:t];
			}
		}
	}
	
	_editRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showEditMenu)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue isKindOfClass:[DismissSegue class]])
	{
		if (_selectionDelegate && [_selectionDelegate respondsToSelector:@selector(tokenSelectionWasCancelled)])
		{
			[_selectionDelegate tokenSelectionWasCancelled];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.collectionView reloadData];
}

- (void)addToken:(Token *)token
{
	[_tokens addObject:token];
	[self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _tokens.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell;
	if (indexPath.row < _tokens.count)
	{
		Token *token = [_tokens objectAtIndex:indexPath.row];
		TokenCell *tcell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Token" forIndexPath:indexPath];
		[token fullyLoad];
		[tcell.image setImage:token.image];
		cell = tcell;
	}
	else
	{
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewToken" forIndexPath:indexPath];
	}
    
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(nonnull NSIndexPath *)indexPath
{
	if ([kind compare:UICollectionElementKindSectionHeader] == NSOrderedSame)
	{
		return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"TokenCancelHeader" forIndexPath:indexPath];
	}
	else
	{
		return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"TokenCancelFooter" forIndexPath:indexPath];
	}
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
	if (cell && [cell isKindOfClass:[TokenCell class]])
	{
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
		if (_selectionDelegate)
		{
			Token *token = [_tokens objectAtIndex:indexPath.row];
			[_selectionDelegate tokenWasSelected:token];
			_selectionDelegate = nil;
		}
	}
	else
	{
		TokenEditController *tc = [self.storyboard instantiateViewControllerWithIdentifier:@"TokenEditView"];
		[self presentViewController:tc animated:YES completion:nil];
	}
}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (void)showEditMenu
{
	CGPoint touchLoc = [_editRecognizer locationInView:self.collectionView];
	NSIndexPath *path = [self.collectionView indexPathForItemAtPoint:touchLoc];
	if (path && path.row < _tokens.count)
	{
		Token *token = (Token*)[_tokens objectAtIndex:path.row];
		
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:token.name message:nil preferredStyle:UIAlertControllerStyleActionSheet];
		
		[alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
			
		}]];
		[alert addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			
		}]];
		
		
	}
}

@end
