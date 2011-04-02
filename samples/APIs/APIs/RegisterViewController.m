//
//  RegisterViewController.m
//  Cocoafish-ios-demo
//
//  Created by Michael Goff on 11/27/09.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "RegisterViewController.h"

#define FIRST_NAME 0
#define LAST_NAME 1
#define EMAIL_ADDRESS 2
#define PASSWORD 3
#define PASSWORD_VERIFY 4
#define TABLE_SIZE 5

@interface RegisterViewController ()
- (void)startRegistration;
@end

@implementation RegisterViewController

@synthesize delegate;

#pragma mark -
#pragma mark Table View Methods

- (void)viewDidLoad {
    [super viewDidLoad];

	
	// hide the back arrow
	self.navigationItem.hidesBackButton = YES;

	// Add the cancel button
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked:)] autorelease];

	// init the array that contains our text fields
	if (textFields == nil) {
		textFields = [[NSMutableArray alloc] initWithCapacity:TABLE_SIZE];
		for (int i=0; i<TABLE_SIZE; i++) {
			UITextField *textField;
            textField = [[UITextField alloc] initWithFrame:CGRectMake(110, 11, 190, 25)];
			[textFields addObject:textField];
			[textField release];
		}
	}
	
	if (_ccNetworkManager == nil) {
		_ccNetworkManager = [[CCNetworkManager alloc] initWithDelegate:self];
	}
	
	// init the operation queue
	if (queue == nil) {
		queue = [[NSOperationQueue alloc] init];
	}
	
	// set the title
	self.navigationItem.title = @"Sign Up";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)dealloc {
	[textFields release];
	[tableView release];
	[registerProgress release];
	[_ccNetworkManager release];
    [super dealloc];
}

#pragma mark -
#pragma mark Navigation Controller methods

// don't register
-(void) cancelClicked:(id)sender {
	
	// resign the first responder
	for (UITextField *textField in textFields) {
		if ([textField isFirstResponder]) {
			[textField resignFirstResponder];
		}
	}
	
	// cancel any pending logins
	[_ccNetworkManager cancelAllRequests];
	[queue cancelAllOperations];
	
	// remove this view
	[self dismissModalViewControllerAnimated:YES];
	//[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return TABLE_SIZE;
	} else {
		return 1;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @	"Cell";
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}

	// Setup cells for the first section
	if (section == 0) {

		// Get the textField from our model
		UITextField *textField = (UITextField *)[textFields objectAtIndex:row];
		
		// Set textField defaults
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.returnKeyType = UIReturnKeyNext;
		textField.clearButtonMode = UITextFieldViewModeAlways;	
		textField.autocorrectionType = UITextAutocorrectionTypeNo;
		textField.clearsOnBeginEditing = NO;
		[textField setDelegate:(id)self];
		
		// Set specific properties
		if (row == FIRST_NAME) {
			textField.tag = FIRST_NAME;
			cell.textLabel.text = @"First Name:";
			textField.placeholder = @"First";
			textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		} else if (row == LAST_NAME) {
			textField.tag = LAST_NAME;
			cell.textLabel.text = @"Last Name:";
			textField.placeholder = @"Last";
			textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		} else if (row == EMAIL_ADDRESS) {
			textField.tag = EMAIL_ADDRESS;
			cell.textLabel.text = @"Email:";
			textField.placeholder = @"example@mac.com";
			textField.keyboardType = UIKeyboardTypeEmailAddress;
			textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		} else if (row == PASSWORD) {
			textField.tag = PASSWORD;
			cell.textLabel.text = @"Password:";
			textField.placeholder = @"enter password";
			textField.secureTextEntry = YES;
			textField.returnKeyType = UIReturnKeyNext;
			textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		} else if (row == PASSWORD_VERIFY) {
			textField.tag = PASSWORD_VERIFY;
			cell.textLabel.text = @"Verify:";
			textField.placeholder = @"re-enter password";
			textField.secureTextEntry = YES;
			textField.returnKeyType = UIReturnKeyDone;
			textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		}
		
		// Set cell defaults
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		[cell.contentView addSubview:textField];
		
	// Setup the signup button
	} else {
		cell.textLabel.text = @"Sign Up!";
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}
		
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath section];
	if (section == 1) {
		return indexPath;
	} else {
		return nil;
	}
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
	// Try registering if we've selected the signup button
	if (section == 1 && row == 0) {
		[tv deselectRowAtIndexPath:indexPath animated:YES];
		[self startRegistration];
	}
}

