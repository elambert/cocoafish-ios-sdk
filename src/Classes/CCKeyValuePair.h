//
//  CCKeyValuePair.h
//  Cocoafish-ios-sdk
//
//  Created by Wei Kong on 2/8/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCObject.h"

@interface CCKeyValuePair : CCObject {
	
	NSString *_key;
	NSString *_value;
}

@property (nonatomic, retain, readonly) NSString *key;
@property (nonatomic, retain, readonly) NSString *value;


@end
