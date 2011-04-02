//
//  CCEvent.h
//  APIs
//
//  Created by Wei Kong on 4/1/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCObject.h"

@class CCUser;
@class CCPlace;
@interface CCEvent : CCObject {
@private
    NSString *_name;
    NSString *_note;
    NSDate *_startTime;
    NSDate *_endTime;
	CCUser *_user;
	CCPlace *_place;
}

@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, retain, readonly) NSString *note;
@property (nonatomic, retain, readonly) CCUser *user;
@property (nonatomic, retain, readonly) CCPlace *place;
@property (nonatomic, retain, readonly) NSDate *startTime;
@property (nonatomic, retain, readonly) NSDate *endTime;

@end
