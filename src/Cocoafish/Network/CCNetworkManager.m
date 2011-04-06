//
//  CCNetworkManager.m
//  Demo
//
//  Created by Wei Kong on 12/14/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCNetworkManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Cocoafish.h"
#import "CCResponse.h"
#import "CCConstants.h"
#import "CCDownloadRequest.h"
#import "OAuthCore.h"
#import "CCRequest.h"

# pragma -
# pragma mark CCNetworkManager PrivateMethods
@interface CCNetworkManager (PrivateMethods)
-(void)setDelegate:(id)delegate;
-(void)addNewRequest:(ASIHTTPRequest *)newRequest;
-(void)removeFinishedRequest:(ASIHTTPRequest *)finishedRequest;
-(NSError *)serverErrorFromResponse:(CCResponse *)jsonResponse;
-(void)performAsyncRequest:(ASIHTTPRequest *)request callback:(SEL)callback;
-(void)loginRequestDone:(ASIHTTPRequest *)request;
-(void)logoutRequestDone:(ASIHTTPRequest *)request;
-(void)createRequestDone:(ASIHTTPRequest *)request;
-(void)getRequestDone:(ASIHTTPRequest *)request;
-(void)updateRequestDone:(ASIHTTPRequest *)request;
-(void)deleteRequestDone:(ASIHTTPRequest *)request;
-(void)requestFailed:(ASIHTTPRequest *)request;
-(void)addOauthHeaderToRequest:(ASIHTTPRequest *)request;
-(Class)parseResultArray:(NSDictionary *)jsonResponse resultArray:(NSMutableArray **)resultArray;
-(NSString *)generateFullRequestUrl:(NSString *)partialUrl additionalParams:(NSArray *)additionalParams;
-(CCUser *)facebookAuth:(NSString *)fbAppId accessToken:(NSString *)accessToken error:(NSError **)error isLogin:(Boolean)isLogin;
-(void)processImageBeforeUpload:(CCUploadImage *)image;
@end

# pragma -
# pragma mark CCNetworkManager implementations
@implementation CCNetworkManager

-(id)initWithDelegate:(id)delegate {
	if ((self = [super init])) {
		[self setDelegate:delegate];
		// init the operation queue
		_operationQueue = [[NSOperationQueue alloc] init];
        _photoProcessingQueue = [[NSOperationQueue alloc] init];
		_requestSet = [[NSMutableSet alloc] init];
		
	}
	return self;
}

-(id)init {
	if ((self = [super init])) {
		// init the operation queue
		_operationQueue = [[NSOperationQueue alloc] init];
        _photoProcessingQueue = [[NSOperationQueue alloc] init];
		_requestSet = [[NSMutableSet alloc] init];
		
	}
	return self;
}

-(void)setDelegate:(id)delegate
{
	// Sanity Check
	if (![delegate conformsToProtocol:@protocol(CCNetworkManagerDelegate)]) {
		[NSException raise:@"CCNetworkManagerDelegate Exception"
					format:@"Parameter does not conform to CCNetworkManagerDelegate protocol at line %d", (int)__LINE__];
	}
	_delegate = delegate;
}

# pragma -
# pragma mark requests Management
-(void)addNewRequest:(ASIHTTPRequest *)newRequest
{
	@synchronized(self) {
		[_requestSet addObject:newRequest];
	}
    [self retain];
}

-(void)removeFinishedRequest:(ASIHTTPRequest *)finishedRequest
{
	@synchronized(self) {
		[_requestSet removeObject:finishedRequest];
	}
    [self release];
}

-(void)cancelAllRequests
{
	@synchronized(self) {
		NSArray *allRequests = [_requestSet allObjects];
		for (ASIHTTPRequest *request in allRequests) {
			[request clearDelegatesAndCancel];
		}
		[_requestSet removeAllObjects];
	}
}

// Generate NSError from json Response
-(NSError *)serverErrorFromResponse:(CCResponse *)jsonResponse
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
	if (jsonResponse && [jsonResponse.meta.message length] > 0) {
		[userInfo setObject:[NSString stringWithFormat:@"%@", jsonResponse.meta.message] forKey:NSLocalizedDescriptionKey];
	}
	if (jsonResponse.meta.method) {
		[userInfo setObject:jsonResponse.meta.method forKey:@"remote_method"];
	}
	NSError *error = [NSError errorWithDomain:CC_DOMAIN code:CC_SERVER_ERROR userInfo:userInfo];
	return error;
}

-(void)performAsyncRequest:(ASIHTTPRequest *)request callback:(SEL)callback
{
	[self addOauthHeaderToRequest:request];

	request.timeOutSeconds = CC_TIMEOUT;

	// set callbacks
	[request setDelegate:self];
	[request setDidFinishSelector:callback];
	[request setDidFailSelector:@selector(requestFailed:)];
	
	[_operationQueue addOperation:request];
	
	[self addNewRequest:request];
	
}

