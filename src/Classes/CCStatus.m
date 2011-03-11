//
//  CCStatus.m
//  Cocoafish-ios-sdk
//
//  Created by Wei Kong on 2/6/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCStatus.h"

@interface CCStatus ()

@property (nonatomic, retain, readwrite) NSString *status;

@end

@implementation CCStatus
@synthesize status = _status;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	if (self = [super initWithJsonResponse:jsonResponse]) {
		self.status = [jsonResponse objectForKey:CC_JSON_STATUS];
	}
	
	return self;
}

-(void)dealloc
{
	self.status = nil;
	[super dealloc];
}

@end
