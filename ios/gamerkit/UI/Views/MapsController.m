    //
//  MapsController.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/31/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "MapsController.h"
#import "AppDelegate.h"
#import "GriddedView.h"
#import "ContentManager.h"
#import "MapCell.h"

@interface MapsController () <MapConsumer>
{
	NSMutableOrderedSet *_maps;
	Map *currentMap;
	
	UIPopoverController *popover;
	UIViewController *cachedVC;
	id<UITabBarControllerDelegate> cachedDel;
	UIBarButtonItem *cachedButton;
}
@end

@implementation MapsController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
	{
		// load map xml files.
		ContentManager *cm = [ContentManager contentManager];
		
		[cm addMapConsumer:self];
    }
    return self;
}

- (void)mapAdded:(Map *)map
{
	[_maps addObject:map];
	[self.collectionView reloadData];
}

- (void)mapRemoved:(Map *)map
{
	[_maps removeObject:map];
	[self.collectionView reloadData];
}

- (void)mapUpdated:(Map *)map
{
	[self.collectionView reloadData];
}

- (void)formatMapImage:(UIImage*)img
{
	if (_mapGrid)
	{
		_mapGrid.image = img;
	}
}

- (IBAction)detailDone
{
	if (currentMap == nil) return;
	
	currentMap.gridOffset = _mapGrid.gridOffset;
	currentMap.gridScale = _mapGrid.gridScale;
	
	[currentMap saveFile];
	
	if (![_maps containsObject:currentMap])
		[_maps addObject:currentMap];
	
	currentMap = nil;
	
	if (_mapList)
		[_mapList reloadData];
	
	[self formatMapImage:nil];
}

- (IBAction)newMap:(id)sender
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
		photoLibrary.modalPresentationStyle = UIModalPresentationCurrentContext;
		photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		//photoLibrary.allowsEditing = true;
		photoLibrary.delegate = self;
		[self presentViewController:photoLibrary animated:YES completion:nil];
	}
}

- (IBAction)share:(id)sender
{
	if (currentMap)
	{
		[currentMap shareFromViewController:self];
	}
}

- (void)addMap:(Map*)map
{
	if ([_maps containsObject:map])
		[_maps addObject:map];
	if (_mapList) [_mapList reloadData];
}

- (void)showMapDetail
{
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row < _maps.count)
	{
		Map *m = [_maps objectAtIndex:indexPath.row];
		MapCell *cell = (MapCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Map" forIndexPath:indexPath];
	
		if (cell && m)
		{
			cell.image.image = m.miniImage;
		}
		
		return cell;
	}
	else
	{
		UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewMap" forIndexPath:indexPath];
		return cell;
	}
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _maps.count + 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row < _maps.count)
	{
		Map *m = [_maps objectAtIndex:indexPath.row];
		if (m && _mapDetail)
		{
			currentMap = m;
			[self formatMapImage:m.image];
			if (_mapGrid)
			{
				_mapGrid.gridOffset = m.gridOffset;
				_mapGrid.gridScale = m.gridScale;
			}

			[self showMapDetail];
		}
	}
}

- (IBAction)pickImage:(id)sender
{
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
	currentMap.image = img;
	[self formatMapImage:img];
	
	if (popover)
	{
		[popover dismissPopoverAnimated:YES];
	}
	else
	{
		[_mapDetail dismissViewControllerAnimated:YES completion:NULL];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[_mapDetail dismissViewControllerAnimated:YES completion:NULL];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _mapGrid;
}

- (IBAction)toggleEditGrid:(id)sender
{
	if (_mapGrid && [sender isKindOfClass:[UISwitch class]])
	{
		_mapGrid.drawGrid = [sender isOn];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

@end
