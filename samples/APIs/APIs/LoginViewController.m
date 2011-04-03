//
//  LoginViewController.m
//  Cocoafish-ios-demo
//
//  Created by Michael Goff on 11/23/09.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "Cocoafish.h"

#define SECTION_LOGIN 0
#define EMAIL_ADDRESS 0
#define PASSWORD 1
#define LOGIN_TABLE_SIZE 2

#define SECTION_SIGNUP 1
#define SIGNUP 0
#define SIGNUP_TABLE_SIZE 1

#define TOTAL_SECTIONS 2

#define ROW_HEIGHT 40
#define CELL_WIDTH 320.0
#define LABEL_HEIGHT 20

@implementation LoginViewController

@synthesize delegate;
@synthesize emailTableCell;
@synthesize passwordTableCell;
@synthesize emailTextField;
@synthesize passwordTextField;

#pragma mark -
#pragma mark UIView Methods
	
- (void)viewDidLoad {
    [super viewDidLoad];

	// init the array that contains our text fields
	if (textFields == nil) {
		textFields = [[NSMutableArray alloc] initWithCapacity:LOGIN_TABLE_SIZE];
		[textFields addObject:emailTextField];
		[textFields addObject:passwordTextField];
	}
	
	// hide the back arrow
	self.navigationItem.hidesBackButton = YES;
	
	// set the title
	self.navigationItem.title = @"Login";
	
	UIBarButtonItem *loginButton;
	
	// create the login button	
	loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(startLogin)];
	self.navigationItem.rightBarButtonItem = loginButton;
	[loginButton release];
	
	if (_ccNetworkManager == nil) {
		_ccNetworkManager = [[CCNetworkManager alloc] initWithDelegate:self];
	}
	
	
}

-(void)viewDidUnload
{
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	// Get the textField from our model
//	UITextField *emailField = (UITextField *)[textFields objectAtIndex:EMAIL_ADDRESS];
	//[emailField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
/*	if (isIPad()) {
		return YES;
	} else {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}*/
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

}

/*// don't login
-(void)cancelClicked:(id)sender {
	
	
	UIBarButtonItem *loginButton;
	
	// create the login button	
	loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(startLogin)];
	self.navigationItem.rightBarButtonItem = loginButton;
	[loginButton release];
	
	// resign the first responder
	for (UITextField *textField in textFields) {
		if ([textField isFirstResponder]) {
			[textField resignFirstResponder];
		}
	}
	
	// cancel any pending logins
	[_ccNetworkManager cancelAllRequests];

	// call the delegate's fail method
	[self.delegate loginFailed];
} */

#pragma mark -
#pragma mark Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//table = tableView;
	//tableView.backgroundColor = [UIColor clearColor];
    return TOTAL_SECTIONS;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == SECTION_LOGIN) {
		return LOGIN_TABLE_SIZE;
	} else if (section == SECTION_SIGNUP) {
		return SIGNUP_TABLE_SIZE;
	}
	return 0;
}

// section headers
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == SECTION_LOGIN ) {
		return NSLocalizedString(@"Login to add photos & reviews, or to view your profile:", @"Login view login section header"); 
	} else if (section == SECTION_SIGNUP) {
		return NSLocalizedString(@"If you don't have an account:", @"Login view signup section header"); 
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];

	// login form
	if (section == SECTION_LOGIN) {
		if (row == EMAIL_ADDRESS) {
			return emailTableCell;
		} else {
			return passwordTableCell;
		}

	// signup button
	} else if (section == SECTION_SIGNUP) {
		static NSString *CellIdentifier = @	"Cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.textLabel.text = @"Sign Up!";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
	}
	return nil;
}

#pragma mark -
#pragma mark Table Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath section];
	if (section == 1) {
		return indexPath;
	} else {
		return nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath section];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (section == SECTION_SIGNUP) {
		RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
		registerViewController.delegate = self;
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:registerViewController];
		navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:navController animated:YES];
		[registerViewController release];
		[navController release];
	}
}

