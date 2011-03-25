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
-(void)performAsyncRequest:(ASIHTTPRequest *)request;
-(void)requestDone:(ASIHTTPRequest *)request;
-(void)requestFailed:(ASIHTTPRequest *)request;
-(void)addOauthHeaderToRequest:(ASIHTTPRequest *)request;
-(NSString *)generateFullRequestUrl:(NSString *)partialUrl additionalParams:(NSArray *)additionalParams;
-(CCUser *)facebookAuth:(NSString *)fbAppId accessToken:(NSString *)accessToken error:(NSError **)error isLogin:(Boolean)isLogin;
@end

# pragma -
# pragma mark CCNetworkManager implementations
@implementation CCNetworkManager

-(id)initWithDelegate:(id)delegate {
	if ((self = [super init])) {
		[self setDelegate:delegate];
		// init the operation queue
		_operationQueue = [[NSOperationQueue alloc] init];
		_requestSet = [[NSMutableSet alloc] init];
		
	}
	return self;
}

-(id)init {
	if ((self = [super init])) {
		// init the operation queue
		_operationQueue = [[NSOperationQueue alloc] init];
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

-(void)performAsyncRequest:(ASIHTTPRequest *)request
{
	[self addOauthHeaderToRequest:request];

	request.timeOutSeconds = CC_TIMEOUT;

	// set callbacks
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
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

#pragma mark -
#pragma mark Cocoafish API calls

/*-(void)getPlacesInRegion:(MKCoordinateRegion)region
{
}*/

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
	
	[self performAsyncRequest:request];
}

-(void)showCurrentUser
{
	NSString *urlPath = [self generateFullRequestUrl:@"users/show/me.json" additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];
}

-(void)showUser:(NSString *)userId
{
	NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"users/show/%@.json", userId] additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];

}

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

-(void)login:(NSString *)login password:(NSString *)password
{
	NSString *urlPath = [self generateFullRequestUrl:@"users/login.json" additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];

	// set the form
	[request setPostValue:login forKey:@"login"];
	[request setPostValue:password forKey:@"password"];
	
	[self performAsyncRequest:request];
}

-(void)logout
{
	NSString *urlPath = [self generateFullRequestUrl:@"users/logout.json" additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];

	[self performAsyncRequest:request];
	
}

