//
//  CCResponse.h
//  Demo
//
//  Created by Wei Kong on 12/15/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@class CCMeta;
@class CCPagination;

@interface CCResponse : NSObject {
	CCMeta *_meta;
	NSDictionary *_response; // parsed json response in NSDictionary format
	NSArray *_responses; // If this is a compound response, it contains an array of responses
}

@property (nonatomic, retain, readonly) CCMeta *meta;
@property (nonatomic, retain, readonly) NSDictionary *response;
@property (nonatomic, retain, readonly) NSArray *responses;

-(id)initWithJsonData:(NSData *)jsonData;

+(NSArray *)getArrayFromJsonResonse:(NSDictionary *)jsonResponse jsonTag:(NSString *)jsonTag class:(Class)class;

@end


@interface CCMeta : NSObject {
	NSString *_status;
	NSInteger _code;
	NSString *_message;
	NSString *_method; // method name
    NSNumber *_page;
    NSNumber *_perPage;
    NSNumber *_totalPages;
    NSNumber *_totalResults;
    
}

@property (nonatomic, readonly) NSInteger code;
@property (nonatomic, retain, readonly) NSString *message;
@property (nonatomic, retain, readonly) NSString *status;
@property (nonatomic, retain, readonly) NSString *method;
@property (nonatomic, retain, readonly) NSNumber *totalResults;
@property (nonatomic, retain, readonly) NSNumber *totalPages;
@property (nonatomic, retain, readonly) NSNumber *page;
@property (nonatomic, retain, readonly) NSNumber *perPage;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse;
@end
