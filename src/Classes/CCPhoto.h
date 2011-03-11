//
//  CCPhoto.h
//  Cocoafish-ios-sdk
//
//  Created by Wei Kong on 2/7/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CCObject.h"

@class UIImage;
typedef enum PhotoSize {
	CC_SQUARE,
	CC_THUMB,
	CC_SMALL,
	CC_MEDIUM_500,
	CC_MEDIUM_640,
	CC_LARGE,
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
