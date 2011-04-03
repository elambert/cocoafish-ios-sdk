//
//  APIViewController.h
//  APIs
//
//  Created by Wei Kong on 3/21/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cocoafish.h"

@interface APIViewController : UIViewController <CCNetworkManagerDelegate> {
    IBOutlet UILabel *statusLabel;
    IBOutlet UITextView *header;
    IBOutlet UITextView *body;
    CCNetworkManager *_ccNetworkManager;

}

@property (nonatomic, retain, readonly) CCNetworkManager *ccNetworkManager;

@end
