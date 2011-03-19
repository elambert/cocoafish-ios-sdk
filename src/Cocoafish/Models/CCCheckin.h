//
//  CCCheckin.h
//  Demo
//
//  Created by Wei Kong on 12/17/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCObject.h"

@class CCUser;
@class CCPlace;
@class CCPhoto;
@interface CCCheckin : CCObject {
	CCUser *_user;
	CCPlace *_place;
	CCPhoto *_photo;
	NSString *message;
}

@property (nonatomic, retain, readonly) CCUser *user;
@property (nonatomic, retain, readonly) CCPlace *place;
@property (nonatomic, retain, readonly) CCPhoto *photo;
@property (nonatomic, retain, readonly) NSString *message;

@end
