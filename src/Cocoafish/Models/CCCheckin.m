//
//  CCCheckin.m
//  Demo
//
//  Created by Wei Kong on 12/17/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCCheckin.h"
#import "CCUser.h"
#import "CCPlace.h"
#import "CCPhoto.h"

@interface CCCheckin ()

@property (nonatomic, retain, readwrite) CCUser *user;
@property (nonatomic, retain, readwrite) CCPlace *place;
@property (nonatomic, retain, readwrite) CCPhoto *photo;
@property (nonatomic, retain, readwrite) NSString *message;

@end

@implementation CCCheckin
@synthesize user = _user;
@synthesize place = _place;
@synthesize photo = _photo;
@synthesize message = _message;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	self = [super initWithJsonResponse:jsonResponse];
	if (self) {
		@try {
			self.user = [[CCUser alloc] initWithJsonResponse:[jsonResponse objectForKey:CC_JSON_USER]];
			self.place = [[CCPlace alloc] initWithJsonResponse:[jsonResponse objectForKey:CC_JSON_PLACE]];
			self.photo = [[CCPhoto alloc] initWithJsonResponse:[jsonResponse objectForKey:CC_JSON_PHOTO]];
		}
		@catch (NSException *e) {
			NSLog(@"Error: Failed to parse checkin object. Reason: %@", [e reason]);
			[self release];
			self = nil;
		}
		self.message = [jsonResponse objectForKey:CC_JSON_MESSAGE];
	}
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"CCCheckin:\n\tmessage=%@\n\tuser=[\n\t%@\n\t]\n\tplace=[\n\t%@\n\t]\n\tphoto=[\n\t%@\n\t]\n\t%@",
                                    self.message, [self.user description],
                                    [self.place description], [self.photo description], [super description]];
}

-(void)dealloc
{
	self.user = nil;
	self.place = nil;
	self.message = nil;
	self.photo = nil;
	[super dealloc];
}

@end
