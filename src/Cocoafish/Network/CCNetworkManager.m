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
-(void)deleteUserRequestDone:(ASIHTTPRequest *)request;
-(void)deleteRequestDone:(ASIHTTPRequest *)request;
-(void)requestDone:(ASIHTTPRequest *)request;
-(void)requestFailed:(ASIHTTPRequest *)request;
-(void)addOauthHeaderToRequest:(ASIHTTPRequest *)request;
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
-(void)registerUser:(CCUser *)user password:(NSString *)password
{
	NSString *urlPath = [self generateFullRequestUrl:@"users/create.json" additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];

	// set the form
	[request setPostValue:user.email forKey:@"email"];
	[request setPostValue:user.first forKey:@"first_name"];
	[request setPostValue:user.last forKey:@"last_name"];
	[request setPostValue:password forKey:@"password"];
	[request setPostValue:password forKey:@"password_confirmation"];
	
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

-(void)deleteUser
{
	NSString *urlPath = [self generateFullRequestUrl:@"users/delete.json" additionalParams:nil];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[request setRequestMethod:@"DELETE"];
	[self performAsyncRequest:request callback:@selector(deleteUserRequestDone:)];
	
}

-(void)updateUser:(CCUser *)updatedUser
{
    CCUser *currentUser = [[Cocoafish defaultCocoafish] getCurrentUser];
    
    NSMutableArray *additionalParams = [[[NSMutableArray alloc] init] autorelease];
    if ([currentUser.first caseInsensitiveCompare:updatedUser.first] != NSOrderedSame) {
        [additionalParams addObject:[NSString stringWithFormat:@"first=%@", updatedUser.first]];
    }
    if ([currentUser.last caseInsensitiveCompare:updatedUser.last] != NSOrderedSame) {
        [additionalParams addObject:[NSString stringWithFormat:@"last=%@", updatedUser.last]];
    }
    if ([currentUser.email caseInsensitiveCompare:updatedUser.email] != NSOrderedSame) {
        [additionalParams addObject:[NSString stringWithFormat:@"email=%@", updatedUser.email]];
    }
    if ([currentUser.userName caseInsensitiveCompare:updatedUser.userName] != NSOrderedSame) {
        [additionalParams addObject:[NSString stringWithFormat:@"user_name=%@", updatedUser.userName]];
    }
    
    NSString *urlPath = [self generateFullRequestUrl:@"users/update.json" additionalParams:additionalParams];
    NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    [request setRequestMethod:@"PUT"];
    
	[self performAsyncRequest:request callback:@selector(updateRequestDone:)];
    
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
			NSArray *users = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_USERS class:[CCUser class]];
			if ([users count] == 1) {
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
			NSArray *users = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_USERS class:[CCUser class]];
			if ([users count] == 1) {
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
		
	[self performAsyncRequest:request callback:@selector(networkManager:response:didCreate:)];

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
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[request setRequestMethod:@"DELETE"];
	[self performAsyncRequest:request  callback:@selector(deleteRequestDone:)];
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
-(void)createPhoto:(CCObject *)object collectionName:(NSString *)collectionName image:(CCUploadImage *)image
{
    NSString *urlPath = [self generateFullRequestUrl:@"photos/create.json" additionalParams:nil];

    NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	//[request setFile:photoPath forKey:@"file"];	
    
    if ([object isKindOfClass:[CCPlace class]]) {
        [request setPostValue:object.objectId forKey:@"place_id"];
    } else if ([object isKindOfClass:[CCUser class]]) {
        [request setPostValue:object.objectId forKey:@"user_id"];
    } else {
        [NSException raise:@"Object type is not supported in uploadPhoto" format:@"unknow object type"];
    }
    
    if ([collectionName length]>0) {
        [request setPostValue:collectionName forKey:@"collection_name"];
    }
    if ([object isKindOfClass:[CCPlace class]]) {
        [request setPostValue:object.objectId forKey:@"place_id"];
    } else if ([object isKindOfClass:[CCUser class]]) {
        [request setPostValue:object.objectId forKey:@"user_id"];
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
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[request setRequestMethod:@"DELETE"];
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
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[request setRequestMethod:@"DELETE"];
	[self performAsyncRequest:request callback:@selector(deleteRequestDone:)];
}


# pragma -
# pragma mark Handle Server responses
// Get an array of a class type from a jsonresponse, the caller needs to speicify the jsonTag to identify 
// the array and the class type of the objects that will be stored as array, the class type should have 
// method initWithJsonResponse implemented
-(NSArray *)parseResultArray:(NSDictionary *)jsonResponse
{
    NSArray *jsonTagArray = [jsonResponse allKeys];
    
    NSMutableArray	*array= nil;
    for (NSString *jsonTag in jsonTagArray) {
        Class class;
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
            for (NSDictionary *jsonObject in jsonArray) {
                NSObject *object = (NSObject *)[[class alloc] initWithJsonResponse:jsonObject];
                if (object) {
                    [array addObject:object];
                }
            }
        }
        // right now each response can only send back one array of objects
        break;
    }
	
	
	return array;
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
        if ([_delegate respondsToSelector:@selector(networkManager:response:didLogin:)]) {
            NSArray *results = [self parseResultArray:response.response];

            CCUser *user = nil;

            if ([results count] == 1) {
                user = [results objectAtIndex:0];
            }

            [_delegate networkManager:self response:response didLogin:user];
            [[Cocoafish defaultCocoafish] setCurrentUser:user];
            
        }
    } 
}

// Create action finished
-(void)logoutRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        if ([_delegate respondsToSelector:@selector(didLogout:response:)]) {
            
            [_delegate didLogout:self response:response];
            [[Cocoafish defaultCocoafish] setCurrentUser:nil];
        }
    } 
}