-(void)addOauthHeaderToRequest:(ASIHTTPRequest *)request
{
	if (![[Cocoafish defaultCocoafish] getOauthConsumerKey] || ![[Cocoafish defaultCocoafish] getOauthConsumerSecret]) {
		// nothing to add
		return;
	}
	BOOL postRequest = NO;
	if ([request isKindOfClass:[ASIFormDataRequest class]]) {
		postRequest = YES;
	}
	NSData *body = nil;

	if (postRequest) {
		[request buildPostBody];
		body = [request postBody];
	}
	
	NSString *header = OAuthorizationHeader([request url],
											[request requestMethod],
											body,
											[[Cocoafish defaultCocoafish] getOauthConsumerKey],
											[[Cocoafish defaultCocoafish] getOauthConsumerSecret],
											@"",
											@"");
	[request addRequestHeader:@"Authorization" value:header];
}

-(NSString *)generateFullRequestUrl:(NSString *)partialUrl additionalParams:(NSArray *)additionalParams
{
	NSString *url = nil;
	NSString *appKey = [[Cocoafish defaultCocoafish] getAppKey];
    NSString *paramsString = nil;
    if ([additionalParams count] > 0) {
        paramsString = [additionalParams componentsJoinedByString:@"&"];
        paramsString = [paramsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
	if ([appKey length] > 0) {
		if (paramsString) {
			url = [NSString stringWithFormat:@"%@/%@?key=%@&%@", CC_BACKEND_URL, partialUrl, appKey, 
                   paramsString];
		} else {
			url = [NSString stringWithFormat:@"%@/%@?key=%@", CC_BACKEND_URL, partialUrl, appKey];
		}
	} else if (paramsString) {
		url = [NSString stringWithFormat:@"%@/%@?%@", CC_BACKEND_URL, partialUrl, paramsString];
	} else {
		url = [NSString stringWithFormat:@"%@/%@", CC_BACKEND_URL, partialUrl];
	}
	return url;
}


-(void)processImageBeforeUpload:(CCUploadImage *)image
{   
    [image processAndSetPhotoData];
    [self performAsyncRequest:image.request callback:image.didFinishSelector];
    
}

#pragma mark -
#pragma mark Cocoafish API calls

#pragma mark - Users related
-(void)registerUser:(CCUser *)user password:(NSString *)password passwordConfirmation:(NSString *)passwordConfirmation
{
	NSString *urlPath = [self generateFullRequestUrl:@"users/create.json" additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];

	// set the form
    if ([user.email length] > 0) {
        [request setPostValue:user.email forKey:@"email"];
    }
    if ([user.firstName length] > 0) {
        [request setPostValue:user.firstName forKey:@"first_name"];
    }
    if ([user.lastName length] > 0) {
        [request setPostValue:user.lastName forKey:@"last_name"];
    }
    if ([user.username length] > 0) {
        [request setPostValue:user.username forKey:@"username"];
    }
	[request setPostValue:password forKey:@"password"];
	[request setPostValue:passwordConfirmation forKey:@"password_confirmation"];
	
	[self performAsyncRequest:request callback:@selector(createRequestDone:)];
}

-(void)showCurrentUser
{
	NSString *urlPath = [self generateFullRequestUrl:@"users/show/me.json" additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];
}

-(void)showUser:(NSString *)userId
{
	NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"users/show/%@.json", userId] additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];

}


-(void)login:(NSString *)login password:(NSString *)password
{
	NSString *urlPath = [self generateFullRequestUrl:@"users/login.json" additionalParams:nil];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
    
	// set the form
	[request setPostValue:login forKey:@"login"];
	[request setPostValue:password forKey:@"password"];
	
	[self performAsyncRequest:request callback:@selector(loginRequestDone:)];
}

-(void)logout
{
	NSString *urlPath = [self generateFullRequestUrl:@"users/logout.json" additionalParams:nil];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    
	[self performAsyncRequest:request callback:@selector(logoutRequestDone:)];
	
}

-(void)updateUser:(CCUser *)updatedUser
{
    CCUser *currentUser = [[Cocoafish defaultCocoafish] getCurrentUser];
    
    NSMutableArray *additionalParams = [[[NSMutableArray alloc] init] autorelease];
    if ([currentUser.firstName caseInsensitiveCompare:updatedUser.firstName] != NSOrderedSame) {
        [additionalParams addObject:[NSString stringWithFormat:@"first_name=%@", updatedUser.firstName]];
    }
    if ([currentUser.lastName caseInsensitiveCompare:updatedUser.lastName] != NSOrderedSame) {
        [additionalParams addObject:[NSString stringWithFormat:@"last_name=%@", updatedUser.lastName]];
    }
    if ([currentUser.email caseInsensitiveCompare:updatedUser.email] != NSOrderedSame) {
        [additionalParams addObject:[NSString stringWithFormat:@"email=%@", updatedUser.email]];
    }
    if ([currentUser.username caseInsensitiveCompare:updatedUser.username] != NSOrderedSame) {
        [additionalParams addObject:[NSString stringWithFormat:@"username=%@", updatedUser.username]];
    }
    
    NSString *urlPath = [self generateFullRequestUrl:@"users/update.json" additionalParams:additionalParams];
    NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    [request setRequestMethod:@"PUT"];
    
	[self performAsyncRequest:request callback:@selector(updateRequestDone:)];
    
}

