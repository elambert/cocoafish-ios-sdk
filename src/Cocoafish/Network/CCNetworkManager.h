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
@class CCObject;

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

// Users
-(void)registerUser:(CCUser *)user password:(NSString *)password;
-(void)login:(NSString *)login password:(NSString *)password;
-(void)logout;
-(void)deleteCurrentUser;
-(void)showCurrentUser;
-(void)showUser:(NSString *)userId;
-(void)updateUser:(CCUser *)updatedUser;

// Checkins
-(void)showCurrentUserCheckins:(int)page perPage:(int)perPage;
-(void)showUserCheckins:(NSString *)userId page:(int)page perPage:(int)perPage;
-(void)checkin:(CCPlace *)place message:(NSString *)message photoData:(NSData *)photoData contentType:(NSString *)contentType;
-(void)getPlaceCheckins:(CCPlace *)place page:(int)page perPage:(int)perPage;

// Statuses
-(void)createUserStatus:(NSString *)status;
-(void)showCurrentUserStatuses:(int)page perPage:(int)perPage;
-(void)showUserStatuses:(CCUser *)user page:(int)page perPage:(int)perPage;
-(void)createPlaceStatus:(NSString *)status place:(CCPlace *)place;

// Places
-(void)deletePlace:(NSString *)placeId;
-(void)createPlace:(CCPlace *)newPlace;
-(void)showPlace:(NSString *)placeId;
-(void)searchPlaces:(CLLocation *)location distance:(NSNumber *)distance page:(int)page perPage:(int)perPage;
-(void)updatePlace:(CCPlace *)place;
//-(void)getPlacesInRegion:(MKCoordinateRegion)region;

// Photos
-(void)createPhoto:(CCObject *)object collectionName:(NSString *)collectionName photoData:(NSData *)photoData contentType:(NSString *)contentType;
-(void)searchPhotos:(CCObject *)object collectionName:(NSString *)collectionName page:(int)page perPage:(int)perPage;
-(void)showPhoto:(NSString *)photoId;
-(void)deletePhoto:(NSString *)photoId;
-(void)getPhotosByIds:(NSArray *)photoIds;
-(Boolean)downloadPhoto:(id)sender photo:(CCPhoto *)photo size:(int)size;


// Key Value Pairs
-(void)setValueForKey:(NSString *)key value:(NSString *)value;
-(void)getValueForKey:(NSString *)value;
-(void)appendValueForKey:(NSString *)key appendValue:(NSString *)appendValue;
-(void)deleteKeyValue:(NSString *)key;

// Used to login with cocoafish after a successful facebook login
-(CCUser *)loginWithFacebook:(NSString *)fbAppId accessToken:(NSString *)accessToken error:(NSError **)error;
-(CCUser *)linkWithFacebook:(NSString *)fbAppId accessToken:(NSString *)accessToken error:(NSError **)error;
-(void)unlinkFromFacebook:(NSError **)error;
@end

@protocol CCNetworkManagerDelegate <NSObject>

@optional
// Users
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didLogin:(CCUser *)user;
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGetUser:(CCUser *)user;
-(void)didLogout:(CCNetworkManager *)networkManager response:(CCResponse *)response ;
-(void)didDeleteCurrentUser:(CCNetworkManager *)networkManager response:(CCResponse *)response ;
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response  didRegisterUser:(CCUser *)user;
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didUpdateUser:(CCUser *)user;
// Checkins
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didCheckin:(CCCheckin *)checkin;
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGetCheckins:(NSArray *)checkins;

// Places
-(void)didDeletePlace:(CCNetworkManager *)networkManager response:(CCResponse *)response;
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGetPlaces:(NSArray *)places;
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didCreatePlace:(CCPlace *)place;
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didUpdatePlace:(CCPlace *)place;

// status
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didCreateStatus:(CCStatus *)status;
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGetStatuses:(NSArray *)statuses;

// photos
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didCreatePhoto:(CCPhoto *)photo;
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGetPhotos:(NSArray *)photos;
-(void)didDeletePhoto:(CCNetworkManager *)networkManager response:(CCResponse *)response;

// keyvalues
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didSetKeyValue:(CCKeyValuePair *)keyvalue;
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGetKeyValue:(CCKeyValuePair *)keyvalue;
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didAppendKeyValue:(CCKeyValuePair *)keyvalue;
-(void)didDeleteKeyValue:(CCNetworkManager *)networkManager response:(CCResponse *)response;
// compound
-(void)networkManager:(CCNetworkManager *)networkManager didSucceedWithCompound:(NSArray *)responses;



@required
-(void)networkManager:(CCNetworkManager *)networkManager didFailWithError:(NSError *)error;

@end