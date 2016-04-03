//
//  ContentTransformResult.h
//  gamerkit
//
//  Created by Benjamin Taggart on 4/1/16.
//  Copyright © 2016 Abject Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentObject.h"

@interface ContentTransformResult : NSObject

- (instancetype)initWithAction:(ContentObjectAction)action;

@property (nonatomic, readonly, assign) ContentObjectAction action;
@property (nonatomic, readonly, assign) BOOL succeeded;

// preview
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly, strong) UIImage *image;

// webview, readonlywebview
@property (nonatomic, readonly, copy) NSString *html;

// share, exporttopdf
@property (nonatomic, readonly, strong) NSURL *file;

// print
@property (nonatomic, readonly, strong) UIPrintFormatter *printFormatter;

@end
