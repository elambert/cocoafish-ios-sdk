//
//  Annotation.m
//  GoogleMap
//
//  Created by Wei Kong on 8/26/09.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "Annotation.h"
#import "CCPlace.h"

@implementation Annotation
@synthesize place;
@synthesize coordinate;

-(id)initWithPlace:(CCPlace *)_place
{
		
	if ((self = [super init])) {
		self.place = _place;	
		/*CLLocationCoordinate2D instanceCoordinate;
		instanceCoordinate.latitude = [place.location.latitude doubleValue];
		instanceCoordinate.longitude = [place.longitude.longitude doubleValue];*/
		[self setCoordinate:place.location.coordinate];

	}
	return self;
}


/*-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle
{
	if (self = [super init]) {
		[self changeCoordinate:coordinate];
		self.title = [title copy];
		self.subtitle = [subtitle copy];		
	}
	return self;
}*/
#pragma mark -
#pragma mark MKAnnotation Methods

-(NSString *)title {
	return place.name;
}

- (NSString *)subtitle {

	return place.address;
}

#pragma mark -
#pragma mark Change Coordinate

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	coordinate = newCoordinate;
	
	// Try to reserve geocode here
//	MKReverseGeocoder *reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:self.coordinate];
//	reverseGeocoder.delegate = self;
//	[reverseGeocoder start];
}

#pragma mark -
#pragma mark MKReverseGeocoderDelegate Methods

/*-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark 
{
	[self notifyCalloutInfo:placemark];
	[geocoder release];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	[self notifyCalloutInfo:nil];
	[geocoder release];
}

#pragma mark -
#pragma mark MKAnnotationView Notification

- (void)notifyCalloutInfo:(MKPlacemark *)placemark {
	[self willChangeValueForKey:@"subtitle"]; //workaround for SDK 3.0, otherwise callout info won't update
	self.placemark = placemark;
	[self didChangeValueForKey:@"subtitle"]; //workaround for SDK 3.0, otherwise callout info won't update
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"MKAnnotationCalloutInfoDidChangeNotification" object:self]];
}
*/
#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
//XXX CAUSE BUG WHY?	self.place = nil;
	[super dealloc];
}


@end
