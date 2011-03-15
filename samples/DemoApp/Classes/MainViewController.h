//
//  MainViewController.h
//  Demo
//
//  Created by Wei Kong on 10/7/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "MapKit/MapKit.h"
#import "ListViewController.h"
#import "CCNetworkManager.h"

@interface MainViewController : UIViewController <CCNetworkManagerDelegate> {
	UIBarButtonItem *viewSwitchButton;
	MapViewController *mapViewController;
	ListViewController *listViewController;
	NSOperation *processingRequest;
	UINavigationController *navController;
	CCNetworkManager *ccNetworkManager;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *viewSwitchButton;
@property (nonatomic, retain) MapViewController *mapViewController;
@property (nonatomic, retain) ListViewController *listViewController;
@property (nonatomic, retain) NSOperation *processingRequest;

-(IBAction)switchView;
-(IBAction)getPlaces;
@end


