//
//  APIsAppDelegate.m
//  APIs
//
//  Created by Wei Kong on 3/18/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "APIsAppDelegate.h"

// Alternatively you can use your oauth token and secret instead of the app key for security purpose
static NSString * const oauthConsumerKey = @"mKnmYaRVFZjKCeKv0dwyXhzZb5AKbGys";
static NSString * const oauthConsumerSecret = @"tr7fy3sFtfbKsKI5AttcK1UeG01Bwfhb";

// If you want to add facebook support, please set the facebook app id here.
static NSString * const facebookAppId = @"109836395704353";

@implementation APIsAppDelegate

@synthesize testPlace = _testPlace;
@synthesize testPhoto = _testPhoto;
@synthesize window=_window;

@synthesize navigationController=_navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Cocoafish initializeWithOauthConsumerKey:oauthConsumerKey consumerSecret:oauthConsumerSecret customAppIds:[NSDictionary dictionaryWithObject:facebookAppId forKey:@"Facebook"]];
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
                                                                                                                                                                                        
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	return [[Cocoafish defaultCocoafish] handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [_testPlace release];
    [_testPhoto release];
    [super dealloc];
}


@end
