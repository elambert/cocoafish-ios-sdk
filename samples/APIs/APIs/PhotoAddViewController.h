//
//  PhotoAddViewController.h
//  APIs
//
//  Created by Wei Kong on 3/23/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingImageView.h"
@class CCObject;

@interface PhotoAddViewController : UIViewController<UITextFieldDelegate, UINavigationControllerDelegate, TapDetectingImageViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
    IBOutlet UITextField *collectionName;
	IBOutlet TapDetectingImageView *photoView;
	NSData *photoData;
    IBOutlet UILabel *photoLabel;
	IBOutlet UIButton *addButton;
    CCObject *object; // either a ccuser or a ccplace to add the photo to
}

@property(nonatomic, retain) CCObject *object;

-(IBAction)startAdd;
@end