-(void)deleteUser
{
    NSString *urlPath = [self generateFullRequestUrl:@"users/delete.json" additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	
	CCDeleteRequest *request = [[[CCDeleteRequest alloc] initWithURL:url deleteClass:[CCUser class]] autorelease];
	
    [self performAsyncRequest:request callback:@selector(deleteRequestDone:)];
}

#pragma mark - Facebook related
-(CCUser *)linkWithFacebook:(NSString *)fbAppId accessToken:(NSString *)accessToken error:(NSError **)error
{
	return [self facebookAuth:fbAppId accessToken:accessToken error:error isLogin:NO];
}

-(CCUser *)loginWithFacebook:(NSString *)fbAppId accessToken:(NSString *)accessToken error:(NSError **)error
{
	return [self facebookAuth:fbAppId accessToken:accessToken error:error isLogin:YES];

}

-(void)unlinkFromFacebook:(NSError **)error
{
	NSString *urlPath = [self generateFullRequestUrl:@"social/facebook/unlink.json" additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    [request setRequestMethod:@"DELETE"];
	[self addOauthHeaderToRequest:request];
	
	[request startSynchronous];	
	*error = [request error];
	CCUser *currentUser = nil;
	if (!*error) {
		NSLog(@"%@", [request responseString]);
		CCResponse *response = [[CCResponse alloc] initWithJsonData:[request responseData]];
		if (response && [response.meta.status isEqualToString:CC_STATUS_OK]) {
			NSMutableArray *users = nil;
            Class class = [self parseResultArray:response.response resultArray:&users];
			if (class == [CCUser class] && [users count] == 1) {
				currentUser = [users objectAtIndex:0];
			}
			if (!currentUser) {
				NSLog(@"Did not receive user info after facebookLogin");
			} else {
				[[Cocoafish defaultCocoafish] setCurrentUser:currentUser];
			}
			
		} else {
			*error = [self serverErrorFromResponse:response];
		}
	} 
	
}

-(CCUser *)facebookAuth:(NSString *)fbAppId accessToken:(NSString *)accessToken error:(NSError **)error isLogin:(Boolean)isLogin
{
	NSString *urlPath = nil;

	if (isLogin) {
		urlPath = [self generateFullRequestUrl:@"social/facebook/login.json" additionalParams:nil];
	} else {
		urlPath = [self generateFullRequestUrl:@"social/facebook/link.json" additionalParams:nil];
	}
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];

	// set the form
	[request setPostValue:fbAppId forKey:@"facebook_app_id"];
	[request setPostValue:accessToken forKey:@"access_token"];
	
	[self addOauthHeaderToRequest:request];

	[request startSynchronous];	
	*error = [request error];
	CCUser *currentUser = nil;
	if (!*error) {
		NSLog(@"%@", [request responseString]);
		CCResponse *response = [[CCResponse alloc] initWithJsonData:[request responseData]];
		if (response && [response.meta.status isEqualToString:CC_STATUS_OK]) {
			NSMutableArray *users = nil;
            Class class = [self parseResultArray:response.response resultArray:&users];
			if (class == [CCUser class] && [users count] == 1) {
				currentUser = [users objectAtIndex:0];
			}
			if (!currentUser) {
				NSLog(@"Did not receive user info after facebookLogin");
			} else {
				[[Cocoafish defaultCocoafish] setCurrentUser:currentUser];
			}
		
		} else {
			*error = [self serverErrorFromResponse:response];
		}
	} 
	return currentUser;
}


#pragma mark - Facebook related
-(void)searchCheckins:(CCObject *)belongTo page:(int)page perPage:(int)perPage
{
    NSMutableArray *additionalParams = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];
    if ([belongTo isKindOfClass:[CCPlace class]]) {
        [additionalParams addObject:[NSString stringWithFormat:@"place_id=%@", belongTo.objectId]];
    } else if ([belongTo isKindOfClass:[CCUser class]]) {
        [additionalParams addObject:[NSString stringWithFormat:@"user_id=%@", belongTo.objectId]];
    } else if ([belongTo isKindOfClass:[CCEvent class]]) {
        [additionalParams addObject:[NSString stringWithFormat:@"event_id=%@", belongTo.objectId]];
    } else {
        [NSException raise:@"Object type is not supported in showCheckins" format:@"unknow object type"];
    }
    NSString *urlPath = [self generateFullRequestUrl:@"checkins/search.json" additionalParams:additionalParams];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];

}

-(void)createCheckin:(CCObject *)belongTo message:(NSString *)message image:(CCUploadImage *)image
{
	
	NSString *urlPath = [self generateFullRequestUrl:@"checkins/create.json" additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];

    if ([belongTo isKindOfClass:[CCPlace class]]) {
        [request setPostValue:belongTo.objectId forKey:@"place_id"];
    } else if ([belongTo isKindOfClass:[CCEvent class]]) {
        [request setPostValue:belongTo.objectId forKey:@"event_id"];
    } else {
        [NSException raise:@"Object type is not supported in createCheckin" format:@"unknow object type"];
    }
	if (message && [message length] > 0) {
		[request setPostValue:message forKey:@"message"];
	}

	if (image) {
        /* Create our NSInvocationOperation to call loadDataWithOperation, passing in nil */

        image.request = request;
        image.didFinishSelector = @selector(createRequestDone:);
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(processImageBeforeUpload:)
                                                                                  object:image];
        
        /* Add the operation to the photo processing queue */
        [_photoProcessingQueue addOperation:operation];
        [operation release];
        return;
     	
	//	[request setData:photoData withFileName:@"photo.jpg" andContentType:contentType forKey:@"photo"];

	}
		
	[self performAsyncRequest:request callback:@selector(createRequestDone:)];

}

