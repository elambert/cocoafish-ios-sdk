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
//@property (nonatomic, readwrite) Boolean facebookAuthorized;
@property (nonatomic, retain, readwrite) NSString *facebookAccessToken;

@end

@implementation CCUser

@synthesize email = _email;
@synthesize userName = _userName;
@synthesize first = _first;
@synthesize last = _last;
//@synthesize facebookAuthorized = _facebookAuthorized;
@synthesize facebookAccessToken = _facebookAccessToken;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	self = [super initWithJsonResponse:jsonResponse];
	if (self) {

		self.email = [jsonResponse objectForKey:CC_JSON_USER_EMAIL];
		self.userName = [jsonResponse objectForKey:CC_JSON_USERNAME];
		self.first = [jsonResponse objectForKey:CC_JSON_USER_FIRST];
		self.last = [jsonResponse objectForKey:CC_JSON_USER_LAST];
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
		self.first = first;
		self.last = last;
		self.email = email;
	}
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"CCUser:\n\temail: %@\n\tuserName: %@\n\tfirst: %@\n\tlast: %@\n\tfacebookAccessToken :%@\n\t%@",
            self.email, self.userName, self.first, self.last, self.facebookAccessToken, [super description]];
}

-(CCMutableUser *)mutableCopy
{
    CCMutableUser *userCopy = [[[CCMutableUser alloc] initWithId:self.objectId first:self.first last:self.last email:self.email] autorelease];;
    userCopy.userName = [self.userName copy];
    return userCopy;
}

-(void)dealloc
{
	self.email = nil;
	self.userName = nil;
	self.first = nil;
	self.last = nil;
    self.facebookAccessToken = nil;
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


