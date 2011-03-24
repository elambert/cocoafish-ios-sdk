//
//  CocoafishLibrary.h
//  Cocoafish-ios-demo
//
//  Created by Michael Goff on 7/9/08.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#ifdef _DEBUG
#define debug_NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define debug_NSLog(format, ...)
#endif

NSString* getUniqueIdentifier();

// iOS Version
float osVersion();

NSString * timeElapsedFrom(NSDate *startDate);

UIImage *scaleAndRotateImage(UIImage *img, int kMaxResolution);