-(void)deleteCheckin:(NSString *)checkinId
{
    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"checkins/delete/%@.json", checkinId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
    
	CCDeleteRequest *request = [[[CCDeleteRequest alloc] initWithURL:url deleteClass:[CCCheckin class]] autorelease];
	
    [self performAsyncRequest:request callback:@selector(deleteRequestDone:)];
}

-(void)showCheckin:(NSString *)checkinId
{	
	NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"checkins/show/%@.json", checkinId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];
}

#pragma mark - Statuses
-(void)createUserStatus:(NSString *)message
{	
	NSString *urlPath = [self generateFullRequestUrl:@"statuses/create.json" additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];

	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];

	[request setPostValue:message forKey:@"message"];

	[self performAsyncRequest:request callback:@selector(createRequestDone:)];

}

-(void)searchUserStatuses:(CCUser *)user page:(int)page perPage:(int)perPage
{
	NSArray *additionalParams = [NSArray arrayWithObjects:[NSString stringWithFormat:@"user_id=%@", user.objectId], [NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];

	NSString *urlPath = [self generateFullRequestUrl:@"statuses/search.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];

}

-(void)deletePlace:(NSString *)placeId
{
    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"places/delete/%@.json", placeId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	
    
	CCDeleteRequest *request = [[[CCDeleteRequest alloc] initWithURL:url deleteClass:[CCPlace class]] autorelease];
	
    [self performAsyncRequest:request callback:@selector(deleteRequestDone:)];
}

-(void)updatePlace:(CCPlace *)place
{
    NSMutableArray *additionalParams = [[[NSMutableArray alloc] init] autorelease];
    if (place.name != nil) {
        [additionalParams addObject:[NSString stringWithFormat:@"name=%@", place.name]];
    }
    if (place.address != nil) {
        [additionalParams addObject:[NSString stringWithFormat:@"address=%@", place.address]];
    }
    if (place.crossStreet != nil) {
        [additionalParams addObject:[NSString stringWithFormat:@"cross_street=%@", place.crossStreet]];
    }
    if (place.city != nil) {
        [additionalParams addObject:[NSString stringWithFormat:@"city=%@", place.city]];
    }
    if (place.state != nil) {
        [additionalParams addObject:[NSString stringWithFormat:@"stat=%@", place.state]];
    } 
    if (place.country != nil) {
        [additionalParams addObject:[NSString stringWithFormat:@"country=%@", place.country]];
    } 
    if (place.postalCode!= nil) {
        [additionalParams addObject:[NSString stringWithFormat:@"postal_code=%@", place.postalCode]];
    } 
    if (place.phone != nil) {
        [additionalParams addObject:[NSString stringWithFormat:@"phone_number=%@", place.phone]];
    } 
    if (place.website != nil) {
        [additionalParams addObject:[NSString stringWithFormat:@"website=%@", place.website]];
    } 
    if (place.twitter != nil) {
        [additionalParams addObject:[NSString stringWithFormat:@"twitter=%@", place.twitter]];
    } 
    if (place.location != nil) {
        [additionalParams addObject:[NSString stringWithFormat:@"latitude=%f", place.location.coordinate.latitude]];
        [additionalParams addObject:[NSString stringWithFormat:@"longitude=%f", place.location.coordinate.longitude]];
    } 

    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"places/update/%@.json", place.objectId] additionalParams:additionalParams];
    NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    [request setRequestMethod:@"PUT"];
    
	[self performAsyncRequest:request callback:@selector(updateRequestDone:)];
    
}

-(void)createPlace:(CCPlace *)newPlace
{
    NSString *urlPath = [self generateFullRequestUrl:@"places/create.json" additionalParams:nil];
    
	NSURL *url = [NSURL URLWithString:urlPath];
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
    if (newPlace.name) {
        [request setPostValue:newPlace.name forKey:@"name"];
    }
    if (newPlace.address) {
        [request setPostValue:newPlace.address forKey:@"address"];
    }
    if (newPlace.crossStreet) {
        [request setPostValue:newPlace.crossStreet forKey:@"crossStreet"];
    }
    if (newPlace.city) {
        [request setPostValue:newPlace.city forKey:@"city"];
    }
    if (newPlace.state) {
        [request setPostValue:newPlace.state forKey:@"state"];
    }
    if (newPlace.country) {
        [request setPostValue:newPlace.country forKey:@"country"];
    }
    if (newPlace.postalCode) {
        [request setPostValue:newPlace.postalCode forKey:@"postal_code"];
    }
    if (newPlace.website) {
        [request setPostValue:newPlace.website forKey:@"website"];
    }
    if (newPlace.twitter) {
        [request setPostValue:newPlace.twitter forKey:@"twitter"];
    }
    if (newPlace.phone) {
        [request setPostValue:newPlace.phone forKey:@"phone_number"];
    }
    if (newPlace.location) {
        [request setPostValue:[NSString stringWithFormat:@"%f", newPlace.location.coordinate.latitude] forKey:@"latitude"];
        [request setPostValue:[NSString stringWithFormat:@"%f", newPlace.location.coordinate.longitude] forKey:@"longitude"];
    }

    [self performAsyncRequest:request callback:@selector(createRequestDone:)];

}

