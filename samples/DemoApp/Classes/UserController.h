//
//  UserController.h
//  Demo
//
//  Created by Wei Kong on 10/15/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cocoafish.h"

@interface UserController : UITableViewController <CCNetworkManagerDelegate, CCFBSessionDelegate> {

	NSArray *userCheckins; // list of places checked in
	CCNetworkManager *_ccNetworkManager;
}

-(void)getUserCheckins;

@end
