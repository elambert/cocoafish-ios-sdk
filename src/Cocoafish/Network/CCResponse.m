//
//  CCResponse.m
//  Demo
//
//  Created by Wei Kong on 12/15/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCResponse.h"
#import "CCConstants.h"
#import "CCObject.h"
#import <YAJL/YAJL.h>

@interface CCResponse()
@property (nonatomic, readwrite, retain) CCMeta *meta;
@property (nonatomic, readwrite, retain) CCPagination *pagination;
@property (nonatomic, readwrite, retain) NSDictionary *response;
@property (nonatomic, readwrite, retain) NSArray *responses;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse;

@end

@interface CCMeta()
@property (nonatomic, readwrite, retain) NSString *status;
@property (nonatomic, readwrite, retain) NSString *message;
@property (nonatomic, readwrite, retain) NSString *method;
@end

@implementation CCResponse
@synthesize pagination = _pagination;
@synthesize response = _response;
@synthesize responses = _responses;
@synthesize meta = _meta;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	
	if ((self = [super init])) {
		self.response = [jsonResponse objectForKey:CC_JSON_RESPONSE];
		self.pagination = [[[CCPagination alloc] initWithJsonResponse:jsonResponse] autorelease];
		self.meta = [[[CCMeta alloc] initWithJsonResponse:jsonResponse] autorelease];
		
		// check if this is a compound response
		NSArray *compoundResponses = [_response objectForKey:CC_JSON_RESPONSES];
		if (compoundResponses && [compoundResponses isKindOfClass:[NSArray class]]) {
			NSMutableArray *responseArray = [NSMutableArray arrayWithCapacity:[compoundResponses count]];
			for (NSDictionary *rp in compoundResponses) {
				CCResponse *tmpResponse = [[[CCResponse alloc] initWithJsonResponse:rp] autorelease];
				[responseArray addObject:tmpResponse];
			}
			if ([responseArray count] > 0) {
				self.responses = (NSArray *)responseArray;
			}
		}
		// Sanity check
		if (_meta == nil) {
			NSLog(@"No meta data found in response");
			[self release];
			self = nil;
		}
	}
	return self;
}

-(id)initWithJsonData:(NSData *)jsonData
{
	@try {
		NSDictionary *jsonResponse = [jsonData yajl_JSON];
		return ([self initWithJsonResponse:jsonResponse]);
	} 
	@catch (NSException *exception) {
		// Failed to parse
		NSLog(@"Failed to parse data using YAJL JSON parser. Reason: %@", exception.reason);
	}
	return nil;
}

-(void)dealloc
{
	self.response = nil;
	self.pagination = nil;
	self.meta = nil;
	self.responses = nil;

	[super dealloc];
	
}


// Get an array of a class type from a jsonresponse, the caller needs to speicify the jsonTag to identify 
// the array and the class type of the objects that will be stored as array, the class type should have 
// method initWithJsonResponse implemented
+(NSArray *)getArrayFromJsonResonse:(NSDictionary *)jsonResponse jsonTag:(NSString *)jsonTag class:(Class)class
{
	if (!class_respondsToSelector(class, @selector(initWithJsonResponse:))) {
		// class doesn't have
		return nil;
	}
	NSMutableArray	*array;
	NSArray *jsonArray = [jsonResponse objectForKey:jsonTag];
	if (jsonArray && [jsonArray isKindOfClass:[NSArray class]]) {
		array = [NSMutableArray arrayWithCapacity:[jsonArray count]];
		for (NSDictionary *jsonObject in jsonArray) {
			CCObject *object = (CCObject *)[[class alloc] initWithJsonResponse:jsonObject];
			if (object) {
				[array addObject:object];
			}
		}
	}
	return array;
}

@end

@implementation CCMeta

@synthesize status = _status;
@synthesize message = _message;
@synthesize code = _code;
@synthesize method = _method;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	NSDictionary *meta = [jsonResponse objectForKey:CC_JSON_META];

	if (meta) {
		self = [super init];
	}
	if (self) {
		// get response code and details if there are any
		self.message = [meta objectForKey:CC_JSON_META_MESSAGE];
		self.method = [meta objectForKey:CC_JSON_META_METHOD];
		NSString *tmpValue = [meta objectForKey:CC_JSON_META_CODE];
		_code = tmpValue ? [tmpValue intValue] : 0;
		self.status = [meta objectForKey:CC_JSON_META_STATUS];
	}
	return self;
}

-(void)dealloc
{
	self.message = nil;
	self.status = nil;
	self.method = nil;
	[super dealloc];
}
@end

@implementation CCPagination

@synthesize totalCount = _totalCount;
@synthesize totalPage = _totalPage;
@synthesize perPageCount = _perPageCount;
@synthesize curPage = _curPage;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse
{
	NSDictionary *pagination = [jsonResponse objectForKey:CC_JSON_PAGINATION];
	if (pagination) {
		self = [super init];
	}
	if (self) {
		NSString *tmpValue;
		tmpValue = [pagination objectForKey:CC_JSON_TOTAL_COUNT];
		_totalCount = tmpValue ? [tmpValue intValue] : 0;
		
		tmpValue = [pagination objectForKey:CC_JSON_TOTAL_PAGE];
		_totalPage = tmpValue ? [tmpValue intValue] : 0;
		
		tmpValue = [pagination objectForKey:CC_JSON_PER_PAGE_COUNT];
		_perPageCount = tmpValue ? [tmpValue intValue] : 0;
		
		tmpValue = [pagination objectForKey:CC_JSON_CUR_PAGE];
		_curPage = tmpValue ? [tmpValue intValue] : -1;
		
	}
	return self;
}


@end