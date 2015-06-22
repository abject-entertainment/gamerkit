//
//  GriddedView.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 9/1/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "GriddedView.h"


#define UNSCALED_GRID_SIZE 20

@implementation GriddedView

- (void)setImage:(UIImage *)img
{
	_image = img;
	[self setNeedsDisplay];
	imageOffset = CGPointMake(0,0);
	imageScale = 1.0f;
	
	minScale = self.bounds.size.width / (_image.size.width + UNSCALED_GRID_SIZE + UNSCALED_GRID_SIZE);
	CGFloat wScale = self.bounds.size.height / (_image.size.height + UNSCALED_GRID_SIZE + UNSCALED_GRID_SIZE);
	minScale = (minScale<wScale)?minScale:wScale;
	minScale = (minScale<1.0f)?minScale:1.0f;
}

- (void)setDrawGrid:(BOOL)dg
{
	_drawGrid=dg;

	[self setNeedsDisplay];
}

- (void)updateTouchState
{
	if (touches.count == 0)
	{
		touchState = TS_NoTouches;
		touchAnchor = -1;
		return;
	}
	
	if (touches.count > 2)
	{
		touchState = TS_Ignoring;
		touchAnchor = -1;
		return;
	}
	
	if (touches.count >= 1)
	{
		touchState = TS_Panning;
		touchAnchor = 0;
		touchStart = [[touches objectAtIndex:0] locationInView:self];
		tempPoint = _drawGrid?_gridOffset:imageOffset;
	}
	
	if (touches.count == 2)
	{
		touchState = TS_Zooming;
		CGPoint touch2 = [[touches objectAtIndex:1] locationInView:self];
		CGFloat dx = touch2.x - touchStart.x;
		CGFloat dy = touch2.y - touchStart.y;
		touchDistance = (dx*dx) + (dy*dy);
		tempScale = _drawGrid?_gridScale:imageScale;
	}
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) 
	{
		_gridScale = 1.0f;
		_gridOffset.x = _gridOffset.y = 0.0f;
		imageScale = 1.0f;
		imageOffset.x = imageOffset.y = 0.0f;
		
		touches = [NSMutableArray arrayWithCapacity:5];
		[self updateTouchState];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)inTouches withEvent:(UIEvent *)event
{
	fprintf(stdout, "Touch Began: %lu/%lu\n", (unsigned long)inTouches.count, (unsigned long)[[event allTouches] count]);
	
	NSEnumerator *enumerator = [inTouches objectEnumerator];
	UITouch *t = nil;
	while (t = [enumerator nextObject])
	{
		if (![touches containsObject:t])
		{
			[touches addObject:t];
		}
	}
	
	[self updateTouchState];
}

