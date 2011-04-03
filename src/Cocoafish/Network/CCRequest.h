//
//  CCRequest.h
//  APIs
//
//  Created by Wei Kong on 4/2/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "ASIHTTPRequest.h"

@class CCObject;
@interface  CCDeleteRequest  :  ASIHTTPRequest  {
@private
    Class _deleteClass;
}

@property (nonatomic, readonly) Class deleteClass;

-(id)initWithURL:(NSURL *)newURL deleteClass:(Class)deleteClass;
@end
