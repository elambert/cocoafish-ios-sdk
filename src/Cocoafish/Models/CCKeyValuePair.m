//
//  CCKeyValuePair.m
//  Cocoafish-ios-sdk
//
//  Created by Wei Kong on 2/8/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCKeyValuePair.h"

@interface CCKeyValuePair ()

@property (nonatomic, retain, readwrite) NSString *key;
@property (nonatomic, retain, readwrite) NSString *value;
@end

@implementation CCKeyValuePair
@synthesize key = _key;
@synthesize value = _value;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	if ((self = [super initWithJsonResponse:jsonResponse])) {
		self.key = [jsonResponse objectForKey:CC_JSON_KEY];
		self.value = [jsonResponse objectForKey:CC_JSON_VALUE];		
	}
	
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"CCKeyValuePair\n\tkey: %@\n\tvalue: %@\n\t%@", 
            self.key, self.value, [super description]];
}

-(void)dealloc
{
	self.key = nil;
	self.value = nil;
	[super dealloc];
}


@end
