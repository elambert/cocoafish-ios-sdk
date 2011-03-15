//
//  Annotation.h
//  GoogleMap
//
//  Created by Wei Kong on 8/26/09.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CCPlace.h"

@interface Annotation : NSObject<MKAnnotation> {
@private
	CLLocationCoordinate2D coordinate;
	CCPlace *place;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) CCPlace *place;
//@property (nonatomic, retain) MKPlacemark *placemark;

-(id)initWithPlace:(CCPlace *)place;
//-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle;
-(void)setCoordinate:(CLLocationCoordinate2D)coordinate;

//-(void)notifyCalloutInfo:(MKPlacemark *)placemark;
@end
