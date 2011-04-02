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
@class CCPagination;
@class CCEvent;
@class CCUploadImage;

@protocol CCNetworkManagerDelegate;

@interface CCNetworkManager : NSObject {
	id<CCNetworkManagerDelegate> _delegate;

	@private
	NSOperationQueue *_operationQueue;
    NSOperationQueue *_photoProcessingQueue;
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
-(void)deleteUser;  // delete current user
-(void)showCurrentUser;
-(void)showUser:(NSString *)userId;
-(void)updateUser:(CCUser *)updatedUser;    // update current user

// Checkins
-(void)searchCheckins:(CCObject *)belongTo page:(int)page perPage:(int)perPage;
-(void)showCheckin:(NSString *)checkId;
-(void)createCheckin:(CCObject *)belongTo message:(NSString *)message image:(CCUploadImage *)image;

// Statuses
-(void)createUserStatus:(NSString *)status;
-(void)searchUserStatuses:(CCUser *)user page:(int)page perPage:(int)perPage;

// Places
-(void)deletePlace:(NSString *)placeId;
-(void)createPlace:(CCPlace *)newPlace;
-(void)showPlace:(NSString *)placeId;
-(void)searchPlaces:(CLLocation *)location distance:(NSNumber *)distance page:(int)page perPage:(int)perPage;
-(void)updatePlace:(CCPlace *)place;
//-(void)getPlacesInRegion:(MKCoordinateRegion)region;

// Photos
-(void)createPhoto:(CCObject *)object collectionName:(NSString *)collectionName image:(CCUploadImage *)image;
-(void)searchPhotos:(CCObject *)photoHost collectionName:(NSString *)collectionName page:(int)page perPage:(int)perPage;
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

// Delegate callback methods
@protocol CCNetworkManagerDelegate <NSObject>

@optional
// user logged in
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didLogin:(CCUser *)user;

// user logged out
-(void)didLogout:(CCNetworkManager *)networkManager response:(CCResponse *)response;

// did delete current user
-(void)didDeleteUser:(CCNetworkManager *)networkManager response:(CCResponse *)response;

// create succeeded
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didCreate:(CCObject *)object;

// get succeeded
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGet:(NSArray *)objectArray pagination:(CCPagination *)pagination;

// update succeeded
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didUpdate:(CCObject *)object;

// delete succeeded
-(void)didDelete:(CCNetworkManager *)networkManager response:(CCResponse *)response;


// compound
-(void)networkManager:(CCNetworkManager *)networkManager didSucceedWithCompound:(NSArray *)responses;


@required
-(void)networkManager:(CCNetworkManager *)networkManager didFailWithError:(NSError *)error;

@end