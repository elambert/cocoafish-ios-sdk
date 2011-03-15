//
//  AnnotationView.m
//  GoogleMap
//
//  Created by Wei Kong on 8/26/09.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "AnnotationView.h"
#import "Annotation.h"


#pragma mark -
#pragma mark AnnotationView implementation


@implementation AnnotationView

@synthesize mapView;
@synthesize annotation;

-(id)initWithAnnotation:(id <MKAnnotation>)_annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithAnnotation:_annotation reuseIdentifier:reuseIdentifier]) {
		self.enabled = YES;
		self.canShowCallout = YES;
		self.multipleTouchEnabled = YES;
		self.animatesDrop = NO;
		if (annotation.place != nil ) {
			UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			self.rightCalloutAccessoryView = rightButton;
		} 

	}
	return self;
}

#pragma mark -
#pragma mark Handling events

// Reference: iPhone Application Programming Guide > Device Support > Displaying Maps and Annotations > Displaying Annotations > Handling Events in an Annotation View

/*-(void)touchsBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// The view is configured for single touches only.
	UITouch *aTouch = [touches anyObject];
	self.startLocation = [aTouch locationInView:[self superview]];
	self.originalCenter = self.center;
	
	[super touchesBegan:touches withEvent:event];

}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *aTouch = [touches anyObject];
	CGPoint newLocation = [aTouch locationInView:[self superview]];
	CGPoint newCenter;
	
	// If the user's finger moved more than 5 pixels, begin the drag.
	if ((abs(newLocation.x - self.startLocation.x) > 5.0 || (abs(newLocation.y - self.startLocation.y) > 5.0))) {
		self.isMoving = YES;
	}
		
	// If drgging has begun, adust the position of the view.
	if (self.isMoving) {
		newCenter.x = self.originalCenter.x + (newLocation.x - self.startLocation.x);
		newCenter.y = self.originalCenter.y + (newLocation.y - self.startLocation.y);
		self.center = newCenter;
	} else {
		// let the parent class handle it.
		[super touchesMoved:touches withEvent:event];
	}
}
		
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self.isMoving) {
		// Update the map coordinate to reflect the new position.
		CGPoint newCenter = self.center;
		Annotation* theAnnotation = (Annotation *)self.annotation;
		CLLocationCoordinate2D newCoordinate = [self.mapView convertPoint:newCenter toCoordinateFromView:self.superview];
		[theAnnotation changeCoordinate:newCoordinate];
		
		// Cleanup the state information.
		self.startLocation = CGPointZero;
		self.originalCenter = CGPointZero;
		self.isMoving = 0;
	} else {
		[super touchesEnded:touches withEvent:event];
	}
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self.isMoving) {
		// Move the view back to its starting point.
		self.center = self.originalCenter;
		
		// Clean up the state information.
		self.startLocation = CGPointZero;
		self.originalCenter = CGPointZero;
		self.isMoving = NO;
	} else {
		[super touchesCancelled:touches withEvent:event];
	}
}
*/
-(void)dealloc
{
	mapView = nil;
	[annotation release];
	[super dealloc];
}

@end
