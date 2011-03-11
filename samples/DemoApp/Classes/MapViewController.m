//
//  MapViewController.m
//  Demo
//
//  Created by Wei Kong on 10/7/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "MapViewController.h"
#import "Annotation.h"
#import "AnnotationView.h"
#import "PlaceViewController.h"

@implementation MapViewController

@synthesize mapView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[mapView release];
    [super dealloc];
}

-(void)reloadData
{
	
	if (zoomed) {
		return;
	}
	if ([annotations count] > 0) {
		[self.mapView addAnnotations:annotations];
		
		[self zoomIn:nil annotations:annotations];
	} 
	
}

// Zoom in to the center of the annotations.
// if userLocation is specified, zoom in to user location only
-(void)zoomIn:(CLLocation *)userLocation annotations:(NSArray *)inputAnnotations {
	
	int count = [inputAnnotations count];
	MKCoordinateRegion zoomRegion;
	
	CLLocationCoordinate2D topLeft, bottomRight;
	int i = 0;
	
	if (userLocation != nil) {
		topLeft = userLocation.coordinate;
	} else {
		if (count == 0) {
			return;
		}
		topLeft = [[inputAnnotations objectAtIndex:i++] coordinate];
		
	}
	bottomRight = topLeft;
	
	for (; i < count; i++) {
		CLLocationCoordinate2D curcoordinate = [[inputAnnotations objectAtIndex:i] coordinate];
		topLeft.latitude = MIN(topLeft.latitude, curcoordinate.latitude);
		topLeft.longitude = MIN(topLeft.longitude, curcoordinate.longitude);
		bottomRight.latitude = MAX(bottomRight.latitude, curcoordinate.latitude);
		bottomRight.longitude = MAX(bottomRight.longitude, curcoordinate.longitude);
		
	}
	
	CLLocation *locTopLeft = [[CLLocation alloc] initWithLatitude:topLeft.latitude longitude:topLeft.longitude];
	CLLocation *locBottomRight = [[CLLocation alloc] initWithLatitude:bottomRight.latitude longitude:bottomRight.longitude];
	
	CLLocationDistance meters = [locTopLeft distanceFromLocation:locBottomRight];
	
	zoomRegion.center.latitude = (topLeft.latitude + bottomRight.latitude) / 2.0;
	zoomRegion.center.longitude = (topLeft.longitude + bottomRight.longitude) /2.0;
	
	//region.span.latitudeDelta = meters / 111319.5;
	
	if (meters == 0) {
		zoomRegion.span.latitudeDelta = 0.008;
	} else {
		zoomRegion.span.latitudeDelta = meters /82000.5;
		
	}
	zoomRegion.span.longitudeDelta = 0.0;
	
	
	[mapView setRegion:[mapView regionThatFits:zoomRegion] animated:FALSE];
	zoomed = YES;
	
	[locTopLeft release];
	[locBottomRight release];
}

-(void)showPlaces:(NSArray *)places
{
	if (!annotations) {
		annotations = [[NSMutableArray alloc] init];
	} else {
		// remove old annotations
		[self.mapView removeAnnotations:annotations];
		
		[annotations removeAllObjects];
	}
	for (CCPlace *place in places) {
		Annotation *annotation = [[Annotation alloc] initWithPlace:place];
		if (annotation == nil) {
			continue;
		}
		[annotations addObject:annotation];
		[annotation release];
	}
	zoomed = NO;
	[self reloadData];
	
}


#pragma mark -
#pragma mark MKMapViewDelegate methods
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	if ([annotations count] == 0) {
		return;
	}
	Annotation *selectAnnotation = nil;
	
	selectAnnotation = [annotations objectAtIndex:0];
	
	
	for (AnnotationView *annotationView in views) {
		if ([annotationView.annotation isEqual:selectAnnotation]) {
			[self.mapView selectAnnotation:selectAnnotation animated:NO];
		}
	}
	
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	//debug_NSLog(@"View for Annotation is called with latitude [%+.6f], longitude %+.6f, dish [%@], place [%@]",
	//	  annotation.coordinate.latitude, annotation.coordinate.longitude, annotation.title, annotation.subtitle);
	
	// will not show a pin for user location , otherwise click on user location pin will crash the app
	if ([annotation isEqual:self.mapView.userLocation]) {
		return nil;
	}
	// regular pins
	
	AnnotationView *annotationView = nil;
	if (((Annotation *)annotation).place) { 			
		annotationView = (AnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
		if (annotationView == nil) {
			annotationView = [[[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"] autorelease];	
		}  
	}
	annotationView.mapView = self.mapView;
	return annotationView;
	
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	PlaceViewController *placeController = [[PlaceViewController alloc] initWithNibName:@"PlaceViewController" bundle:nil];
	placeController.place = ((Annotation *)view.annotation).place;
	UIViewController *tmp = (UIViewController *)self.view.superview.nextResponder;
	[tmp.navigationController pushViewController:placeController animated:YES];
	[placeController release];
}
@end