- (void)touchesMoved:(NSSet *)inTouches withEvent:(UIEvent *)event
{
	fprintf(stdout, "Touch Moved: %lu/%lu\n", (unsigned long)inTouches.count, (unsigned long)[[event allTouches] count]);
	
	if (touchAnchor < 0) return;
	
	if (touchState >= TS_Panning && touchState <= TS_Zooming)
	{
		CGPoint newAnchor = [[touches objectAtIndex: touchAnchor] locationInView:self];
		if (_drawGrid)
		{
			_gridOffset.x = tempPoint.x + ((newAnchor.x - touchStart.x) / _gridScale);
			_gridOffset.y = tempPoint.y + ((newAnchor.y - touchStart.y) / _gridScale);
			
			_gridOffset.x = (int)_gridOffset.x % UNSCALED_GRID_SIZE;
			_gridOffset.y = (int)_gridOffset.y % UNSCALED_GRID_SIZE;
			
			if (_gridOffset.x < 0) _gridOffset.x += UNSCALED_GRID_SIZE;
			if (_gridOffset.y < 0) _gridOffset.y += UNSCALED_GRID_SIZE;
		}
		else 
		{
			imageOffset.x = tempPoint.x + ((newAnchor.x - touchStart.x) / imageScale);
			imageOffset.y = tempPoint.y + ((newAnchor.y - touchStart.y) / imageScale);
			
			if (imageOffset.x > UNSCALED_GRID_SIZE) imageOffset.x = UNSCALED_GRID_SIZE;
			if (imageOffset.y > UNSCALED_GRID_SIZE) imageOffset.y = UNSCALED_GRID_SIZE;
			
			CGFloat maxDim = (_image.size.width + UNSCALED_GRID_SIZE) * imageScale;
			maxDim = (((maxDim > self.bounds.size.width)?maxDim:self.bounds.size.width) - self.bounds.size.width) / imageScale;
			if (imageOffset.x < -maxDim) imageOffset.x = -maxDim;
			maxDim = (_image.size.height + UNSCALED_GRID_SIZE) * imageScale;
			maxDim = (((maxDim > self.bounds.size.height)?maxDim:self.bounds.size.height) - self.bounds.size.height) / imageScale;
			if (imageOffset.y < -maxDim) imageOffset.y = -maxDim; 
		}

		if (touchState == TS_Zooming)
		{
			CGPoint touch2 = [[touches objectAtIndex:1] locationInView:self];
			CGFloat scalex = touch2.x-newAnchor.x;
			CGFloat scaley = touch2.y-newAnchor.y;
			scalex = (((scalex*scalex) + (scaley*scaley)) / touchDistance) * tempScale;
			if (_drawGrid)
				_gridScale = (scalex>(1.0f/UNSCALED_GRID_SIZE))?scalex:(1.0f/UNSCALED_GRID_SIZE);
			else
				imageScale = (scalex>minScale)?scalex:minScale;
		}
	}
	
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)inTouches withEvent:(UIEvent *)event
{
	fprintf(stdout, "Touch Ended: %lu/%lu\n", (unsigned long)inTouches.count, (unsigned long)[[event allTouches] count]);

	UITouch *oldAnchor = [touches objectAtIndex:touchAnchor];
	
	NSEnumerator *enumerator = [inTouches objectEnumerator];
	UITouch *t = nil;
	while (t = [enumerator nextObject])
	{
		if (t == oldAnchor)
		{
			touchAnchor = -1;
		}
		if ([touches containsObject:t])
		{
			[touches removeObject:t];
		}
	}
	
	[self updateTouchState];
	[self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)inTouches withEvent:(UIEvent *)event
{
	fprintf(stdout, "Touch Cancelled: %lu/%lu\n", (unsigned long)inTouches.count, (unsigned long)[[event allTouches] count]);
	
	UITouch *oldAnchor = [touches objectAtIndex:touchAnchor];
	
	NSEnumerator *enumerator = [inTouches objectEnumerator];
	UITouch *t = nil;
	while (t = [enumerator nextObject])
	{
		if (t == oldAnchor)
		{
			touchAnchor = -1;
		}
		if ([touches containsObject:t])
		{
			[touches removeObject:t];
		}
	}

	[self updateTouchState];
}

- (void)drawRect:(CGRect)rect {
	if (_image)
	{
		CGRect imgRect = CGRectMake(imageOffset.x*imageScale, imageOffset.y*imageScale, _image.size.width*imageScale, _image.size.height*imageScale);
		[_image drawInRect:imgRect];
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFont(ctx, CGFontCreateWithFontName((__bridge CFStringRef)@"Helvetica"));
	CGContextSetFontSize(ctx, 12.0f);
	CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1.0f, -1.0f));

//	char txt[128];
//	sprintf(txt, "image scale: %.4f, offset: %.4f, %.4f", imageScale, imageOffset.x, imageOffset.y);
//	CGContextShowTextAtPoint(ctx, 20, 20, txt, strlen(txt));
//	sprintf(txt, "grid  scale: %.4f, offset: %.4f, %.4f", gridScale, gridOffset.x, gridOffset.y);
//	CGContextShowTextAtPoint(ctx, 20, 40, txt, strlen(txt));

	if (_drawGrid)
	{
		CGContextSetLineWidth(ctx, 1.0f);
		CGContextSetRGBStrokeColor(ctx, 0.25f, 1.0f, 1.0f, 0.5f);
		
		CGFloat gridSize = UNSCALED_GRID_SIZE * _gridScale * imageScale;
		
		CGFloat start = (imageOffset.x*imageScale) + ((int)(_gridOffset.x * _gridScale * imageScale) % (int)gridSize);
		for (int i = (int)start; i <= (imageOffset.x + _image.size.width)*imageScale; i += gridSize)
		{
			CGContextMoveToPoint(ctx, i, (imageOffset.y + _image.size.height)*imageScale);
			CGContextAddLineToPoint(ctx, i, imageOffset.y * imageScale);
			CGContextStrokePath(ctx);
		}
		start = (imageOffset.y*imageScale) + ((int)(_gridOffset.y * _gridScale * imageScale) % (int)gridSize);
		for (int i = (int)start; i < (imageOffset.y + _image.size.height)*imageScale; i += gridSize)
		{
			CGContextMoveToPoint(ctx, (imageOffset.x + _image.size.width)*imageScale, i);
			CGContextAddLineToPoint(ctx, imageOffset.x * imageScale, i);
			CGContextStrokePath(ctx);
		}
	}
	
	CGContextFlush(ctx);
}

@end