-(void)deleteCurrentUser
{
	NSString *urlPath = [self generateFullRequestUrl:@"users/delete.json" additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[request setRequestMethod:@"DELETE"];
	[self performAsyncRequest:request];
	
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

	[self performAsyncRequest:request];

}

-(void)getPlaceCheckins:(CCPlace *)place page:(int)page perPage:(int)perPage
{
    NSArray *additionalParams = [NSArray arrayWithObjects:[NSString stringWithFormat:@"place_id=%@", place.objectId], [NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];

	NSString *urlPath = [self generateFullRequestUrl:@"checkins/search.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];

}

-(void)showCurrentUserCheckins:(int)page perPage:(int)perPage
{
    NSArray *additionalParams = [NSArray arrayWithObjects:[NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];

	NSString *urlPath = [self generateFullRequestUrl:@"checkins/show/me.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];
	
}

-(void)showUserCheckins:(NSString *)userId page:(int)page perPage:(int)perPage
{
    NSArray *additionalParams = [NSArray arrayWithObjects:[NSString stringWithFormat:@"user_id=%@", userId], [NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];

	NSString *urlPath = [self generateFullRequestUrl:@"checkins/search.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];

}

-(void)checkin:(CCPlace *)place message:(NSString *)message photoData:(NSData *)photoData contentType:(NSString *)contentType
{
	
	NSString *urlPath = [self generateFullRequestUrl:@"checkins/create.json" additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];

	[request setPostValue:place.objectId forKey:@"place_id"];
	if (message && [message length] > 0) {
		[request setPostValue:message forKey:@"message"];
	}

	if (photoData) {
		[request setData:photoData withFileName:@"photo.jpg" andContentType:contentType forKey:@"photo"];

//		[request setData:photoData withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"photo"];
	}
		
	[self performAsyncRequest:request];

}

-(void)createUserStatus:(NSString *)message
{	
	NSString *urlPath = [self generateFullRequestUrl:@"statuses/create.json" additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];

	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];

	[request setPostValue:message forKey:@"message"];

	[self performAsyncRequest:request];

}

-(void)createPlaceStatus:(NSString *)status place:(CCPlace *)place
{	
	NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"places/%@/status.json", place.objectId] additionalParams:nil];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	[request setPostValue:status forKey:@"status"];
	
	[self performAsyncRequest:request];

}

-(void)showCurrentUserStatuses:(int)page perPage:(int)perPage
{
    NSArray *additionalParams = [NSArray arrayWithObjects:[NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];

	
	NSString *urlPath = [self generateFullRequestUrl:@"statuses/show/me.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];
	
}

-(void)showUserStatuses:(CCUser *)user page:(int)page perPage:(int)perPage
{
	NSArray *additionalParams = [NSArray arrayWithObjects:[NSString stringWithFormat:@"user_id=%@", user.objectId], [NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];

	NSString *urlPath = [self generateFullRequestUrl:@"statuses/search.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];

}

-(void)deletePlace:(NSString *)placeId
{
    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"places/delete/%@.json", placeId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[request setRequestMethod:@"DELETE"];
	[self performAsyncRequest:request];
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
    
	[self performAsyncRequest:request];
    
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

    [self performAsyncRequest:request];

}

-(void)searchPlaces:(CLLocation *)location distance:(NSNumber *)distance page:(int)page perPage:(int)perPage
{
    NSArray *additionalParams = [NSArray arrayWithObjects:[NSString stringWithFormat:@"page=%d", page], [NSString stringWithFormat:@"per_page=%d", perPage], nil];
    
	NSString *urlPath = [self generateFullRequestUrl:@"places/search.json" additionalParams:additionalParams];
	
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    
	[self performAsyncRequest:request];
}

-(void)showPlace:(NSString *)placeId
{	
	NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"places/show/%@.json", placeId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];
}

// currently object only supports CCUser and CCPlace
-(void)createPhoto:(CCObject *)object collectionName:(NSString *)collectionName photoData:(NSData *)photoData contentType:(NSString *)contentType
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
	[request setData:photoData withFileName:@"photo.jpg" andContentType:contentType forKey:@"file"];
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
	[self performAsyncRequest:request];
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
	
	[self performAsyncRequest:request];	

}

-(void)showPhoto:(NSString *)photoId
{
	NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"photos/show/%@.json", photoId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];	
}

-(void)deletePhoto:(NSString *)photoId
{
    NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"photos/delete/%@.json", photoId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[request setRequestMethod:@"DELETE"];
	[self performAsyncRequest:request];
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
	
	[self performAsyncRequest:request];	
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
	
	[self performAsyncRequest:request];
}

-(void)getValueForKey:(NSString *)key
{
	NSArray *additionalParams = [NSArray arrayWithObject:[NSString stringWithFormat:@"name=%@", key]];
	
	NSString *urlPath = [self generateFullRequestUrl:@"keyvalues/get.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];	
	
}

-(void)appendValueForKey:(NSString *)key appendValue:(NSString *)appendValue
{
    NSArray *additionalParams = [NSArray arrayWithObjects:[NSString stringWithFormat:@"name=%@", key], [NSString stringWithFormat:@"value=%@", appendValue], nil];
    
    NSString *urlPath = [self generateFullRequestUrl:@"keyvalues/append.json" additionalParams:additionalParams];
    
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
    [request setRequestMethod:@"PUT"];
	
	[self performAsyncRequest:request];
    
}

-(void)deleteKeyValue:(NSString *)key
{
    NSArray *additionalParams = [NSArray arrayWithObject:[NSString stringWithFormat:@"name=%@", key]];

    NSString *urlPath = [self generateFullRequestUrl:@"keyvalues/delete.json" additionalParams:additionalParams];
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[request setRequestMethod:@"DELETE"];
	[self performAsyncRequest:request];
}


# pragma -
# pragma mark Handle Server responses
-(void)requestDone:(ASIHTTPRequest *)request
{
	NSLog(@"Received %@", [request responseString]);

	CCResponse *response = [[CCResponse alloc] initWithJsonData:[request responseData]];
	NSError *error = nil;
	if ([response.meta.status isEqualToString:CC_JSON_META_METHOD_COMPOUND]) {
		if (response && [response.meta.status isEqualToString:CC_STATUS_OK]) {
			if ([_delegate respondsToSelector:@selector(networkManager:didSucceedWithCompound:)]) {
				[_delegate networkManager:self didSucceedWithCompound:response.responses];
			}

			/*for (CCResponse *rp in response.responses) {
				[self handleResponse:rp];
			}*/
		} else {
			// something failed on the server
			error = [self serverErrorFromResponse:response];
		}
	} else {
		error = [self handleResponse:response];

	}
	if (error /*&& [[_delegate class] instancesRespondToSelector:@selector(networkManager:didFailWithError:)]*/) {
		[_delegate networkManager:self didFailWithError:error];
	}
	[self removeFinishedRequest:request];
}

-(NSError *)handleResponse:(CCResponse *)response
{
	if (response && [response.meta.status isEqualToString:CC_STATUS_OK]) {

		if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_GET_PLACES] ||
			 [response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_PLACES]) {
			NSArray *places = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_PLACES class:[CCPlace class]];
            if ([_delegate respondsToSelector:@selector(networkManager:response:didGetPlaces:)]) {
                [_delegate networkManager:self response:response didGetPlaces:places];
            }
            
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_CREATE_PLACE] ||
                   [response.meta.method isEqualToString:CC_JSON_META_METHOD_UPDATE_PLACE]) {
            NSArray *places = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_PLACES class:[CCPlace class]];
            CCPlace *place = nil;
            if ([places count] == 1) {
                place = [places objectAtIndex:0];
            }
            if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_CREATE_PLACE] && [_delegate respondsToSelector:@selector(networkManager:response:didCreatePlace:)]) {
                [_delegate networkManager:self response:response didCreatePlace:place];
            } else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_UPDATE_PLACE] && [_delegate respondsToSelector:@selector(networkManager:response:didUpdatePlace:)]) {
                [_delegate networkManager:self response:response didUpdatePlace:place];
            }
        } else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_DELETE_PLACE]) {
            if ([_delegate respondsToSelector:@selector(didDeletePlace:response:)]) {
                [_delegate didDeletePlace:self response:response];
            }
        } else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_LOGIN] ||
                   [response.meta.method isEqualToString:CC_JSON_META_METHOD_UPDATE_USER] ||
                   [response.meta.method isEqualToString:CC_JSON_META_METHOD_REGISTER_USER]) {
			NSArray *users = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_USERS class:[CCUser class]];
			CCUser *currentUser = nil;
			if ([users count] == 1) {
				currentUser = [users objectAtIndex:0];
			}
			if (!currentUser) {
				NSLog(@"Did not receive user info");
			}
            if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_LOGIN]  &&
                [_delegate respondsToSelector:@selector(networkManager:response:didLogin:)]) {
				[_delegate networkManager:self response:response didLogin:currentUser];
			} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_UPDATE_USER]  &&
                [_delegate respondsToSelector:@selector(networkManager:response:didUpdateUser:)]) {
                [_delegate networkManager:self response:response didUpdateUser:currentUser];
            } else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_REGISTER_USER] &&
                [_delegate respondsToSelector:@selector(networkManager:response:didRegisterUser:)]) {
                [_delegate networkManager:self response:response didRegisterUser:currentUser];
            }

			[[Cocoafish defaultCocoafish] setCurrentUser:currentUser];
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_USERS] ||
				   [response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_CURRENT_USER]) {
			NSArray *users = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_USERS class:[CCUser class]];
			CCUser *user = nil;
			if ([users count] == 1) {
				user = [users objectAtIndex:0];
			}
			if ([_delegate respondsToSelector:@selector(networkManager:response:didGetUser:)]) {
				[_delegate networkManager:self response:response didGetUser:user];	
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_LOGOUT]) {
			if ([_delegate respondsToSelector:@selector(didLogout:response:)]) {
				[_delegate didLogout:self response:response];
			}
			[[Cocoafish defaultCocoafish] setCurrentUser:nil];
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_DELETE_USER]) {
			if ([_delegate respondsToSelector:@selector(didDeleteCurrentUser:response:)]) {
				[_delegate didDeleteCurrentUser:self response:response];
			}
			
			[[Cocoafish defaultCocoafish] setCurrentUser:nil];
		} else if (/*[response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_CHECKINS_ME] ||*/
				   [response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_CHECKINS]) {
			NSArray *checkins = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_CHECKINS class:[CCCheckin class]];
			if ([_delegate respondsToSelector:@selector(networkManager:response:didGetCheckins:)]) {
				[_delegate networkManager:self response:response didGetCheckins:checkins];
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_CHECKIN_PLACE]) {
			NSArray *checkins = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_CHECKINS class:[CCCheckin class]];
			CCCheckin *checkin = nil;
			if ([checkins count] == 1) {
				checkin = [checkins objectAtIndex:0];
			}
			if ([_delegate respondsToSelector:@selector(networkManager:response:didCheckin:)]) {
				[_delegate networkManager:self response:response didCheckin:checkin];
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_CREATE_STATUS]) {
			NSArray *statuses = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_STATUSES class:[CCStatus class]];
			CCStatus *status = nil;
			if ([statuses count] == 1) {
				status = [statuses objectAtIndex:0];
			}
			if ([_delegate respondsToSelector:@selector(networkManager:response:didCreateStatus:)]) {
				[_delegate networkManager:self response:response didCreateStatus:status];
			}
		} else if (/*[response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_STATUSES_ME] ||*/
					[response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_STATUSES]) {
			NSArray *statuses = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_STATUSES class:[CCStatus class]];
			if ([_delegate respondsToSelector:@selector(networkManager:response:didGetStatuses:)]) {
				[_delegate networkManager:self response:response didGetStatuses:statuses];
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_CREATE_PHOTO]) {
			NSArray *photos = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_PHOTOS class:[CCPhoto class]];
			CCPhoto *photo = nil;
			if ([photos count] == 1) {
				photo = [photos objectAtIndex:0];
			}
			if ([_delegate respondsToSelector:@selector(networkManager:response:didCreatePhoto:)]) {
				[_delegate networkManager:self response:response didCreatePhoto:photo];
			}
			
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_PHOTOS] ||
                   [response.meta.method isEqualToString:CC_JSON_META_METHOD_SEARCH_PHOTOS]) {
			NSArray *photos = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_PHOTOS class:[CCPhoto class]];
			if ([_delegate respondsToSelector:@selector(networkManager:response:didGetPhotos:)]) {
				[_delegate networkManager:self response:response didGetPhotos:photos];
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_DELETE_PHOTO]) { 
			if ([_delegate respondsToSelector:@selector(didDeletePhoto:response:)]) {
				[_delegate didDeletePhoto:self response:response];
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_SET_KEY_VALUE] ||
                   [response.meta.method isEqualToString:CC_JSON_META_METHOD_GET_KEY_VALUE] ||
                   [response.meta.method isEqualToString:CC_JSON_META_METHOD_APPEND_KEY_VALUE] ||
                   [response.meta.method isEqualToString:CC_JSON_META_METHOD_DELETE_KEY_VALUE]) {
			NSArray *keyvalues = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_KEY_VALUES class:[CCKeyValuePair class]];
			CCKeyValuePair *keyvalue = nil;
			if ([keyvalues count] == 1) {
				keyvalue = [keyvalues objectAtIndex:0];
			}
            if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_GET_KEY_VALUE] && 
                    [_delegate respondsToSelector:@selector(networkManager:response:didGetKeyValue:)]) {
                [_delegate networkManager:self response:response didGetKeyValue:keyvalue];
            } else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_SET_KEY_VALUE] &&
                       [_delegate respondsToSelector:@selector(networkManager:response:didSetKeyValue:)]) {
                [_delegate networkManager:self response:response didSetKeyValue:keyvalue];
            } else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_APPEND_KEY_VALUE] &&
                       [_delegate respondsToSelector:@selector(networkManager:response:didAppendKeyValue:)]) {
                [_delegate networkManager:self response:response didAppendKeyValue:keyvalue];
            } else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_DELETE_KEY_VALUE] &&
                       [_delegate respondsToSelector:@selector(didDeleteKeyValue:response:)]) {
                [_delegate didDeleteKeyValue:self response:response];
            }
		} else {
			// Did find any match
			NSLog(@"Do not know how to handle method %@", response.meta.method);
		}
		
	} else {
		// something failed on the server
		NSError *error = [self serverErrorFromResponse:response];
		return error;
	}
	return nil;
	
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	[_delegate networkManager:self didFailWithError:error];
	[self removeFinishedRequest:request];
	
}

# pragma -
# pragma mark Memory Management
-(void)dealloc
{
	[self cancelAllRequests];
	[_operationQueue cancelAllOperations];
	[_operationQueue release];
	[_requestSet release];
	[super dealloc];
}

@end