// Create action finished
-(void)createRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        if ([_delegate respondsToSelector:@selector(networkManager:response:didCreate:)]) {
            NSArray *results = [self parseResultArray:response.response];

            CCObject *object = nil;
            
            if ([results count] == 1) {
                object = [results objectAtIndex:0];
            }
            
            [_delegate networkManager:self response:response didCreate:object];
            if ([object isKindOfClass:[CCUser class]]) {
                [[Cocoafish defaultCocoafish] setCurrentUser:(CCUser *)object];
            }
        }
    } 
}

// get action finished
-(void)getRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        if ([_delegate respondsToSelector:@selector(networkManager:response:didGet:pagination:)]) {
            NSArray *results = [self parseResultArray:response.response];

            [_delegate networkManager:self response:response didGet:results pagination:response.meta.pagination];
        }
    } 
}

// update action finished
-(void)updateRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        if ([_delegate respondsToSelector:@selector(networkManager:response:didUpdate:)]) {
            NSArray *results = [self parseResultArray:response.response];
            
            CCObject *object = nil;
            
            if ([results count] == 1) {
                object = [results objectAtIndex:0];
            }
            
            [_delegate networkManager:self response:response didUpdate:object];
            if ([object isKindOfClass:[CCUser class]]) {
                [[Cocoafish defaultCocoafish] setCurrentUser:(CCUser *)object];
            }
        }
    } 
}

// delete ser action finished
-(void)deleteUserRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        if ([_delegate respondsToSelector:@selector(didDeleteUser:response:)]) {
            [_delegate didDeleteUser:self response:response];
        }
        [[Cocoafish defaultCocoafish] setCurrentUser:nil];
    } 
}

// delete action finished
-(void)deleteRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        if ([_delegate respondsToSelector:@selector(didDelete:response:)]) {
            [_delegate didDelete:self response:response];
        }
    } 
}

-(void)compoundRequestDone:(ASIHTTPRequest *)request
{
    CCResponse *response = [self requestDoneCommon:request];
    if (response) {
        if ([_delegate respondsToSelector:@selector(networkManager:didSucceedWithCompound:)]) {
            [_delegate networkManager:self didSucceedWithCompound:response.responses];
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
