//
//  CCPhoto.h
//  Cocoafish-ios-sdk
//
//  Created by Wei Kong on 2/7/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCObject.h"

@class UIImage;
@class ASIHTTPRequest;
typedef enum PhotoSize {
	CC_SQUARE_75,
	CC_THUMB_100,
	CC_SMALL_240,
	CC_MEDIUM_500,
	CC_MEDIUM_640,
	CC_LARGE_1024,
	CC_ORIGINAL
} PhotoSize;

@interface CCPhoto : CCObject {
	
	NSString *_filename;
	int _size;
	NSString *_collectionName;
	NSString *_md5;
	BOOL _processed;
	NSString  *_contentType;
	NSDictionary *_urls;
	NSDate *takenAt;
}

@property (nonatomic, retain, readonly) NSString *filename;
@property (nonatomic, readonly) int size;
@property (nonatomic, retain, readonly) NSString *collectionName;
@property (nonatomic, retain, readonly) NSString *md5;
@property (nonatomic, readonly) BOOL processed;
@property (nonatomic, retain, readonly) NSString *contentType;
@property (nonatomic, retain, readonly) NSDate *takenAt;
@property (nonatomic, retain, readonly) NSDictionary *urls;

-(NSString *)getPhotoUrl:(PhotoSize)photoSize;
-(Boolean)asyncGetPhoto:(PhotoSize)photoSize;
-(UIImage *)getPhoto:(PhotoSize)photoSize;
-(NSString *)localPath:(PhotoSize)photoSize;
-(void)updateUrls:(NSDictionary *)urls;
@end

@interface CCUploadImage :  NSObject  {
@private
    UIImage *_rawImage;
    int _maxPhotoSize;
    double _jpegCompression;
    
    // the following are used by CCNetworkManager
    SEL _didFinishSelector; // callback method once the request is finished
    NSString *_photoKey; 
    ASIHTTPRequest *_request;
    NSString *_photoFileName;
}

@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic) SEL didFinishSelector;
@property (nonatomic, readonly) int maxPhotoSize;
@property (nonatomic, readonly) double jpegCompression;
@property (nonatomic,retain) NSString *photoFileName;
@property (nonatomic, retain) NSString *photoKey;

-(id)initWithImage:(UIImage *)image;
-(id)initWithImage:(UIImage *)image maxPhotoSize:(int)maxPhotoSize jpegCompression:(double)jpegCompression;
-(void)processAndSetPhotoData;

@end
