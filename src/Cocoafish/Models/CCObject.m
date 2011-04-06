//
//  CCObject.m
//  Demo
//
//  Created by Wei Kong on 12/15/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCObject.h"

@interface CCObject()
@property (nonatomic, retain, readwrite) NSString *objectId;
@property (nonatomic, retain, readwrite) NSDate *createdAt;
@property (nonatomic, retain, readwrite) NSDate *updatedAt;
@end


@implementation CCObject
@synthesize objectId = _objectId;
@synthesize createdAt = _createdAt;
@synthesize updatedAt = _updatedAt;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	if (jsonResponse == nil) {
		return nil;
	}
	self.objectId = [jsonResponse objectForKey:CC_JSON_OBJECT_ID];
	if (_objectId) {
		self = [super init];
	}
	
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
	
	NSString *dateString = [jsonResponse objectForKey:CC_JSON_CREATED_AT];
	if (dateString) {
		self.createdAt = [dateFormatter dateFromString:dateString];
	}
	
	dateString = [jsonResponse objectForKey:CC_JSON_UPDATED_AT];
	if (dateString) {
		self.updatedAt = [dateFormatter dateFromString:dateString];
	}
	return self;
}

-(id)initWithId:(NSString *)objectId
{
    if (!objectId) {
        return nil;
    }
    if ((self = [super init])) {
        self.objectId = objectId;
        self.updatedAt = [NSDate date];
        self.createdAt = [NSDate date];
    }
    return self;
    
}

- (NSString *)description {
    return [NSString stringWithFormat:@"id: %@\n\tcreatedAt: %@\n\tupdatedAt: %@", 
                self.objectId,
                [self.createdAt description],
                [self.updatedAt description]];
}

-(NSString *)arrayDescription:(NSArray *)array
{
    return [NSString stringWithFormat:@"{\n\t%@\n\t}", [array componentsJoinedByString:@"\n\t"]];
}

-(void)dealloc
{
	self.createdAt = nil;
	self.updatedAt = nil;
	self.objectId = nil;
	[super dealloc];
}

@end
