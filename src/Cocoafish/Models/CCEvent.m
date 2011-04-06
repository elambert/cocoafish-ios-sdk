//
//  CCEvent.m
//  APIs
//
//  Created by Wei Kong on 4/1/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCEvent.h"
#import "CCUser.h"
#import "CCPlace.h"

@interface CCEvent ()
@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, retain, readwrite) NSString *details;
@property (nonatomic, retain, readwrite) CCUser *user;
@property (nonatomic, retain, readwrite) CCPlace *place;
@property (nonatomic, retain, readwrite) NSDate *startTime;
@property (nonatomic, retain, readwrite) NSDate *endTime;
@end

@implementation CCEvent

@synthesize name = _name;
@synthesize details = _details;
@synthesize user = _user;
@synthesize place = _place;
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	self = [super initWithJsonResponse:jsonResponse];
	if (self) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        NSString *dateString = nil;
		@try {
            self.name = [jsonResponse objectForKey:CC_JSON_NAME];
			self.user = [[CCUser alloc] initWithJsonResponse:[jsonResponse objectForKey:CC_JSON_USER]];
			self.place = [[CCPlace alloc] initWithJsonResponse:[jsonResponse objectForKey:CC_JSON_PLACE]];

            
            dateString = [jsonResponse objectForKey:CC_JSON_START_TIME];
            if (dateString) {
                self.startTime = [dateFormatter dateFromString:dateString];
            }

        }
		@catch (NSException *e) {
			NSLog(@"Error: Failed to parse Event object. Reason: %@", [e reason]);
			[self release];
			self = nil;
		}
        self.details = [jsonResponse objectForKey:CC_JSON_DETAILS];
        
        dateString = [jsonResponse objectForKey:CC_JSON_END_TIME];
        if (dateString) {
            self.endTime = [dateFormatter dateFromString:dateString];
        }

	}
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"CCEvent:\n\tname=%@\n\tdetails=%@\n\tstartTime=%@\n\tendTime=%@\n\tuser=[\n\t%@\n\t]\n\tplace=[\n\t%@\n\t]\n\t%@",
            self.name, self.details, [self.startTime description], [self.endTime description], [self.user description],
            [self.place description], [super description]];
}

-(void)dealloc
{
	self.user = nil;
	self.place = nil;
	self.name = nil;
	self.details = nil;
    self.startTime = nil;
    self.endTime = nil;
	[super dealloc];
}
@end