-(void)searchPlaces:(CLLocation *)location distance:(NSNumber *)distance page:(int)page perPage:(int)perPage
{
    NSArray *additionalParams = [NSArray arrayWithObjects:[NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];
    
	NSString *urlPath = [self generateFullRequestUrl:@"places/search.json" additionalParams:additionalParams];
	
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];
}

-(void)showPlace:(NSString *)placeId
{	
	NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"places/show/%@.json", placeId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];
}

// currently object only supports CCUser and CCPlace
-(void)createPhoto:(CCObject *)photoHost collectionName:(NSString *)collectionName image:(CCUploadImage *)image
{
    NSString *urlPath = [self generateFullRequestUrl:@"photos/create.json" additionalParams:nil];

    NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	//[request setFile:photoPath forKey:@"file"];	
    
    if ([photoHost isKindOfClass:[CCPlace class]]) {
        [request setPostValue:photoHost.objectId forKey:@"place_id"];
    } else if ([photoHost isKindOfClass:[CCUser class]]) {
        [request setPostValue:photoHost.objectId forKey:@"user_id"];
    } else {
        [NSException raise:@"Object type is not supported in uploadPhoto" format:@"unknow object type"];
    }
    
    if ([collectionName length]>0) {
        [request setPostValue:collectionName forKey:@"collection_name"];
    }
    if ([photoHost isKindOfClass:[CCPlace class]]) {
        [request setPostValue:photoHost.objectId forKey:@"place_id"];
    } else if ([photoHost isKindOfClass:[CCUser class]]) {
        [request setPostValue:photoHost.objectId forKey:@"user_id"];
    } else {
        [NSException raise:@"Object type is not supported in uploadPhoto" format:@"unknow object type"];
    }
    
    if (image) {
        /* Create our NSInvocationOperation to call loadDataWithOperation, passing in nil */
        
        image.request = request;
        image.didFinishSelector = @selector(createRequestDone:);
        image.photoKey = @"file";
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(processImageBeforeUpload:)
                                                                                  object:image];
        
        /* Add the operation to the photo processing queue */
        [_photoProcessingQueue addOperation:operation];
        [operation release];
        return;
    }     	

	[self performAsyncRequest:request callback:@selector(createRequestDone:)];
}

-(void)searchPhotos:(CCObject *)object collectionName:(NSString *)collectionName page:(int)page perPage:(int)perPage
{
    NSMutableArray *additionalParams = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];
    if ([collectionName length] > 0) {
        [additionalParams addObject:[NSString stringWithFormat:@"collection_name=%@", collectionName]];
    }

    if ([object isKindOfClass:[CCPlace class]]) {
        [additionalParams addObject:[NSString stringWithFormat:@"place_id=%@", object.objectId]];
    } else if ([object isKindOfClass:[CCUser class]]) {
        [additionalParams addObject:[NSString stringWithFormat:@"user_id=%@", object.objectId]];
    } else {
        [NSException raise:@"Object type is not supported in searchPhotos" format:@"unknow object type"];
    }
    
    NSString *urlPath = [self generateFullRequestUrl:@"photos/search.json" additionalParams:additionalParams];
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];	

}

-(void)showPhoto:(NSString *)photoId
{
	NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"photos/show/%@.json", photoId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];	
}

-(void)deletePhoto:(NSString *)photoId
{
    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"photos/delete/%@.json", photoId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	
	CCDeleteRequest *request = [[[CCDeleteRequest alloc] initWithURL:url deleteClass:[CCPhoto class]] autorelease];	
    
	[self performAsyncRequest:request callback:@selector(deleteRequestDone:)];
}

