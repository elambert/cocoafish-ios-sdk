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
-(NSString *)generateFullRequestUrl:(NSString *)partialUrl additionalParams:(NSString *)additionalParams;
-(CCUser *)facebookAuth:(NSString *)fbAppId accessToken:(NSString *)accessToken error:(NSError **)error isLogin:(Boolean)isLogin;
@end

# pragma -
# pragma mark CCNetworkManager implementations
@implementation CCNetworkManager

-(id)initWithDelegate:(id)delegate {
	if (self = [super init]) {
		[self setDelegate:delegate];
		// init the operation queue
		_operationQueue = [[NSOperationQueue alloc] init];
		_requestSet = [[NSMutableSet alloc] init];
		
	}
	return self;
}

-(id)init {
	if (self = [super init]) {
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
}

-(void)removeFinishedRequest:(ASIHTTPRequest *)finishedRequest
{
	@synchronized(self) {
		[_requestSet removeObject:finishedRequest];
	}
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

-(NSString *)generateFullRequestUrl:(NSString *)partialUrl additionalParams:(NSString *)additionalParams
{
	NSString *url = nil;
	NSString *appKey = [[Cocoafish defaultCocoafish] getAppKey];
	if ([appKey length] > 0) {
		if (additionalParams) {
			url = [NSString stringWithFormat:@"%@/%@?key=%@&%@", CC_BACKEND_URL, partialUrl, appKey, additionalParams];
		} else {
			url = [NSString stringWithFormat:@"%@/%@?key=%@", CC_BACKEND_URL, partialUrl, appKey];
		}
	} else if (additionalParams) {
		url = [NSString stringWithFormat:@"%@/%@?%@", CC_BACKEND_URL, partialUrl, additionalParams];
	} else {
		url = [NSString stringWithFormat:@"%@/%@", CC_BACKEND_URL, partialUrl];
	}
	return url;
}

#pragma mark -
#pragma mark Cocoafish API calls
-(void)getPlacesNear:(CLLocation *)location distance:(int)distance page:(int)page perPage:(int)perPage
{
	NSString *additionalParams = [NSString stringWithFormat:@"page=%d&per_page=%d", page, perPage];

	NSString *urlPath = [self generateFullRequestUrl:@"places/search.json" additionalParams:additionalParams];
	
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
		
	[self performAsyncRequest:request];
}

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
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
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
	NSString *additionalParams = [NSString stringWithFormat:@"facebook_app_id=%@&access_token=%@", fbAppId, accessToken];

	if (isLogin) {
		urlPath = [self generateFullRequestUrl:@"social/facebook/login.json" additionalParams:additionalParams];
	} else {
		urlPath = [self generateFullRequestUrl:@"social/facebook/link.json" additionalParams:additionalParams];
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

-(void)getPlaceCheckins:(CCPlace *)place page:(int)page perPage:(int)perPage
{
	NSString *additionalParams = [NSString stringWithFormat:@"place_id=%@&page=%d&per_page=%d", place.objectId, page, perPage];

	NSString *urlPath = [self generateFullRequestUrl:@"checkins/search.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];

}

-(void)showCurrentUserCheckins:(int)page perPage:(int)perPage
{
	NSString *additionalParams = [NSString stringWithFormat:@"page=%d&per_page=%d", page, perPage];

	NSString *urlPath = [self generateFullRequestUrl:@"checkins/show/me.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];
	
}

-(void)showUserCheckins:(CCUser *)user page:(int)page perPage:(int)perPage
{
	NSString *additionalParams = [NSString stringWithFormat:@"user_id=%@&page=%d&per_page=%d", user.objectId, page, perPage];

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
	NSString *additionalParams = [NSString stringWithFormat:@"page=%d&per_page=%d", page, perPage];
	
	NSString *urlPath = [self generateFullRequestUrl:@"statuses/show/me.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];
	
}

-(void)showUserStatuses:(CCUser *)user page:(int)page perPage:(int)perPage
{
	
	NSString *additionalParams = [NSString stringWithFormat:@"user_id=%@&page=%d&per_page=%d", user.objectId, page, perPage];
	
	NSString *urlPath = [self generateFullRequestUrl:@"statuses/search.json" additionalParams:additionalParams];

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

-(void)getPlaceStatuses:(CCPlace *)place page:(int)page perPage:(int)perPage
{
	
	NSString *additionalParams = [NSString stringWithFormat:@"page=%d&per_page=%d", page, perPage];
	
	NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"places/%@/status.json", place.objectId] additionalParams:additionalParams];
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];

}

-(void)uploadPlacePhoto:(CCPlace *)place photoData:(NSData *)photoData contentType:(NSString *)contentType
{	
	NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"places/%@/photos.json", place.objectId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	//[request setFile:photoPath forKey:@"file"];	
	[request setData:photoData withFileName:@"photo.jpg" andContentType:contentType forKey:@"photo"];

	[self performAsyncRequest:request];

}

-(void)getPlacePhotos:(CCPlace *)place page:(int)page perPage:(int)perPage
{
	NSString *urlPath = [NSString stringWithFormat:@"%@/places/%@/photos.json?key=%@&page=%d&per_page=%d", CC_BACKEND_URL, place.objectId, [[Cocoafish defaultCocoafish] getAppKey], page, perPage];
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];	
}

-(void)getPhoto:(NSString *)photoId
{
	NSString *urlPath = [self generateFullRequestUrl:[NSString stringWithFormat:@"photos/show/%@.json", photoId] additionalParams:nil];
	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];	
}

-(void)getPhotos:(NSArray *)photoIds
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
	
	NSString *additionalParams = [NSString stringWithFormat:@"ids=%@", photoIdsStr];
	
	NSString *urlPath = [self generateFullRequestUrl:@"photos/show.json" additionalParams:additionalParams];

	NSURL *url = [NSURL URLWithString:urlPath];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	
	[self performAsyncRequest:request];	
}

-(void)storeValueForKey:(NSString *)key value:(NSString *)value
{
	NSString *urlPath = [NSString stringWithFormat:@"%@/keyvalues.json?key=%@", CC_BACKEND_URL, [[Cocoafish defaultCocoafish] getAppKey]];
	NSURL *url = [NSURL URLWithString:urlPath];
	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
	[request setPostValue:value forKey:@"value"];	
	
	[self performAsyncRequest:request];
}

-(void)getValueForKey:(NSString *)key
{
	
	NSString *additionalParams = [NSString stringWithFormat:@"name=%@", key];
	
	NSString *urlPath = [self generateFullRequestUrl:@"keyvalues.json" additionalParams:additionalParams];

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
			 [response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_PLACE]) {
			NSArray *places = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_PLACES class:[CCPlace class]];
			if ([_delegate respondsToSelector:@selector(networkManager:didGetPlaces:)]) {
				[_delegate networkManager:self didGetPlaces:places];
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_REGISTER_USER]) {
			NSArray *users = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_USERS class:[CCUser class]];
			CCUser *currentUser = nil;
			if ([users count] == 1) {
				currentUser = [users objectAtIndex:0];
			}
			if (!currentUser) {
				NSLog(@"Did not receive user info after registerUser");
			}
			if ([_delegate respondsToSelector:@selector(networkManager:didRegisterUser:)]) {
				[_delegate networkManager:self didRegisterUser:currentUser];
			}
			[[Cocoafish defaultCocoafish] setCurrentUser:currentUser];
							  
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_LOGIN]) {
			NSArray *users = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_USERS class:[CCUser class]];
			CCUser *currentUser = nil;
			if ([users count] == 1) {
				currentUser = [users objectAtIndex:0];
			}
			if (!currentUser) {
				NSLog(@"Did not receive user info after login");
			}
			if ([_delegate respondsToSelector:@selector(networkManager:didLogin:)]) {
				[_delegate networkManager:self didLogin:currentUser];
			}
			[[Cocoafish defaultCocoafish] setCurrentUser:currentUser];
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_USER] ||
				   [response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_CURRENT_USER]) {
			NSArray *users = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_USERS class:[CCUser class]];
			CCUser *user = nil;
			if ([users count] == 1) {
				user = [users objectAtIndex:0];
			}
			if ([_delegate respondsToSelector:@selector(networkManager:didGetUser:)]) {
				[_delegate networkManager:self didGetUser:user];	
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_LOGOUT]) {
			if ([_delegate respondsToSelector:@selector(didLogout:)]) {
				[_delegate didLogout:self];
			}
			[[Cocoafish defaultCocoafish] setCurrentUser:nil];
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_DELETE_USER]) {
			if ([_delegate respondsToSelector:@selector(didDeleteCurrentUser:)]) {
				[_delegate didDeleteCurrentUser:self];
			}
			
			[[Cocoafish defaultCocoafish] setCurrentUser:nil];
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_CHECKINS_ME] ||
				   [response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_CHECKINS]) {
			NSArray *checkins = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_CHECKINS class:[CCCheckin class]];
			if ([_delegate respondsToSelector:@selector(networkManager:didGetCheckins:)]) {
				[_delegate networkManager:self didGetCheckins:checkins];
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_CHECKIN_PLACE]) {
			NSArray *checkins = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_CHECKINS class:[CCCheckin class]];
			CCCheckin *checkin = nil;
			if ([checkins count] == 1) {
				checkin = [checkins objectAtIndex:0];
			}
			if ([_delegate respondsToSelector:@selector(networkManager:didCheckin:)]) {
				[_delegate networkManager:self didCheckin:checkin];
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_CREATE_STATUS]) {
			NSArray *statuses = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_STATUSES class:[CCStatus class]];
			CCStatus *status = nil;
			if ([statuses count] == 1) {
				status = [statuses objectAtIndex:0];
			}
			if ([_delegate respondsToSelector:@selector(networkManager:didCreateStatus:)]) {
				[_delegate networkManager:self didCreateStatus:status];
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_STATUSES_ME] ||
					[response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_STATUSES]) {
			NSArray *statuses = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_STATUSES class:[CCStatus class]];
			if ([_delegate respondsToSelector:@selector(networkManager:didGetStatuses:)]) {
				[_delegate networkManager:self didGetStatuses:statuses];
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_UPLOAD_PHOTO]) {
			NSArray *photos = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_PHOTOS class:[CCPhoto class]];
			CCPhoto *photo = nil;
			if ([photos count] == 1) {
				photo = [photos objectAtIndex:0];
			}
			if ([_delegate respondsToSelector:@selector(networkManager:didUploadPhoto:)]) {
				[_delegate networkManager:self didUploadPhoto:photo];
			}
			
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_PHOTOS]) {
			NSArray *photos = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_PHOTOS class:[CCPhoto class]];
			if ([_delegate respondsToSelector:@selector(networkManager:didGetPhotos:)]) {
				[_delegate networkManager:self didGetPhotos:photos];
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_SHOW_PHOTO]) {
			NSArray *photos = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_PHOTOS class:[CCPhoto class]];
			CCPhoto *photo = nil;
			if ([photos count] == 1) {
				photo = [photos objectAtIndex:0];
			}
			if ([_delegate respondsToSelector:@selector(networkManager:didGetPhoto:)]) {
				[_delegate networkManager:self didGetPhoto:photo];
			}
			
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_STORE_VALUE]) {
			if ([_delegate respondsToSelector:@selector(didStoreValue:)]) {
				[_delegate didStoreValue:self];
			}
		} else if ([response.meta.method isEqualToString:CC_JSON_META_METHOD_STORE_VALUE]) {
			NSArray *keyvalues = [CCResponse getArrayFromJsonResonse:response.response jsonTag:CC_JSON_KEY_VALUES class:[CCKeyValuePair class]];
			CCKeyValuePair *keyvalue = nil;
			if ([keyvalues count] == 1) {
				keyvalue = [keyvalues objectAtIndex:0];
			}
			if ([_delegate respondsToSelector:@selector(networkManager:didGetKeyValue:)]) {
				[_delegate networkManager:self didGetKeyValue:keyvalue];
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
