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
#import "DataManager.h"
#import "MapCell.h"

@implementation MapsController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
	{
		// load map xml files.
		NSFileManager *fm = [NSFileManager defaultManager];
		DataManager *dm = [DataManager getDataManager];
		NSString *path = [dm.docsPath stringByAppendingPathComponent:@"Media"];
		
		if (![fm fileExistsAtPath:path])
			[fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
		
		NSArray *files = [fm contentsOfDirectoryAtPath:path error:nil];
		NSEnumerator *enumerator = [files objectEnumerator];
		NSString *file;
		
		maps = [NSMutableArray arrayWithCapacity:files.count];
		while (file = [enumerator nextObject])
		{
			if ([file hasSuffix: @".map"])
			{
				Map *m = [[Map alloc] initWithFileAtPath:[path stringByAppendingPathComponent:file]];
				if (m)
				{
					[maps addObject:m];
				}
			}
		}
    }
    return self;
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
	
	currentMap.name = _mapName.text;
	currentMap.gridOffset = _mapGrid.gridOffset;
	currentMap.gridScale = _mapGrid.gridScale;
	
	[currentMap writeToFile];
	
	if (![maps containsObject:currentMap])
		[maps addObject:currentMap];
	
	currentMap = nil;
	
	if (_mapList)
		[_mapList reloadData];
	
	[self formatMapImage:nil];
	_mapName.text = @"New Map";
}

- (IBAction)newMap:(id)sender
{
	DataManager* dm = [DataManager getDataManager];
	
	if (dm)
	{
		cachedButton = sender;
		[dm pickImportSource:self forClass:[Map class] withView:self andButton:sender];
	}
}

- (IBAction)pickImage:(id)sender
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
		[currentMap share:self];
	}
}

- (void)addMap:(Map*)map
{
	if (![maps containsObject:map])
		[maps addObject:map];
	if (_mapList) [_mapList reloadData];
}

- (void)showMapDetail
{
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row < maps.count)
	{
		Map *m = [maps objectAtIndex:indexPath.row];
		MapCell *cell = (MapCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Map" forIndexPath:indexPath];
	
		if (cell && m)
		{
			cell.name.text = m.name;
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
	return maps.count + 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row < maps.count)
	{
		Map *m = [maps objectAtIndex:indexPath.row];
		if (m && _mapDetail)
		{
			currentMap = m;
			[self formatMapImage:m.image];
			if (_mapGrid)
			{
				_mapGrid.gridOffset = m.gridOffset;
				_mapGrid.gridScale = m.gridScale;
			}
			if (_mapName) _mapName.text = m.name;

			[self showMapDetail];
		}
	}
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

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSUInteger idx[2];
		[indexPath getIndexes: idx];
		
		if (idx[0] == 0 && idx[1] < maps.count)
		{
			Map *m = [maps objectAtIndex:idx[1]];
			
			if (m)
			{
				NSFileManager *fm = [NSFileManager defaultManager];
				if (m.path != nil && [fm isDeletableFileAtPath:m.path])
				{
					[fm removeItemAtPath:m.path error:NULL];
				}
				[maps removeObjectAtIndex:idx[1]];
			}
		}
	}
	
	[tableView reloadData];
}
*/

- (BOOL)modalPicker:(ModalPicker*)picker donePicking:(NSArray*)results
{
	NSString *result = [results objectAtIndex:0];
	if ([result caseInsensitiveCompare:@"Shared Content"] == NSOrderedSame)
	{
	/*
		SharedContentController *sharedController = [[RPG_ToolkitAppDelegate sharedApp] sharedContentController];
		if (sharedController)
		{
			if (bPad)
			{
				[sharedController showAsPopoverFromButton:cachedButton];
			}
			else
			{
				[self presentViewController:sharedController animated:YES completion:NULL];
			}
			[sharedController displaySharedContentForClass:[Map class] delegate:self];
		}
	*/
	}
	else if ([result caseInsensitiveCompare:@"Create New"] == NSOrderedSame)
	{
		if (_mapName) _mapName.text = @"New Map";
		if (_mapDetail)
		{
			currentMap = [[Map alloc] init];
			[self showMapDetail];
		}
	}
	return YES;
}

- (void)modalPicker:(ModalPicker*)picker selectionChanged:(NSInteger) newIndex forColumn:(NSInteger)column
{
}

- (void)modalPicker:(ModalPicker *)picker isDoneHiding:(BOOL)animated fromResults:(NSArray *)results
{
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
