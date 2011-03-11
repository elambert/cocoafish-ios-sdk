//
//  CCNetworkManager.h
//  Demo
//
//  Created by Wei Kong on 12/14/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

#define CC_FIRST_PAGE 1
#define CC_DEFAULT_PER_PAGE 20

@class CLLocation;
@class CCUser;
@class CCPlace;
@class CCCheckin;
@class CCResponse;
@class CCStatus;
@class CCPhoto;
@class CCKeyValuePair;

@protocol CCNetworkManagerDelegate;

@interface CCNetworkManager : NSObject {
	id<CCNetworkManagerDelegate> _delegate;

	@private
	NSOperationQueue *_operationQueue;
	NSMutableSet *_requestSet;
}

-(id)initWithDelegate:(id)delegate;
-(id)init;
-(void)cancelAllRequests;
-(NSError *)handleResponse:(CCResponse *)response;

-(void)registerUser:(CCUser *)user password:(NSString *)password;
-(void)login:(NSString *)login password:(NSString *)password;
-(void)logout;
-(void)deleteCurrentUser;

-(void)showCurrentUser;
-(void)showUser:(NSString *)userId;

-(void)showCurrentUserCheckins:(int)page perPage:(int)perPage;
-(void)showUserCheckins:(CCUser *)user page:(int)page perPage:(int)perPage;
-(void)checkin:(CCPlace *)place message:(NSString *)message photoData:(NSData *)photoData contentType:(NSString *)contentType;
-(void)getPlaceCheckins:(CCPlace *)place page:(int)page perPage:(int)perPage;

-(void)createUserStatus:(NSString *)status;
-(void)showCurrentUserStatuses:(int)page perPage:(int)perPage;
-(void)showUserStatuses:(CCUser *)user page:(int)page perPage:(int)perPage;
-(void)createPlaceStatus:(NSString *)status place:(CCPlace *)place;
-(void)getPlaceStatuses:(CCPlace *)place page:(int)page perPage:(int)perPage;

-(void)showPlace:(NSString *)placeId;
-(void)getPlacesNear:(CLLocation *)location distance:(int)distance page:(int)page perPage:(int)perPage;
//-(void)getPlacesInRegion:(MKCoordinateRegion)region;
-(void)uploadPlacePhoto:(CCPlace *)place photoData:(NSData *)photoData contentType:(NSString *)contentType;
-(void)getPlacePhotos:(CCPlace *)place page:(int)page perPage:(int)perPage;
-(void)getPhoto:(NSString *)photoId;

-(void)getPhotos:(NSArray *)photoIds;

-(void)storeValueForKey:(NSString *)key value:(NSString *)value;
-(void)getValueForKey:(NSString *)value;

-(Boolean)downloadPhoto:(id)sender photo:(CCPhoto *)photo size:(int)size;

// Used to login with cocoafish after a successful facebook login
-(CCUser *)facebookLogin:(NSString *)fbAppId accessToken:(NSString *)accessToken error:(NSError **)error;
@end

@protocol CCNetworkManagerDelegate <NSObject>

@optional
-(void)networkManager:(CCNetworkManager *)networkManager didGetPlaces:(NSArray *)places;
-(void)networkManager:(CCNetworkManager *)networkManager didLogin:(CCUser *)user;
-(void)networkManager:(CCNetworkManager *)networkManager didGetUser:(CCUser *)user;
-(void)didLogout:(CCNetworkManager *)networkManager;
-(void)didDeleteCurrentUser:(CCNetworkManager *)networkManager;
-(void)networkManager:(CCNetworkManager *)networkManager didRegisterUser:(CCUser *)user;
-(void)networkManager:(CCNetworkManager *)networkManager didCheckin:(CCCheckin *)checkin;
-(void)networkManager:(CCNetworkManager *)networkManager didGetCheckins:(NSArray *)checkins;
-(void)networkManager:(CCNetworkManager *)networkManager didSucceedWithCompound:(NSArray *)responses;
-(void)networkManager:(CCNetworkManager *)networkManager didCreateStatus:(CCStatus *)status;
-(void)networkManager:(CCNetworkManager *)networkManager didGetStatuses:(NSArray *)statuses;
-(void)networkManager:(CCNetworkManager *)networkManager didUploadPhoto:(CCPhoto *)photo;
-(void)networkManager:(CCNetworkManager *)networkManager didGetPhotos:(NSArray *)photos;
-(void)networkManager:(CCNetworkManager *)networkManager didGetPhoto:(CCPhoto *)photo;
-(void)didStoreValue:(CCNetworkManager *)networkManager;
-(void)networkManager:(CCNetworkManager *)networkManager didGetKeyValue:(CCKeyValuePair *)keyvalue;

@required
-(void)networkManager:(CCNetworkManager *)networkManager didFailWithError:(NSError *)error;

@end