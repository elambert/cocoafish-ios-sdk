//
//  CCDownloadRequest.h
//  Cocoafish-ios-sdk
//
//  Created by Wei Kong on 3/8/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "ASIHTTPRequest.h"

@class CCObject;
@interface CCDownloadRequest : ASIHTTPRequest {
	CCObject *_object;
	NSNumber *_size; // for photo
}

@property (nonatomic, retain, readonly) CCObject *object;
@property (nonatomic, retain, readonly) NSNumber *size;

-(id)initWithURL:(NSURL *)newURL object:(CCObject *)object size:(NSNumber *)size;

@end
