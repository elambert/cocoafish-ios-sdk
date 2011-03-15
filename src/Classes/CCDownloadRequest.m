//
//  CCDownloadRequest.m
//  Cocoafish-ios-sdk
//
//  Created by Wei Kong on 3/8/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCDownloadRequest.h"

@interface CCDownloadRequest ()

@property (nonatomic, retain, readwrite) CCObject *object;
@property (nonatomic, retain, readwrite) NSNumber *size;
@end

@implementation CCDownloadRequest
@synthesize object = _object;
@synthesize size = _size;

-(id)initWithURL:(NSURL *)newURL object:(CCObject *)object size:(NSNumber *)size
{
	self = [super initWithURL:newURL];
	if (self) {
		self.object = object;
		self.size = size;
	}
	return self;
}

-(void)dealloc
{
	[_object release];
	[_size release];
	[super dealloc];
}
@end
