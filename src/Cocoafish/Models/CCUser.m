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
@property (nonatomic, retain, readwrite) NSString *username;
@property (nonatomic, retain, readwrite) NSString *firstName;
@property (nonatomic, retain, readwrite) NSString *lastName;
//@property (nonatomic, readwrite) Boolean facebookAuthorized;
@property (nonatomic, retain, readwrite) NSString *facebookAccessToken;

@end

@implementation CCUser

@synthesize email = _email;
@synthesize username = _username;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
//@synthesize facebookAuthorized = _facebookAuthorized;
@synthesize facebookAccessToken = _facebookAccessToken;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	self = [super initWithJsonResponse:jsonResponse];
	if (self) {

		self.email = [jsonResponse objectForKey:CC_JSON_USER_EMAIL];
		self.username = [jsonResponse objectForKey:CC_JSON_USERNAME];
		self.firstName = [jsonResponse objectForKey:CC_JSON_USER_FIRST];
		self.lastName = [jsonResponse objectForKey:CC_JSON_USER_LAST];
		//self.facebookAuthorized = [[jsonResponse objectForKey:CC_JSON_USER_FACEBOOK_AUTHORIZED] boolValue];
        self.facebookAccessToken = [jsonResponse objectForKey:CC_JSON_USER_FACEBOOK_ACCESS_TOKEN];
	}
	return self;
}

-(id)initWithId:(NSString *)objectId first:(NSString *)first last:(NSString *)last email:(NSString *)email
{
	if (objectId == nil || first == nil) {
		return nil;
	}
	if ((self = [super initWithId:objectId])) {
		self.firstName = first;
		self.lastName = last;
		self.email = email;
	}
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"CCUser:\n\temail: %@\n\tuserName: %@\n\tfirst: %@\n\tlast: %@\n\tfacebookAccessToken :%@\n\t%@",
            self.email, self.username, self.firstName, self.lastName, self.facebookAccessToken, [super description]];
}

-(CCMutableUser *)mutableCopy
{
    CCMutableUser *userCopy = [[[CCMutableUser alloc] initWithId:self.objectId first:self.firstName last:self.lastName email:self.email] autorelease];;
    userCopy.username = [self.username copy];
    return userCopy;
}

-(void)dealloc
{
	self.email = nil;
	self.username = nil;
	self.firstName = nil;
	self.lastName = nil;
    self.facebookAccessToken = nil;
	[super dealloc];
}

@end

@implementation CCMutableUser
@synthesize objectId;
@synthesize firstName;
@synthesize lastName;
@synthesize email;
@synthesize username;

@end


