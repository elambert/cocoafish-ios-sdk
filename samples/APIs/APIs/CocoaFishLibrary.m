//
//  CocoafishLibrary.m
//  Cocoafish-ios-demo
//
//  Created by Michael Goff on 7/9/08.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "CocoafishLibrary.h"

NSString* getUniqueIdentifier() {
	UIDevice *myCurrentDevice = [UIDevice currentDevice];
	return [myCurrentDevice uniqueIdentifier];
}

// check iphone
BOOL isIphone() {
	NSString *deviceType = [UIDevice currentDevice].model;
	if ([deviceType isEqualToString:@"iPhone"]) {
		return YES;
	} else {
		return NO;
	}
}

// check ipad
BOOL isIPad()
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
	return NO;
#endif
}
// get the float iOS version such as 4.1
float osVersion() {
	UIDevice *myCurrentDevice = [UIDevice currentDevice];
	return [[myCurrentDevice systemVersion] floatValue];
}

NSString* timeElapsedFrom(NSDate *startDate)
{
	NSDate *currentDate = [NSDate date];
	
	NSTimeInterval ti = [currentDate timeIntervalSinceDate:startDate];
	
	int diff;
	NSString *unit;
	NSString *plural;
	if (ti < 60) {
		return NSLocalizedString(@"less than a minute ago", nil);
	} else if (ti < 3600) {
		diff = round(ti / 60);
		unit = NSLocalizedString(@"minute", nil);
	} else if (ti < 86400) {
		diff = round(ti / 60 / 60);
		unit = NSLocalizedString(@"hour", nil);
	} else if (ti < 2629743) {
		diff = round(ti / 60 / 60 / 24);
		unit = NSLocalizedString(@"day", nil);
	} else if (ti < 31556916) {
		diff = round(ti / 30 / 60 / 60 / 24);
		unit = NSLocalizedString(@"month", nil);
	} else {
		diff = round(ti / 12 / 30 / 60 / 60 / 24);
		unit = NSLocalizedString(@"year", nil);
	}   
	if (diff > 1) {
		plural = NSLocalizedString(@"s", nil);
	} else {
		plural = @"";
	}
	NSString *ago = NSLocalizedString(@"ago", nil);
	return [NSString stringWithFormat:@"%d %@%@ %@", diff, unit, plural, ago];
}

BOOL validateEmail(NSString *candidate) {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:candidate];
}

// Scale and rotate the image from the camera or the iage picker.
// Got this from http://discussions.apple.com/thread.jspa?messageID=7324988
UIImage *scaleAndRotateImage(UIImage *img, int kMaxResolution) {
    CGImageRef imgRef = img.CGImage;
	
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
	
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
	
    if ( (kMaxResolution != 0) && (width > kMaxResolution || height > kMaxResolution) ) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
        }
        else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
        }
    }
	
    CGFloat scaleRatio;
    if (kMaxResolution != 0){
        scaleRatio = bounds.size.width / width;
    } else
    {
        scaleRatio = 1.0f;
    }
	
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = img.imageOrientation;
    switch(orient) {
			
        case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
        case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
        case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
        case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
        case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
        case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
        default:
			[NSException raise:NSInternalInconsistencyException format: @"Invalid image orientation"];
			
    }
	
    UIGraphicsBeginImageContext(bounds.size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
	
    CGContextConcatCTM(context, transform);
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return tempImage;
}

