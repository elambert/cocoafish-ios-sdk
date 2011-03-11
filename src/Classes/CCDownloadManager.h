//
//  CCDownloadManager.h
//  Cocoafish-ios-sdk
//
//  Created by Wei Kong on 3/8/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNetworkManager.h"

@class CCPhoto;

@interface CCDownloadManager : NSObject <CCNetworkManagerDelegate> {
	NSMutableDictionary	*_processingPhotos; // list of photo objects that are in processing state
	NSMutableSet *_downloadInProgress; // objects (photo, document, etc) that are currently being downloaded
	CCNetworkManager *_ccNetworkManager;
	NSTimer *_downloadNotificationTimer;	// Timer to send out download finished notifcation
	NSTimer *_autoUpdateTimer; // timer used to get photo updates if needed
	int _timeInterval; // used by timer
}


-(Boolean)downloadPhoto:(CCPhoto *)photo size:(int)size;
-(void)addProcessingPhoto:(CCPhoto *)photo;
@end
