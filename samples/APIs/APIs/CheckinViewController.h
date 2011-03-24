//
//  CheckinViewController.h
//  Demo
//
//  Created by Wei Kong on 3/4/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingImageView.h"


@interface CheckinViewController : UIViewController<UITextViewDelegate, UINavigationControllerDelegate, TapDetectingImageViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {

	IBOutlet UITextView *msgView;
	IBOutlet TapDetectingImageView *photoView;
	NSData *photoData;
	IBOutlet UILabel *photoLabel;
	IBOutlet UIButton *checkinButton;
}

-(IBAction)startCheckin;
@end
