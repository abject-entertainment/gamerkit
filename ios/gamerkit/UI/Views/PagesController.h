//
//  PageController.h
//  gamerkit
//
//  Created by Benjamin Taggart on 5/20/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"

@class Character;

@interface PagesController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, PageViewControllerDelegate>

- (void)addPageForCharacter:(Character*)character;

+ (PagesController*)getPages;

@end
