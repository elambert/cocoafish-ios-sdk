//
//  CCUser.h
//  Demo
//
//  Created by Wei Kong on 12/16/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCObject.h"

@class CCMutableUser;

@interface CCUser : CCObject {

	NSString *_first;
	NSString *_last;
	NSString *_email;
	NSString *_userName;
//	Boolean	_facebookAuthorized;
@private
    NSString *_facebookAccessToken;
}

@property (nonatomic, retain, readonly) NSString *first;
@property (nonatomic, retain, readonly) NSString *last;
@property (nonatomic, retain, readonly) NSString *email;
@property (nonatomic, retain, readonly) NSString *userName;
//@property (nonatomic, readonly) Boolean facebookAuthorized;
@property (nonatomic, retain, readonly) NSString *facebookAccessToken;

-(id)initWithId:(NSString *)objectId first:(NSString *)first last:(NSString *)last email:(NSString *)email;
-(CCMutableUser *)mutableCopy;

@end

@interface CCMutableUser : CCUser {
}

@property (nonatomic, retain, readwrite) NSString *objectId;
@property (nonatomic, retain, readwrite) NSString *first;
@property (nonatomic, retain, readwrite) NSString *last;
@property (nonatomic, retain, readwrite) NSString *email;
@property (nonatomic, retain, readwrite) NSString *userName;

@end


