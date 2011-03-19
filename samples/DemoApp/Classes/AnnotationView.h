//
//  AnnotationView.h
//  GoogleMap
//
//  Created by Wei Kong on 8/26/09.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class Annotation;

@interface AnnotationView : MKPinAnnotationView {
@private
	MKMapView* mapView;
}

@property (nonatomic, assign) MKMapView* mapView;

@end
