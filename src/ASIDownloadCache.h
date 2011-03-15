//
//  ASIDownloadCache.h
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 01/05/2011.
//  Copyright 2011 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASICacheDelegate.h"

@interface ASIDownloadCache : NSObject <ASICacheDelegate> {
	
	// The default cache policy for this cache
	// Requests that store data in the cache will use this cache policy if their cache policy is set to ASIDefaultCachePolicy
	// Defaults to ASIReloadIfDifferentCachePolicy
	ASICachePolicy defaultCachePolicy;
	
	// The directory in which cached data will be stored
	// Defaults to a directory called 'ASIHTTPRequestCache' in the temporary directory
	NSString *storagePath;
	
	// Mediates access to the cache
	NSRecursiveLock *accessLock;
	
	// When YES, the cache will look for cache-control / pragma: no-cache headers, and won't reuse store responses if it finds them
	BOOL shouldRespectCacheControlHeaders;
}

// Returns a static instance of an ASIDownloadCache
// In most circumstances, it will make sense to use this as a global cache, rather than creating your own cache
// To make ASIHTTPRequests use it automatically, use [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
+ (id)sharedCache;

// A helper function that determines if the server has requested data should not be cached by looking at the request's response headers
+ (BOOL)serverAllowsResponseCachingForRequest:(ASIHTTPRequest *)request;

// A date formatter that can be used to construct an RFC 1123 date
// The returned formatter is safe to use on the calling thread
// Do not use this formatter for parsing dates because the format can vary slightly - use ASIHTTPRequest's dateFromRFC1123String: class method instead
+ (NSDateFormatter *)rfc1123DateFormatter;

@property (assign, nonatomic) ASICachePolicy defaultCachePolicy;
@property (retain, nonatomic) NSString *storagePath;
@property (retain) NSRecursiveLock *accessLock;
@property (assign) BOOL shouldRespectCacheControlHeaders;
@end
