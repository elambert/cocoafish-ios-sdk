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
@property (nonatomic, retain, readwrite) NSString *address;
@property (nonatomic, retain, readwrite) NSString *crossStreet;
@property (nonatomic, retain, readwrite) NSString *city;
@property (nonatomic, retain, readwrite) NSString *state;
@property (nonatomic, retain, readwrite) NSString *postalCode;
@property (nonatomic, retain, readwrite) NSString *country;
@property (nonatomic, retain, readwrite) NSString *phone;
@property (nonatomic, retain, readwrite) CLLocation *location;
@property (nonatomic, retain, readwrite) NSString *website;
@property (nonatomic, retain, readwrite) NSString *twitter;

@end

@implementation CCPlace

@synthesize name = _name;
@synthesize address = _address;
@synthesize crossStreet = _crossStreet;
@synthesize city = _city;
@synthesize state = _state;
@synthesize postalCode = _PostalCode;
@synthesize country = _country;
@synthesize phone = _phone;
@synthesize location = _location;
@synthesize website = _website;
@synthesize twitter = _twitter;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	self = [super initWithJsonResponse:jsonResponse];
	if (self) {
		self.name = [jsonResponse objectForKey:CC_JSON_PLACE_NAME];
		self.address = [jsonResponse objectForKey:CC_JSON_PLACE_ADDRESS];
		self.crossStreet = [jsonResponse objectForKey:CC_JSON_PLACE_CROSS_STREET];
		self.city = [jsonResponse objectForKey:CC_JSON_PLACE_CITY];
		self.state = [jsonResponse objectForKey:CC_JSON_PLACE_STATE];
        self.postalCode = [jsonResponse objectForKey:CC_JSON_PLACE_POSTAL_CODE];
		self.country = [jsonResponse objectForKey:CC_JSON_PLACE_COUNTRY];
		self.phone = [jsonResponse objectForKey:CC_JSON_PHONE];
        self.website = [jsonResponse objectForKey:CC_JSON_WEBSITE];
        self.twitter = [jsonResponse objectForKey:CC_JSON_TWITTER];
		
		// get location if there is one
		NSString *latStr = [jsonResponse objectForKey:CC_JSON_LATITUDE];
		NSString *lngStr = [jsonResponse objectForKey:CC_JSON_LONGITUDE];
		if (latStr && lngStr) {
			_location = [[CLLocation alloc] initWithLatitude:[latStr doubleValue] longitude:[lngStr doubleValue]];
		}
		
	}
	
	return self;
	
}

- (NSString *)description {
    return [NSString stringWithFormat:@"CCPlace:\n\tname: %@\n\taddress: %@\n\tcrossStreet: %@\n\tcity: %@\n\tstate: %@\n\tpostalCode: %@\n\tcountry :%@\n\tphone: %@\n\twebsite: %@\n\ttwitter: %@\n\tlocation: %@\n\t%@",
            self.name, self.address, self.crossStreet, self.city, self.state, self.postalCode,
            self.country, self.phone, self.website, self.twitter, [self.location description], [super description]];
}

-(void)dealloc
{
	self.name = nil;
	self.address = nil;
	self.crossStreet = nil;
	self.city = nil;
	self.state = nil;
    self.postalCode = nil;
	self.country = nil;
	self.phone = nil;
    self.website = nil;
    self.twitter = nil;
	self.location = nil;
	[super dealloc];
}

@end

@implementation CCMutablePlace

@synthesize name ;
@synthesize address;
@synthesize crossStreet;
@synthesize state;
@synthesize postalCode;
@synthesize city;
@synthesize country;
@synthesize phone;
@synthesize website;
@synthesize twitter;
@synthesize location;
@end
