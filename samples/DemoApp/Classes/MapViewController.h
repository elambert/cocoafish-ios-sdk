//
//  MapViewController.h
//  Demo
//
//  Created by Wei Kong on 10/7/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MapViewController : UIViewController<MKMapViewDelegate> {

	BOOL zoomed;
	NSMutableArray *annotations;
	MKMapView *mapView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

-(void)showPlaces:(NSArray *)places;
-(void)zoomIn:(CLLocation *)userLocation annotations:(NSArray *)inputAnnotations;
@end
