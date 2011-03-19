//
//  CCPlace.h
//  Demo
//
//  Created by Wei Kong on 12/15/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCObject.h"
#import <CoreLocation/CoreLocation.h>

@interface CCPlace : CCObject {
	
	NSString *_name;
	NSString *_address1;
	NSString *_address2;
	NSString *_crossStreet;
	NSString *_city;
	NSString *_state; // can be used as region or province for international address
	NSString *_country;
	NSString *_phone;
	CLLocation *_location;
}

@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, retain, readonly) NSString *address1;
@property (nonatomic, retain, readonly) NSString *address2;
@property (nonatomic, retain, readonly) NSString *crossStreet;
@property (nonatomic, retain, readonly) NSString *city;
@property (nonatomic, retain, readonly) NSString *state;
@property (nonatomic, retain, readonly) NSString *country;
@property (nonatomic, retain, readonly) NSString *phone;
@property (nonatomic, retain, readonly) CLLocation *location;

@end
