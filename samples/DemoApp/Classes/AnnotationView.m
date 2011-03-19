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

-(id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
		self.enabled = YES;
		self.canShowCallout = YES;
		self.multipleTouchEnabled = YES;
		self.animatesDrop = NO;
		if (((Annotation *)annotation).place != nil ) {
			UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			self.rightCalloutAccessoryView = rightButton;
		} 

	}
	return self;
}

-(void)dealloc
{
	mapView = nil;
	[super dealloc];
}

@end
