//
//  CCUser.m
//  Demo
//
//  Created by Wei Kong on 12/16/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCUser.h"

@interface CCUser ()

@property (nonatomic, retain, readwrite) NSString *email;
@property (nonatomic, retain, readwrite) NSString *userName;
@property (nonatomic, retain, readwrite) NSString *first;
@property (nonatomic, retain, readwrite) NSString *last;
@property (nonatomic, readwrite) Boolean facebookAuthorized;

@end

@implementation CCUser

@synthesize email = _email;
@synthesize userName = _userName;
@synthesize first = _first;
@synthesize last = _last;
@synthesize facebookAuthorized = _facebookAuthorized;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	self = [super initWithJsonResponse:jsonResponse];
	if (self) {

		self.email = [jsonResponse objectForKey:CC_JSON_USER_EMAIL];
		self.userName = [jsonResponse objectForKey:CC_JSON_USERNAME];
	/*	if (!_email && !_userName) {
			NSLog(@"User doesn't have email or userName");
			[self release];
			self = nil;
			return self;
		}*/
		
		self.first = [jsonResponse objectForKey:CC_JSON_USER_FIRST];
		self.last = [jsonResponse objectForKey:CC_JSON_USER_LAST];
		self.facebookAuthorized = [[jsonResponse objectForKey:CC_JSON_USER_FACEBOOK_AUTHORIZED] boolValue];
	}
	return self;
}

-(id)initWithId:(NSString *)objectId first:(NSString *)first last:(NSString *)last email:(NSString *)email
{
	if (objectId == nil || first == nil) {
		return nil;
	}
	if (self = [super init]) {
		_objectId = [objectId retain];
		self.first = first;
		self.last = last;
		self.email = email;
	}
	return self;
}

-(void)dealloc
{
	self.email = nil;
	self.userName = nil;
	self.first = nil;
	self.last = nil;
	[super dealloc];
}

@end

@implementation CCMutableUser
@synthesize objectId;
@synthesize first;
@synthesize last;
@synthesize email;
@synthesize userName;

@end


