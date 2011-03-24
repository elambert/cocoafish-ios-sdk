//
//  LoginViewController.h
//  Cocoafish-ios-demo
//
//  Created by Michael Goff on 11/23/09.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterViewController.h"
#import "FBLoginButton.h"

@class CCNetworkManager;

@protocol LoginDelegate;

@interface LoginViewController : UITableViewController <UITextFieldDelegate, RegisterDelegate, CCNetworkManagerDelegate, CCFBSessionDelegate> {
	//UITableView *table;
	NSMutableArray *textFields;
	
	// init params
	id <LoginDelegate> delegate;
	UITableViewCell *emailTableCell;
	UITableViewCell *passwordTableCell;
	UITextField *emailTextField;
	UITextField *passwordTextField;
	IBOutlet FBLoginButton *fbLoginButton;
	
	CCNetworkManager *_ccNetworkManager;
}

-(IBAction)fbLoginButtonPressed:(id)sender;

@property (nonatomic, assign) id <LoginDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableViewCell *emailTableCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *passwordTableCell;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

-(void)startLogin;

@end

@protocol LoginDelegate
-(void)loginSucceeded;
-(void)loginFailed;
@end