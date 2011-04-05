//
//  APIsAppDelegate.h
//  APIs
//
//  Created by Wei Kong on 3/18/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cocoafish.h"

@interface APIsAppDelegate : NSObject <UIApplicationDelegate> {
    CCPlace *_testPlace;
    CCPhoto *_testPhoto;
    CCEvent *_testEvent;
}

@property (nonatomic, retain) CCPlace *testPlace;
@property (nonatomic, retain) CCPhoto *testPhoto;
@property (nonatomic, retain) CCEvent *testEvent;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