- (void)dealloc {
	[textFields release];
	[_ccNetworkManager release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITextField Delegate Methods

// Add the cancel button when we start editing
-(void)textFieldDidBeginEditing:(UITextField *)textField {

	UIBarButtonItem *cancelButton;
	
	// create the login button	
	cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissKeyboard)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
}

-(void)dismissKeyboard
{
	self.navigationItem.leftBarButtonItem = nil;
	[emailTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];
}


// The "Next" button on the keyboard makes the next cell active
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	if (textField == passwordTextField) {
		[self startLogin];
	} else {
		[passwordTextField becomeFirstResponder];		
	}
	return YES;
}

#pragma mark -
#pragma mark Login Methods

-(IBAction)fbLoginButtonPressed:(id)sender
{
    if ([[Cocoafish defaultCocoafish] getFacebook] == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] 
                 initWithTitle:@"Error" 
                 message:@"Please initialize Cocoafish with a valid facebook id first!"
                 delegate:self 
                 cancelButtonTitle:@"Ok"
                 otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
	[[Cocoafish defaultCocoafish] facebookAuth:[NSArray arrayWithObjects:@"publish_stream", @"email", @"offline_access", nil] delegate:self];
}

// start the login process
- (void)startLogin
{
	// Verify that all fields have been completed
	for (UITextField *textField in textFields) {
		if (textField.text == nil || [textField.text compare:@""] == NSOrderedSame) {
			UIAlertView *alert = [[UIAlertView alloc] 
								  initWithTitle:@"Missing Information!" 
								  message:@"Fill out both fields to login."
								  delegate:self 
								  cancelButtonTitle:@"Ok"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;

		// Clear off the whitespace			
		} else {
			textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		}
	}
	
	// Get the text strings
	NSString *email_address = ((UITextField *)[textFields objectAtIndex:EMAIL_ADDRESS]).text;
	NSString *password = ((UITextField *)[textFields objectAtIndex:PASSWORD]).text;
	
	[_ccNetworkManager login:email_address password:password];

	/*// add the cancel button
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											   target:self action:@selector(cancelClicked:)] autorelease];*/
	self.navigationItem.leftBarButtonItem = nil;

}

#pragma mark -
#pragma mark CCNetworkManager delegate methods
-(void)networkManager:(CCNetworkManager *)networkManager didLogin:(CCUser *)user
{
		
	// Clear the textFields
	for (UITextField *textField in textFields) {
		textField.text = nil;
	}
	//self.loginButton.enabled = YES;
	
	[self.navigationController popViewControllerAnimated:NO];
	
	// call the delegate's method
	[self.delegate loginSucceeded];

}

// unsuccessful login
- (void)networkManager:(CCNetworkManager *)networkManager didFailWithError:(NSError *)error
{
	NSString *msg = [NSString stringWithFormat:@"%@",[error localizedDescription]];
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Failed!" 
						  message:msg
						  delegate:self 
						  cancelButtonTitle:@"Ok"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}


#pragma mark -
#pragma mark RegisterDelegate methods

-(void)registerSucceeded
{
	NSLog(@"Register controller succeeded now we're in login controller");
	
	// call the delegate's method
	[self.delegate loginSucceeded];
	
	[self.navigationController popViewControllerAnimated:NO];

}

-(void)registerFailed
{
	NSLog(@"Register controller failed");
}

#pragma -
#pragma mark CCFBSessionDelegate methods
-(void)fbDidLogin
{
	NSLog(@"fbDidLogin");
	// call the delegate's method
	[self.navigationController popViewControllerAnimated:NO];

	[self.delegate loginSucceeded];
	
}

-(void)fbDidNotLogin:(BOOL)cancelled error:(NSError *)error
{
	if (error == nil) {
		// user failed to login to facebook or cancelled the login
		return;
	}
	NSString *msg = [NSString stringWithFormat:@"%@",[error localizedDescription]];
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Failed to login with Facebook" 
						  message:msg
						  delegate:self 
						  cancelButtonTitle:@"Ok"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}
@end

