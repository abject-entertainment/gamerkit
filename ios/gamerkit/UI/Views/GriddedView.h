//
//  GriddedView.h
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 9/1/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

enum _TouchState
{
	TS_NoTouches,
	TS_Panning,
	TS_Zooming,
	TS_Ignoring
};

typedef enum _TouchState TouchState;

@interface GriddedView : UIView {
	CGPoint imageOffset;
	CGFloat imageScale;
	CGFloat minScale;
	
	NSMutableArray *touches;
	TouchState touchState;
	int touchAnchor;
	CGPoint touchStart;
	CGFloat touchDistance;
	CGPoint tempPoint;
	CGFloat tempScale;
}

@property (nonatomic, strong, setter=setImage:) UIImage *image;
@property (nonatomic, setter=setDrawGrid:) BOOL drawGrid;

@property (nonatomic) CGPoint gridOffset;
@property (nonatomic) CGFloat gridScale;

@end
