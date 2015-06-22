//
//  MapDetailController.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 9/5/11.
//  Copyright 2011 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GriddedView.h"

@interface MapDetailController : UIViewController
{
	GriddedView *grid;
}

@property (nonatomic, retain) IBOutlet GriddedView *grid;

@end
