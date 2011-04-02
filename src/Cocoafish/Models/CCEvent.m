//
//  CCEvent.m
//  APIs
//
//  Created by Wei Kong on 4/1/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCEvent.h"

@interface CCEvent ()
@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, retain, readwrite) NSString *note;
@property (nonatomic, retain, readwrite) CCUser *user;
@property (nonatomic, retain, readwrite) CCPlace *place;
@property (nonatomic, retain, readwrite) NSDate *startTime;
@property (nonatomic, retain, readwrite) NSDate *endTime;
@end

@implementation CCEvent

@synthesize name = _name;
@synthesize note = _note;
@synthesize user = _user;
@synthesize place = _place;
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@end
