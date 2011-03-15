//
//  CheckinViewController.h
//  Demo
//
//  Created by Wei Kong on 3/4/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingImageView.h"

@protocol CheckinViewControllerDelegate;

@interface CheckinViewController : UIViewController<UITextViewDelegate, UINavigationControllerDelegate, TapDetectingImageViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
	id<CheckinViewControllerDelegate> _delegate;

	IBOutlet UITextView *msgView;
	IBOutlet TapDetectingImageView *photoView;
	NSData *photoData;
	IBOutlet UILabel *photoLabel;
	IBOutlet UIButton *checkinButton;
}

@property (nonatomic, assign) id<CheckinViewControllerDelegate> delegate;

-(IBAction)startCheckin;
@end

@protocol CheckinViewControllerDelegate <NSObject>

@required
-(void)startCheckin:(CheckinViewController *)controller message:(NSString *)message photoData:(NSData *)photoData;
@end