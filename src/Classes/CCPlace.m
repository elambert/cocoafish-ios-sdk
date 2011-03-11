//
//  CCPlace.m
//  Demo
//
//  Created by Wei Kong on 12/15/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCPlace.h"

@interface CCPlace ()

@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, retain, readwrite) NSString *address1;
@property (nonatomic, retain, readwrite) NSString *address2;
@property (nonatomic, retain, readwrite) NSString *crossStreet;
@property (nonatomic, retain, readwrite) NSString *city;
@property (nonatomic, retain, readwrite) NSString *state;
@property (nonatomic, retain, readwrite) NSString *country;
@property (nonatomic, retain, readwrite) NSString *phone;
@property (nonatomic, retain, readwrite) CLLocation *location;

@end

@implementation CCPlace

@synthesize name = _name;
@synthesize address1 = _address1;
@synthesize address2 = _address2;
@synthesize crossStreet = _crossStreet;
@synthesize state = _state;
@synthesize city = _city;
@synthesize country = _country;
@synthesize phone = _phone;
@synthesize location = _location;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	self = [super initWithJsonResponse:jsonResponse];
	if (self) {
		self.name = [jsonResponse objectForKey:CC_JSON_PLACE_NAME];
		self.address1 = [jsonResponse objectForKey:CC_JSON_PLACE_ADDRESS_1];
		self.address2 = [jsonResponse objectForKey:CC_JSON_PLACE_ADDRESS_2];
		self.crossStreet = [jsonResponse objectForKey:CC_JSON_PLACE_CROSS_STREET];
		self.city = [jsonResponse objectForKey:CC_JSON_PLACE_CITY];
		self.state = [jsonResponse objectForKey:CC_JSON_PLACE_STATE];
		self.country = [jsonResponse objectForKey:CC_JSON_PLACE_COUNTRY];
		self.phone = [jsonResponse objectForKey:CC_JSON_PHONE];
		
		// get location if there is one
		NSString *latStr = [jsonResponse objectForKey:CC_JSON_LATITUDE];
		NSString *lngStr = [jsonResponse objectForKey:CC_JSON_LONGITUDE];
		if (latStr && lngStr) {
			_location = [[CLLocation alloc] initWithLatitude:[latStr doubleValue] longitude:[lngStr doubleValue]];
		}
		
	}
	
	return self;
	
}

-(void)dealloc
{
	self.name = nil;
	self.address1 = nil;
	self.address2 = nil;
	self.crossStreet = nil;
	self.city = nil;
	self.state = nil;
	self.country = nil;
	self.phone = nil;
	self.location = nil;
	[super dealloc];
}

@end
