//
//  RegisterViewController.h
//  Cocoafish-ios-demo
//
//  Created by Michael Goff on 11/27/09.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressViewController.h"
#import "Cocoafish.h"

@protocol RegisterDelegate;

@interface RegisterViewController : UITableViewController <CCNetworkManagerDelegate> {
	NSOperationQueue *queue;
	NSMutableArray *textFields;
	IBOutlet UITableView *tableView;
	ProgressViewController *registerProgress;
	
	// init params
	id <RegisterDelegate> delegate;
	
	CCNetworkManager *_ccNetworkManager;
}

@property (nonatomic, assign) id <RegisterDelegate> delegate;

@end

@protocol RegisterDelegate
-(void)registerSucceeded;
-(void)registerFailed;
@end
