//
//  CCStatus.m
//  Cocoafish-ios-sdk
//
//  Created by Wei Kong on 2/6/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCStatus.h"

@interface CCStatus ()

@property (nonatomic, retain, readwrite) NSString *message;

@end

@implementation CCStatus
@synthesize message = _message;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	if ((self = [super initWithJsonResponse:jsonResponse])) {
		self.message = [jsonResponse objectForKey:CC_JSON_MESSAGE];
	}
	
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"CCStatus:\n\tmessage: '%@'\n\t%@",
            self.message, [super description]];
}

-(void)dealloc
{
	self.message = nil;
	[super dealloc];
}

@end
