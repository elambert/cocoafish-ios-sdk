//
//  UploadProgressViewController.h
//  Cocoafish-ios-demo
//
//  Created by Michael Goff on 9/19/09.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressViewController : UIViewController {
	UIProgressView *progressIndicator;
	IBOutlet UILabel *progressLabel;
}

@property (nonatomic, retain) IBOutlet UIProgressView *progressIndicator;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;

@end