// Get a list of photos by their ids
-(void)getPhotosByIds:(NSArray *)photoIds
{
	if ([photoIds count] == 0) {
		return;
	} 
	NSMutableString *photoIdsStr = [[[NSMutableString alloc] init] autorelease];;
	
	for (NSString *photoId in photoIds) {
		[photoIdsStr appendFormat:@"%@,", photoId];
	}
	if ([photoIdsStr length] > 0) {
		// remove the last ,
		NSRange range;
		range.location = [photoIdsStr length] - 1;
		range.length = 1;
		[photoIdsStr deleteCharactersInRange:range];
		
	}
	
	NSArray *additionalParams = [NSArray arrayWithObject:[NSString stringWithFormat:@"ids=%@", photoIdsStr]];
	
	NSString *urlPath = [self generateFullRequestUrl:@"photos/show.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];	
}


-(Boolean)downloadPhoto:(id)sender photo:(CCPhoto *)photo size:(int)size
{
	NSString *urlPath = [photo getPhotoUrl:size];
	if (photo == nil || urlPath == nil) {
		return NO;
	}
	NSURL *url = [NSURL URLWithString:urlPath];
	CCDownloadRequest *request = [[[CCDownloadRequest alloc] initWithURL:url object:photo size:[NSNumber numberWithInt:size]] autorelease];
	[request setDownloadDestinationPath:[photo localPath:size]];
    
	request.timeOutSeconds = CC_TIMEOUT;
	
	// set callbacks
	[request setDelegate:sender];
	[request setDidFinishSelector:@selector(downloadDone:)];
	[request setDidFailSelector:@selector(downloadFailed:)];
	
	[_operationQueue addOperation:request];
	
	[self addNewRequest:request];
	return YES;
}

-(void)setValueForKey:(NSString *)key value:(NSString *)value
{
    NSArray *additionalParams = [NSArray arrayWithObjects:[NSString stringWithFormat:@"name=%@", key], [NSString stringWithFormat:@"value=%@", value], nil];

    NSString *urlPath = [self generateFullRequestUrl:@"keyvalues/set.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    [request setRequestMethod:@"PUT"];
	
	[self performAsyncRequest:request callback:@selector(createRequestDone:)];
}

-(void)getValueForKey:(NSString *)key
{
	NSArray *additionalParams = [NSArray arrayWithObject:[NSString stringWithFormat:@"name=%@", key]];
	
	NSString *urlPath = [self generateFullRequestUrl:@"keyvalues/get.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];	
	
}

-(void)appendValueForKey:(NSString *)key appendValue:(NSString *)appendValue
{
    NSArray *additionalParams = [NSArray arrayWithObjects:[NSString stringWithFormat:@"name=%@", key], [NSString stringWithFormat:@"value=%@", appendValue], nil];
    
    NSString *urlPath = [self generateFullRequestUrl:@"keyvalues/append.json" additionalParams:additionalParams];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    [request setRequestMethod:@"PUT"];
	
	[self performAsyncRequest:request callback:@selector(updateRequestDone:)];
    
}

-(void)deleteKeyValue:(NSString *)key
{
    NSArray *additionalParams = [NSArray arrayWithObject:[NSString stringWithFormat:@"name=%@", key]];

    NSString *urlPath = [self generateFullRequestUrl:@"keyvalues/delete.json" additionalParams:additionalParams];
	NSURL *url = [NSURL URLWithString:urlPath];
	
	CCDeleteRequest *request = [[[CCDeleteRequest alloc] initWithURL:url deleteClass:[CCKeyValuePair class]] autorelease];
	
	[self performAsyncRequest:request callback:@selector(deleteRequestDone:)];
}

#pragma mark - Event related
-(void)createEvent:(NSString *)name details:(NSString *)details placeId:(NSString *)placeId startTime:(NSDate *)startTime endTime:(NSDate *)endTime
{    
    NSString *urlPath = [self generateFullRequestUrl:@"events/create.json" additionalParams:nil];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
    
    if (name) {
        [request setPostValue:name forKey:@"name"];
    }
    if (details) {
        [request setPostValue:details forKey:@"details"];
    }
    if (placeId) {
        [request setPostValue:placeId forKey:@"place_id"];
    }
    if (startTime) {
        [request setPostValue:[startTime description] forKey:@"start_time"];
    }
    if (endTime) {
        [request setPostValue:[endTime description] forKey:@"end_time"];
    }

	[self performAsyncRequest:request callback:@selector(createRequestDone:)];
    
}

-(void)updateEvent:(NSString *)eventId name:(NSString *)name details:(NSString *)details placeId:(NSString *)placeId startTime:(NSDate *)startTime endTime:(NSDate *)endTime

{
    NSMutableArray *additionalParams = [[[NSMutableArray alloc] init] autorelease];
    if (name) {
        [additionalParams addObject:[NSString stringWithFormat:@"name=%@", name]];
    }
    if (details) {
        [additionalParams addObject:[NSString stringWithFormat:@"details=%@", details]];
    }
    if (placeId) {
        [additionalParams addObject:[NSString stringWithFormat:@"place_id=%@", placeId]];
    }
    if (startTime) {
        [additionalParams addObject:[NSString stringWithFormat:@"start_time=%@", startTime]];
    }
    if (endTime) {
        [additionalParams addObject:[NSString stringWithFormat:@"end_time=%@", endTime]];
    }
    
    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"events/update/%@.json", eventId] additionalParams:additionalParams];
    NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    [request setRequestMethod:@"PUT"];
    
	[self performAsyncRequest:request callback:@selector(updateRequestDone:)];
    
}

-(void)showEvent:(NSString *)eventId
{
    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"events/show/%@.json", eventId] additionalParams:nil];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];
    
}
-(void)searchEvents:(CCObject *)belongTo page:(int)page perPage:(int)perPage
{
    NSMutableArray *additionalParams = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];
    
    if ([belongTo isKindOfClass:[CCUser class]]) {
        [additionalParams addObject:[NSString stringWithFormat:@"user_id=%@", belongTo.objectId]]; 
    } else if ([belongTo isKindOfClass:[CCPlace class]]) {
        [additionalParams addObject:[NSString stringWithFormat:@"place_id=%@", belongTo.objectId]]; 
    } else {
        [NSException raise:@"Object type is not supported in searchEvents" format:@"unknow object type"];
    }
    
	NSString *urlPath = [self generateFullRequestUrl:@"events/search.json" additionalParams:additionalParams];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];
}

