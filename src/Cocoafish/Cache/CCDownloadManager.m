//
//  CCDownloadManager.m
//  Cocoafish-ios-sdk
//
//  Created by Wei Kong on 3/8/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCDownloadManager.h"
#import "CCDownloadRequest.h"
#import "CCPhoto.h"
#import "Cocoafish.h"
#import "CCResponse.h"

#define DEFAULT_TIME_INTERVAL	10

@interface CCDownloadManager ()

@property (nonatomic, retain, readwrite) NSTimer *autoUpdateTimer;
@end

@implementation CCDownloadManager
@synthesize autoUpdateTimer = _autoUpdateTimer;

-(id)init
{
	self = [super init];
	if (self) {
		if (_ccNetworkManager == nil) {
			_ccNetworkManager = [[CCNetworkManager alloc] initWithDelegate:self];
		}
		_downloadInProgress = [[NSMutableSet alloc] init];
		_processingPhotos = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(Boolean)downloadPhoto:(CCPhoto *)photo size:(int)size
{
	@synchronized(self) {
		NSString *downloadPath = [photo localPath:size];
		if ([_downloadInProgress containsObject:downloadPath]) {
			// download already in progress, no op
			return YES;
		}
		Boolean ret = [_ccNetworkManager downloadPhoto:self photo:photo size:size];
		if (ret) {
			[_downloadInProgress addObject:[photo localPath:size]];
		}
		return ret;
	}
}

-(void)downloadDone:(ASIHTTPRequest *)request
{

	CCDownloadRequest *downloadRequest = (CCDownloadRequest *)request;
	NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:downloadRequest.size, @"size", downloadRequest.object, @"object", nil];
	
	NSNotification * myNotification = [NSNotification notificationWithName:@"PhotoDownloadFinished" object:[Cocoafish defaultCocoafish] userInfo:dict];
	[[NSNotificationQueue defaultQueue] enqueueNotification:myNotification postingStyle:NSPostNow];	
	@synchronized(self) {
		if (downloadRequest.size != nil) {
			// it is a photo download
			[_downloadInProgress removeObject:[(CCPhoto *)downloadRequest.object localPath:[downloadRequest.size intValue]]];
		}
	}
} 
	
-(void)downloadFailed:(ASIHTTPRequest *)request
{
	CCDownloadRequest *downloadRequest = (CCDownloadRequest *)request;
	NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:downloadRequest.size, @"size", downloadRequest.object, @"object", nil];
	NSNotification * myNotification = [NSNotification notificationWithName:@"PhotoDownloadFailed" object:[Cocoafish defaultCocoafish] userInfo:dict];
	[[NSNotificationQueue defaultQueue] enqueueNotification:myNotification postingStyle:NSPostNow];	
} 

-(void)addProcessingPhoto:(CCPhoto *)photo
{
	if (!photo) {
		return;
	}
	@synchronized(self) {
		NSMutableSet *objectList = [_processingPhotos objectForKey:photo.objectId];
		if (objectList == nil) {
			// add an entry for this photo id
			objectList = [NSMutableSet setWithObject:photo];
			[_processingPhotos setObject:objectList forKey:photo.objectId];
		} else {
			// add this photo object to the list
			[objectList addObject:photo];
		}
		
		if (self.autoUpdateTimer != nil) {
			[self.autoUpdateTimer invalidate];
			self.autoUpdateTimer = nil;
		}
		
		_timeInterval = DEFAULT_TIME_INTERVAL;
		self.autoUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:(_timeInterval)
																target:self
															  selector:@selector(updateProcessingPhotos)
															  userInfo:nil
															   repeats:NO];
		
	}
}

-(void)updateProcessingPhotos
{
	@synchronized(self) {
		self.autoUpdateTimer = nil;
		
		NSArray *photoIds;
		if ([_processingPhotos count] > 100) {
			// we will check 100 at a time
			NSRange theRange;
			
			theRange.location = 0;
			theRange.length = 100;
			
			photoIds = [[_processingPhotos allKeys] subarrayWithRange:theRange];
		} else {
			photoIds = [_processingPhotos allKeys]; 
		}

		if ([photoIds count] > 0) {
			// send request
			[_ccNetworkManager getPhotosByIds:photoIds];
		}
		
	}
}


-(void)networkManager:(CCNetworkManager *)networkManager didGet:(NSArray *)photos objectType:(Class)objectType pagination:(CCPagination *)pagination
{
    if (objectType != [CCPhoto class]) {
        return;
    }
	NSMutableDictionary *processedPhotos = [[[NSMutableDictionary alloc] init] autorelease];

	@synchronized(self) {		
		for (CCPhoto *updatedPhoto in photos) {
			if (updatedPhoto.processed) {
				// this photo is ready
				[processedPhotos setObject:updatedPhoto forKey:updatedPhoto.objectId];
				
				// Update all the existing objects with url info
				NSMutableSet *objectList = [_processingPhotos objectForKey:updatedPhoto.objectId];
				for (CCPhoto *photo in objectList) {
					[photo updateUrls:updatedPhoto.urls];
				}
			}			
		}
		if ([processedPhotos count] > 0) {
			[_processingPhotos removeObjectsForKeys:[processedPhotos allKeys]];
		}
		
		if ([_processingPhotos count] > 0) {
			// there are still some photos are being processed on the server
			if (_autoUpdateTimer == nil) {
				if (_timeInterval < 864000) {
					_timeInterval = _timeInterval * 2;
				}
				self.autoUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:(_timeInterval)
												target:self
												selector:@selector(updateProcessingPhotos)
												userInfo:nil
												repeats:NO];
			}
		}
	}
	
	if ([processedPhotos count] > 0) {
		// send out notification
		NSDictionary *dict = [NSDictionary dictionaryWithObject:processedPhotos forKey:@"photos"];
		
		NSNotification * myNotification = [NSNotification notificationWithName:@"PhotosProcessed" object:[Cocoafish defaultCocoafish] userInfo:dict];
		[[NSNotificationQueue defaultQueue] enqueueNotification:myNotification postingStyle:NSPostNow];	
	}
	
}

-(void)networkManager:(CCNetworkManager *)networkManager didFailWithError:(NSError *)error
{
	// restart the timer
	@synchronized(self) {
		if (_autoUpdateTimer == nil) {
			if (_timeInterval < 864000) {
				_timeInterval = _timeInterval * 2;
			}
			self.autoUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:(_timeInterval)
																	target:self
																  selector:@selector(updateProcessingPhotos)
																  userInfo:nil
																   repeats:NO];
		}
	}
}

-(void)dealloc
{
	[_ccNetworkManager release];
	[super dealloc];
	
}
@end
