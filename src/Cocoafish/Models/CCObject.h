//
//  CCObject.h
//  Demo
//
//  Created by Wei Kong on 12/15/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

// Super class for all CC model classes
#import <Foundation/Foundation.h>
#import "CCConstants.h"


@interface CCObject : NSObject {

	NSString * _objectId;
	NSDate * _createdAt;
	NSDate *_updatedAt;
}

@property (nonatomic, retain, readonly) NSString *objectId;
@property (nonatomic, retain, readonly) NSDate *createdAt;
@property (nonatomic, retain, readonly) NSDate *updatedAt;

-(id)initWithJsonResponse:(NSDictionary *)jsonResponse;

-(id)initWithId:(NSString *)objectId;

-(NSString *)arrayDescription:(NSArray *)array;

@end