#pragma mark -
#pragma mark UITextField Delegate Methods

// Center the current textField in the view above the keyboard
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	UITableViewCell *cell = (UITableViewCell*) [[textField superview] superview];
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

// The "Next" button on the keyboard makes the next cell active
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	textField.text  = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[textField resignFirstResponder];
	if (textField.tag == PASSWORD_VERIFY) {
		[self startRegistration];
	} else {
		[(UITextField *)[textFields objectAtIndex:(textField.tag+1)] becomeFirstResponder];		
	}
	return YES;
}

#pragma mark -
#pragma mark Registration Methods

// Do the registration
- (void)startRegistration
{
	// resign the first responder
	for (UITextField *textField in textFields) {
		if ([textField isFirstResponder]) {
			[textField resignFirstResponder];
		}
	}

	// Verify that all fields have been completed
	for (UITextField *textField in textFields) {
		if (textField.text == nil || [textField.text compare:@""] == NSOrderedSame) {
			UIAlertView *alert = [[UIAlertView alloc] 
								  initWithTitle:@"Missing Information!" 
								  message:@"Please fill out all fields to register"
								  delegate:self 
								  cancelButtonTitle:@"Ok"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
	}
	
	// Get the text strings
	CCMutableUser *newUser = [[[CCMutableUser alloc] init] autorelease];
	newUser.first = ((UITextField *)[textFields objectAtIndex:FIRST_NAME]).text;
	newUser.last = ((UITextField *)[textFields objectAtIndex:LAST_NAME]).text;
	newUser.email = ((UITextField *)[textFields objectAtIndex:EMAIL_ADDRESS]).text;

	NSString *password = ((UITextField *)[textFields objectAtIndex:PASSWORD]).text;
	NSString *password_verify = ((UITextField *)[textFields objectAtIndex:PASSWORD_VERIFY]).text;
	
/*	// Make sure we have a valid email address
	if (!validateEmail(email_address)) {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Invalid Email Address!" 
							  message:@"Please enter a valid email address"
							  delegate:self 
							  cancelButtonTitle:@"Ok"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}*/
	
	// Make sure the passwords match
	if ([password compare:password_verify] != NSOrderedSame) {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Passwords Don't Match!" 
							  message:@"Enter the same password in the verify field"
							  delegate:self 
							  cancelButtonTitle:@"Ok"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	// Make sure the password is at least four chars long
	if ([password length] < 4) {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Password Is Too Short!" 
							  message:@"Your password must be at least four characters long"
							  delegate:self 
							  cancelButtonTitle:@"Ok"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	// Add the progress view
	if (registerProgress == nil) {
		registerProgress = [[ProgressViewController alloc] init];
		registerProgress.view.opaque = NO;
		[registerProgress.view setAlpha:0.8f];
		registerProgress.progressLabel.text = @"Registering user...";
		registerProgress.view.backgroundColor = [UIColor blackColor];
	}
	[self.view addSubview:registerProgress.view];
	
	[_ccNetworkManager registerUser:newUser password:password];
	
	// Debug
	 NSLog(@"Registering new user: %@, password: %@", newUser, password); 
}

#pragma mark -
#pragma mark CCNetworkManager Delegate methods
/* Sucessful registration */
- (void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didCreate:(CCObject *)object
{
    if ([object isKindOfClass:[CCUser class]]) {
        // Remove the modal view
        [self dismissModalViewControllerAnimated:NO];
        [delegate registerSucceeded];
    }
}


- (void)networkManager:(CCNetworkManager *)networkManager didFailWithError:(NSError *)error
{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Register Failed!" 
						  message:[error localizedDescription]
						  delegate:self 
						  cancelButtonTitle:@"Ok"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	// Remove the modal view
	[self dismissModalViewControllerAnimated:NO];
	[self.delegate registerFailed];
}
	
@end

