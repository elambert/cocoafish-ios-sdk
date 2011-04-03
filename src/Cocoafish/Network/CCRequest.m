//
//  CCRequest.m
//  APIs
//
//  Created by Wei Kong on 4/2/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCRequest.h"

@implementation CCDeleteRequest
@synthesize deleteClass = _deleteClass;

-(id)initWithURL:(NSURL *)newURL deleteClass:(Class)deleteClass
{
    self = [super initWithURL:newURL];
    if (self) {
        _deleteClass = deleteClass;
        [self setRequestMethod:@"DELETE"];
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
}
@end