-(void)deleteEvent:(NSString *)eventId
{
    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"events/delete/%@.json", eventId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	
	CCDeleteRequest *request = [[[CCDeleteRequest alloc] initWithURL:url deleteClass:[CCEvent class]] autorelease];
	
    [self performAsyncRequest:request callback:@selector(deleteRequestDone:)];    
}

#pragma - Messages related
// Message related
-(void)createMessage:(NSString *)subject body:(NSString *)body toUserIds:(NSArray *)toUserIds
{
    NSString *urlPath = [self generateFullRequestUrl:@"messages/create.json" additionalParams:nil];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
    
    if (subject) {
        [request setPostValue:subject forKey:@"subject"];
    }
    if (body) {
        [request setPostValue:body forKey:@"body"];
    }
    if (toUserIds) {
        [request setPostValue:[toUserIds componentsJoinedByString:@","] forKey:@"to_ids"];
    }
    
	[self performAsyncRequest:request callback:@selector(createRequestDone:)];
    
}
-(void)replyMessage:(NSString *)messageId body:(NSString *)body
{
    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"messages/reply/%@.json", messageId] additionalParams:nil];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
    
    if (body) {
        [request setPostValue:body forKey:@"body"];
    }
	[self performAsyncRequest:request callback:@selector(createRequestDone:)];
}

-(void)showMessage:(NSString *)messageId
{
    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"messages/show/%@.json", messageId] additionalParams:nil];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];
}

-(void)showInboxMessages:(int)page perPage:(int)perPage
{
    NSMutableArray *additionalParams = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];
    NSString *urlPath = [self generateFullRequestUrl:@"messages/show/inbox.json" additionalParams:additionalParams];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];
}

-(void)showSentMessages:(int)page perPage:(int)perPage
{
    NSMutableArray *additionalParams = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];
    NSString *urlPath = [self generateFullRequestUrl:@"messages/show/sent.json" additionalParams:additionalParams];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];
}

-(void)showMessageThreads:(int)page perPage:(int)perPage
{
    NSMutableArray *additionalParams = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];
    NSString *urlPath = [self generateFullRequestUrl:@"messages/show/threads.json" additionalParams:additionalParams];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];
    
}

-(void)showThreadMessages:(NSString *)threadId page:(int)page perPage:(int)perPage
{
    NSMutableArray *additionalParams = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];
    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"messages/show/thread/%@.json", threadId] additionalParams:additionalParams];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request callback:@selector(getRequestDone:)];
    
}

-(void)deleteMessage:(NSString *)messageId
{
    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"messages/delete/%@.json", messageId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	
	CCDeleteRequest *request = [[[CCDeleteRequest alloc] initWithURL:url deleteClass:[CCEvent class]] autorelease];
	
    [self performAsyncRequest:request callback:@selector(deleteRequestDone:)]; 
    
}

# pragma -
# pragma mark Handle Server responses
// Get an array of a class type from a jsonresponse,
-(Class)parseResultArray:(NSDictionary *)jsonResponse resultArray:(NSMutableArray **)resultArray
{
    NSArray *jsonTagArray = [jsonResponse allKeys];
    Class class = [CCObject class];
    NSMutableArray	*array = nil;
    for (NSString *jsonTag in jsonTagArray) {
        if ([jsonTag caseInsensitiveCompare:CC_JSON_USERS] == NSOrderedSame) {
            class = [CCUser class];
        } else if ([jsonTag caseInsensitiveCompare:CC_JSON_PLACES] == NSOrderedSame) {
            class = [CCPlace class];
        } else if ([jsonTag caseInsensitiveCompare:CC_JSON_CHECKINS] == NSOrderedSame) {
            class = [CCCheckin class];
        } else if ([jsonTag caseInsensitiveCompare:CC_JSON_PHOTOS] == NSOrderedSame) {
            class = [CCPhoto class];
        } else if ([jsonTag caseInsensitiveCompare:CC_JSON_STATUSES] == NSOrderedSame) {
            class = [CCStatus class];
        } else if ([jsonTag caseInsensitiveCompare:CC_JSON_KEY_VALUES] == NSOrderedSame) {
            class = [CCKeyValuePair class];
        } else if ([jsonTag caseInsensitiveCompare:CC_JSON_EVENTS] == NSOrderedSame) {
            class = [CCEvent class];
        } else if ([jsonTag caseInsensitiveCompare:CC_JSON_MESSAGES] == NSOrderedSame) {
            class = [CCMessage class];
        } else  {
            continue;
        }
        if (!class_respondsToSelector(class, @selector(initWithJsonResponse:))) {
            // class doesn't have support initWithJsonResponse
            continue;
        }
        NSArray *jsonArray = [jsonResponse objectForKey:jsonTag];
        if (jsonArray == nil) {
            continue;
        }
        if (jsonArray && [jsonArray isKindOfClass:[NSArray class]]) {
            array = [NSMutableArray arrayWithCapacity:[jsonArray count]];
            *resultArray = array;
            for (NSDictionary *jsonObject in jsonArray) {
                CCObject *object = (CCObject *)[[class alloc] initWithJsonResponse:jsonObject];
                if (object) {
                    [array addObject:object];
                }
            }
        }
        // right now each response can only send back one array of objects
        break;
    }
	
	
	return class;
}

