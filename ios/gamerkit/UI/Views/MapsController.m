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

@implementation MapsController
@synthesize mapList;
@synthesize mapDetail, mapGrid, mapName, shareButton, photoLibrary;
@synthesize doneButton, doneTarget, doneAction;

- (NSObject<MapSelectionDelegate>*)selectionDelegate { return _selectionDelegate; }
- (void)setSelectionDelegate:(NSObject <MapSelectionDelegate>*)selDel
{ _selectionDelegate = selDel; if (mapList) [mapList reloadData]; }

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
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
				Map *m = [[Map alloc] initWithFileAtPath:[path stringByAppendingPathComponent:file] fully:NO];
				if (m)
				{
					[maps addObject:m];
				}
			}
		}
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES; // bPad || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)formatMapImage:(UIImage*)img
{
	if (mapGrid)
	{
		mapGrid.image = img;
	}
}

- (IBAction)detailDone
{
	if (currentMap == nil) return;
	
	currentMap.name = mapName.text;
	currentMap.gridOffset = mapGrid.gridOffset;
	currentMap.gridScale = mapGrid.gridScale;
	
	[currentMap writeToFile];
	
	if (![currentMap isShared])
		[currentMap unload];
	
	if (![maps containsObject:currentMap])
		[maps addObject:currentMap];
	
	currentMap = nil;
	
	if (mapList)
		[mapList reloadData];
	
	[self formatMapImage:nil];
	mapName.text = @"New Map";
	
	/*
	if (cachedVC)
	{
		AppDelegate *app = [RPG_ToolkitAppDelegate sharedApp];
		if (app && app.tabBarController)
		{
			app.tabBarController.delegate = cachedDel;
			cachedDel = nil;
			
			if (app.splitViewController)
				[app.splitViewController setViewControllers:[NSArray arrayWithObjects:[app.splitViewController.viewControllers objectAtIndex:0], cachedVC, nil]];
			cachedVC = nil;
		}
	}
	else
	{
		[self dismissViewControllerAnimated:YES completion:NULL];
	}
	*/
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
	if (photoLibrary == nil)
	{
		photoLibrary = [[UIImagePickerController alloc] init];
		photoLibrary.delegate = self;
	}
	
	/*if (bPad)
	{
		if (popover == nil)
		{
			CGSize sz = photoLibrary.view.frame.size;
			popover = [[UIPopoverController alloc] initWithContentViewController:photoLibrary];
			popover.popoverContentSize = sz;
		}
		
		[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else if (self.presentedViewController == mapDetail && photoLibrary) */
	{
		photoLibrary.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[mapDetail presentViewController:photoLibrary animated:YES completion:NULL];
	}
}

- (IBAction)share:(id)sender
{
	if (currentMap)
	{
		if ([currentMap isShared])
		{
			[currentMap stopSharing];
		}
		else 
		{
			[currentMap startSharing:currentMap.name];
		}
		
		if (shareButton)
		{
			((UIBarButtonItem*)sender).title = [currentMap isShared]?@"Stop Sharing":@"Share";
		}
	}
}

- (void)addMap:(Map*)map
{
	if (![maps containsObject:map])
		[maps addObject:map];
	if (mapList) [mapList reloadData];
}

- (void)showMapDetail
{
	/*
	RPG_ToolkitAppDelegate *app = [RPG_ToolkitAppDelegate sharedApp];
	if (app && app.splitViewController)
	{
		if (app.tabBarController && app.tabBarController.delegate != self)
		{
			cachedDel = app.tabBarController.delegate;
			app.tabBarController.delegate = self;
		}
		if (cachedVC == nil)
		{
			cachedVC = [app.splitViewController.viewControllers objectAtIndex:1];
			[app.splitViewController setViewControllers:[NSArray arrayWithObjects:[app.splitViewController.viewControllers objectAtIndex:0], mapDetail, nil]];
		}
	}
	else
	{
		mapDetail.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentViewController:mapDetail animated:YES completion:NULL];
	}
	*/
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MapCell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MapCell"];
	}
	
	if (cell != nil)
	{
		NSUInteger idx[2];
		[indexPath getIndexes: idx];
		
		if (idx[0] == 0 && idx[1] < maps.count)
		{
			Map *m = [maps objectAtIndex:idx[1]];
			if (m)
			{
				cell.textLabel.text = m.name;
				cell.imageView.image = m.miniImage;
				if (_selectionDelegate)
				{
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
					if ([cell.accessoryView isKindOfClass:[UIButton class]])
					{
						[(UIButton*)cell.accessoryView addTarget:self 
														  action:@selector(disclosureTapped:event:) 
												forControlEvents:UIControlEventTouchUpInside];
					}
				}
				else
				{
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				}
			}
			else 
			{
				cell.textLabel.text = @"error";
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			
		}
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return maps.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (cachedVC)
	{
		[self detailDone];
	}
	
	NSUInteger idx[2];
	[indexPath getIndexes: idx];
	
	if (idx[0] == 0 && idx[1] < maps.count)
	{
		Map *m = [maps objectAtIndex:idx[1]];
		if (_selectionDelegate)
		{
			[_selectionDelegate mapSelected:m];
			self.selectionDelegate = nil;
		}
		else if (m && mapDetail)
		{
			currentMap = m;
			[currentMap fullyLoad];
			[self formatMapImage:m.image];
			if (mapGrid)
			{
				mapGrid.gridOffset = m.gridOffset;
				mapGrid.gridScale = m.gridScale;
			}
			if (mapName) mapName.text = m.name;
			if (shareButton) shareButton.title = [m isShared]?@"Stop Sharing":@"Share";

			[self showMapDetail];
		}
	}
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	if (viewController != mapDetail)
	{
		[cachedDel tabBarController:tabBarController didSelectViewController:viewController];
		
		[self detailDone];
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
		[mapDetail dismissViewControllerAnimated:YES completion:NULL];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[mapDetail dismissViewControllerAnimated:YES completion:NULL];
}

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
		if (mapName) mapName.text = @"New Map";
		if (mapDetail)
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

- (void)sharedContentDone:(SharedContentController*)controller
{
	if (self.presentedViewController && [self.presentedViewController isKindOfClass:[SharedContentController class]])
		[self dismissViewControllerAnimated:YES completion:NULL];
	if (mapList) [mapList reloadData];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return mapGrid;
}

- (IBAction)toggleEditGrid:(id)sender
{
	if (mapGrid && [sender isKindOfClass:[UISwitch class]])
	{
		mapGrid.drawGrid = [sender isOn];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)done:(id)sender
{
	if (cachedVC)
		[self detailDone];
	
	if (_selectionDelegate)
	{
		[_selectionDelegate mapSelected:nil];
		self.selectionDelegate = nil;
	}
	else
	{
		if (doneTarget && doneAction && [doneTarget respondsToSelector:doneAction])
		{
			[doneTarget performSelector:doneAction withObject:sender];
		}
	}
}

@end