-(CCResponse *)requestDoneCommon:(ASIHTTPRequest *)request
{
    [self removeFinishedRequest:request];

    NSLog(@"Received %@", [request responseString]);
    CCResponse *response = [[CCResponse alloc] initWithJsonData:[request responseData]];
    if (response && [response.meta.status isEqualToString:CC_STATUS_OK]) {
        return response;
    } else {
        // something failed on the server
        NSError *error = [self serverErrorFromResponse:response];
        if (error && [_delegate respondsToSelector:@selector(networkManager:didFailWithError:)]) {
            [_delegate networkManager:self didFailWithError:error];
        }
    }
    return nil;
}

// Create action finished
-(void)loginRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        if ([_delegate respondsToSelector:@selector(networkManager:didLogin:)]) {
            NSMutableArray *results = nil;
            Class class = [self parseResultArray:response.response resultArray:&results];

            CCUser *user = nil;

            if ([results count] == 1 && class == [CCUser class]) {
                user = [results objectAtIndex:0];
            }

            [_delegate networkManager:self didLogin:user];
            [[Cocoafish defaultCocoafish] setCurrentUser:user];
            
        }
    } 
}

// Create action finished
-(void)logoutRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        if ([_delegate respondsToSelector:@selector(didLogout:)]) {
            
            [_delegate didLogout:self];
            [[Cocoafish defaultCocoafish] setCurrentUser:nil];
        }
    } 
}

// Create action finished
-(void)createRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        NSMutableArray *results = nil;
        Class class = [self parseResultArray:response.response resultArray:&results];
        if ([results count] == 1 && class == [CCUser class]) {
            CCUser *user = [results objectAtIndex:0];
            [[Cocoafish defaultCocoafish] setCurrentUser:user];
        }
        if ([results count] > 0 && [_delegate respondsToSelector:@selector(networkManager:didCreate:objectType:)]) {
            [_delegate networkManager:self didCreate:results objectType:class];
        } else if ([_delegate respondsToSelector:@selector(networkManager:meta:didSucceed:)]) {
            
            // Call the generic callback if we don't know how to process the returned objects or 
            // the didGet callback was not implemented
            [_delegate networkManager:self meta:response.meta didSucceed:response.response];
        }
            
    } 
}

// get action finished
-(void)getRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        if ([_delegate respondsToSelector:@selector(networkManager:didGet:objectType:pagination:)]) {
            NSMutableArray *results = nil;
            Class class = [self parseResultArray:response.response resultArray:&results];
            if (results != nil) {
                [_delegate networkManager:self didGet:results objectType:class pagination:response.meta.pagination];
                return;
            }
        } 
        
        // Call the generic callback if we don't know how to process the returned objects or 
        // the didGet callback was not implemented
        if ([_delegate respondsToSelector:@selector(networkManager:meta:didSucceed:)]) {
            [_delegate networkManager:self meta:response.meta didSucceed:response.response];
        
        }
    } 
}

// update action finished
-(void)updateRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        NSMutableArray *results = nil;
        Class class = [self parseResultArray:response.response resultArray:&results];
        if ([results count] == 1 && class == [CCUser class]) {
            CCUser *user = [results objectAtIndex:0];
            [[Cocoafish defaultCocoafish] setCurrentUser:user];
        }
        if ([results count] > 0 && [_delegate respondsToSelector:@selector(networkManager:didUpdate:objectType:)]) {
            [_delegate networkManager:self didUpdate:results objectType:class];
        } else if ([_delegate respondsToSelector:@selector(networkManager:meta:didSucceed:)]) {
            
            // Call the generic callback if we don't know how to process the returned objects or 
            // the didGet callback was not implemented
            [_delegate networkManager:self meta:response.meta didSucceed:response.response];
        }
    } 
}

// delete action finished
-(void)deleteRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        CCDeleteRequest *deleteRequest = (CCDeleteRequest *)request;
        Class deleteClass = deleteRequest.deleteClass;
        if (deleteClass == [CCUser class]) {
            [[Cocoafish defaultCocoafish] setCurrentUser:nil];
        }
        if ([_delegate respondsToSelector:@selector(networkManager:didDelete:)]) {
            [_delegate networkManager:self didDelete:deleteClass];
        } else if ([_delegate respondsToSelector:@selector(networkManager:meta:didSucceed:)]) {
            
            // Call the generic callback if we don't know how to process the returned objects or 
            // the didGet callback was not implemented
            [_delegate networkManager:self meta:response.meta didSucceed:response.response];
        }
        
    } 
}

-(void)compoundRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        if ([_delegate respondsToSelector:@selector(networkManager:meta:didSucceedWithCompound:)]) {
            [_delegate networkManager:self meta:response.meta didSucceedWithCompound:response.responses];
        }
    }    
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
    if ([_delegate respondsToSelector:@selector(networkManager:didFailWithError:)]) {
        [_delegate networkManager:self didFailWithError:error];
    }
	[self removeFinishedRequest:request];
	
}

# pragma -
# pragma mark Memory Management
-(void)dealloc
{
	[self cancelAllRequests];
	[_operationQueue cancelAllOperations];
	[_operationQueue release];
    [_photoProcessingQueue cancelAllOperations];
    [_photoProcessingQueue release];
	[_requestSet release];
	[super dealloc];
}

@end
