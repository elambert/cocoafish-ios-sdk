//
//  RootViewController.m
//  APIs
//
//  Created by Wei Kong on 3/18/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "RootViewController.h"
#import "Cocoafish.h"
#import "LoginViewController.h"
#import "APIViewController.h"
#import "AlertPrompt.h"
#import "APIsAppDelegate.h"
#import "PhotoAddViewController.h"

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!_ccNetworkManager) {
        _ccNetworkManager = [[CCNetworkManager alloc] initWithDelegate:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![[Cocoafish defaultCocoafish] getCurrentUser]) {
        // not logged in yet, show the login/signup window
        LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:NO];
        [controller release];
    } else {
        UIBarButtonItem *button;
        
		// create the logout button	
		button = [[UIBarButtonItem alloc] initWithTitle:@"Delete Account" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAccount)];
		self.navigationItem.rightBarButtonItem = button;
		[button release];
		
        button = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(startLogout)];
        self.navigationItem.leftBarButtonItem = button;
		[button release];
		
    }
    testPlace = ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPlace;
    if (!testPlace) {
        // remove test place from last run
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *test_place_id = [prefs stringForKey:@"test_place_id"];
        if (test_place_id) {
            [_ccNetworkManager deletePlace:test_place_id];
            [prefs removeObjectForKey:@"test_place_id"];
        }
    }

    [self.tableView reloadData];
}

-(void)startLogout
{
    [_ccNetworkManager logout];
}

-(void)deleteAccount
{
    [_ccNetworkManager deleteCurrentUser];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!testPlace) {
        return 4;
    }
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case USERS: 
            return 3;
        case PLACES:
            if (testPlace) {
                return 3;
            } else {
                return 2;
            }
        case CHECKINS:
            return 4;
        case STATUSES:
            return 3;
     //   case MESSAGES:
      //      return 4;
        case PHOTOS:
            return 3;
        case KEY_VALUES:
            return 2;
        default:
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case USERS:
            return @"Users";
        case PLACES:
            return @"Places";
        case CHECKINS:
            return @"Checkins";
        case STATUSES:
            return @"Statuses";
     //   case MESSAGES:
     //       return @"Messages";
        case PHOTOS:
            return @"Photoes";
        case KEY_VALUES:
            return @"Key/Value Pairs";
        default:
            break;
    }
    return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    switch (indexPath.section) {
        case USERS:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Show User Profile";
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Show Logged in User Profile";
            } else {
                if ([[Cocoafish defaultCocoafish] getCurrentUser].facebookAccessToken != nil) {
                    cell.textLabel.text = @"Unlink From Facebook";
                } else {
                    cell.textLabel.text = @"Link to Facebook";
                }
            }
            break;
        case PLACES:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"List all places";
                    break;
                case 1:
                    if (testPlace) {
                        cell.textLabel.text = @"Show test place";
                        break;
                    }
                    // fall through
                case 2:
                default:
                    if (testPlace) {
                        cell.textLabel.text = @"Delete test place";
                    } else {
                        cell.textLabel.text = @"Create test place";
                    }
                    break;
                
            }
            break;
        case CHECKINS:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Check into a place";
                    break;
                case 1: 
                    cell.textLabel.text = @"List Checkins of a place";
                    break;
                case 2:
                    cell.textLabel.text = @"List logged user checkins";
                    break;
                case 3:
                default:
                    cell.textLabel.text = @"List Checkins of a User";
                    break;
            }
            break;
        case STATUSES:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create Status";
                    break;
                case 1:
                    cell.textLabel.text = @"Show current user Status";
                    break;
                case 2:
                default:
                    cell.textLabel.text = @"Show any user status";
                    break;
            }
            break;
        case PHOTOS:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Upload a Photo of a place";
                    break;
                case 1:
                    cell.textLabel.text = @"Get Photos of a place";
                    break;
                case 2:
                default:
                    cell.textLabel.text = @"Show Photo Info";
                    break;
            }
            break;
        case KEY_VALUES:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Set Value for Key('Test')";
            } else {
                cell.textLabel.text = @"Get Value of key('Test')";
            }
            break;
        default:
            break;
    }
    // Configure the cell.
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/

    AlertPrompt *prompt;
    APIViewController *controller = [[APIViewController alloc] initWithNibName:@"APIViewController" bundle:nil];  
    CCMutablePlace *newPlace;
    CheckinViewController *checkinController;
    PhotoAddViewController *photoController;
    UIAlertView *alert;
    switch (indexPath.section) {
        case USERS:
            if (indexPath.row == 0) {
                // show user profile
                [controller.ccNetworkManager showUser:[[Cocoafish defaultCocoafish] getCurrentUser].objectId];
            } else if (indexPath.row == 1) {
                [controller.ccNetworkManager showCurrentUser];
            } else {
                if ([[Cocoafish defaultCocoafish] getFacebook] == nil) {
         
                    alert = [[UIAlertView alloc] 
                                          initWithTitle:@"Error" 
                                          message:@"Please initialize Cocoafish with a valid facebook id first!"
                                          delegate:self 
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                } else if ([[Cocoafish defaultCocoafish] getCurrentUser].facebookAccessToken == nil) {
                    // link with facebook
                    [[Cocoafish defaultCocoafish] facebookAuth:[NSArray arrayWithObjects:@"publish_stream", @"email", @"offline_access", nil] delegate:self];
                } else {
                    // unlink rom facebook
                    NSError *error;
                    [[Cocoafish defaultCocoafish] unlinkFromFacebook:&error];
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

                return;
            }
            break;
        case PLACES:
            switch (indexPath.row) {

                case 0:
                    [controller.ccNetworkManager searchPlaces:nil distance:nil page:CC_FIRST_PAGE perPage:CC_DEFAULT_PER_PAGE];
                    break;
                case 1:
                    if (testPlace) {
                        [controller.ccNetworkManager showPlace:testPlace.objectId];
                        break;
                    }
                    // fall thru
                case 2:
                default:
                    if (testPlace) {
                        // delete the test place
                        [controller.ccNetworkManager deletePlace:testPlace.objectId];
                    } else {
                        // create a test place
                        newPlace = [[CCMutablePlace alloc] init];
                        newPlace.name = @"Cocoafish";
                        newPlace.address = @"58 South Park Ave.";
                        newPlace.city = @"San Francisco";
                        newPlace.state = @"California";
                        newPlace.postalCode = @"94107-1807";
                        newPlace.country = @"United States";
                        newPlace.website = @"http://cocoafish.com";
                        newPlace.twitter = @"cocoafish";
                        newPlace.location = [[CLLocation alloc] initWithLatitude:37.782227 longitude:-122.393159];
                        [controller.ccNetworkManager createPlace:newPlace];
                        
                    }
                    break;
                    
            }
            break;
        case CHECKINS:
            switch (indexPath.row) {
                case 0:
                    checkinController = [[CheckinViewController alloc] initWithNibName:@"CheckinViewController" bundle:nil];
                    
                    [self.navigationController pushViewController:checkinController  animated:YES];
                    [checkinController release];
                    return;
                    break;
                case 1: 
                    [controller.ccNetworkManager getPlaceCheckins:testPlace page:CC_FIRST_PAGE perPage:CC_DEFAULT_PER_PAGE];
                    break;
                case 2:
                    [controller.ccNetworkManager showCurrentUserCheckins:CC_FIRST_PAGE perPage:CC_DEFAULT_PER_PAGE];
                    break;
                case 3:
                default:
                    [controller.ccNetworkManager showUserCheckins:[[Cocoafish defaultCocoafish] getCurrentUser].objectId page:CC_FIRST_PAGE perPage:CC_DEFAULT_PER_PAGE];
                    break;
            }
            break;
        case STATUSES:
            switch (indexPath.row) {
                case 0:
                    prompt = [AlertPrompt alloc];
                    prompt = [prompt initWithTitle:@"New Status" message:@"Please enter your status" delegate:self cancelButtonTitle:@"Cancel" okButtonTitle:@"Okay" defaultInput:@"Feeling good!"];
                    lastIndexPath = [indexPath copy];
                    [prompt show];
                    [prompt release];
                    [controller release];
                    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                    
                    return;

                    break;
                case 1:
                    // get the logged in user's statuses
                    [controller.ccNetworkManager showCurrentUserStatuses:CC_FIRST_PAGE perPage:CC_DEFAULT_PER_PAGE];
                    break;
                case 2:
                default:
                    // get a user's statuses
                    [controller.ccNetworkManager showUserStatuses:[[Cocoafish defaultCocoafish] getCurrentUser] page:CC_FIRST_PAGE perPage:CC_DEFAULT_PER_PAGE];
                    break;
            }
            break;
        case PHOTOS:
            switch (indexPath.row) {
                case 0:
                    // Add a photo to a place
                    photoController = [[PhotoAddViewController alloc] initWithNibName:@"PhotoAddViewController" bundle:nil];
                    
                    [self.navigationController pushViewController:photoController  animated:YES];
                    [photoController release];
                    return;
                    break;
                case 1:
                    // get Photos of a place
                    [controller.ccNetworkManager searchPhotos:testPlace collectionName:nil page:CC_FIRST_PAGE perPage:CC_DEFAULT_PER_PAGE];
                    break;
                case 2:
                default:
               //    cell.textLabel.text = @"Show Photo Info";
                    break;
            }
            break;
        case KEY_VALUES:
            if (indexPath.row == 0) {
                prompt = [AlertPrompt alloc];
                prompt = [prompt initWithTitle:@"Enter a value for key 'Test'" message:@"Please enter a Value for Key 'Test'" delegate:self cancelButtonTitle:@"Cancel" okButtonTitle:@"Okay" defaultInput:@"Awesome!"];
                lastIndexPath = [indexPath copy];
                [prompt show];
                [prompt release];
                [controller release];
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                
                return;
            } else {
                [controller.ccNetworkManager getValueForKey:@"Test"];
            }
            break;
        default:
            break;
    }
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [_ccNetworkManager release];
    [lastIndexPath release];
    [super dealloc];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        NSString *entered = [(AlertPrompt *)alertView enteredText];
        APIViewController *controller = [[APIViewController alloc] initWithNibName:@"APIViewController" bundle:nil];  
        if (lastIndexPath.section == STATUSES) {
            [controller.ccNetworkManager createUserStatus:entered];
        } else {
            [controller.ccNetworkManager setValueForKey:@"Test" value:entered];
        }
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        [lastIndexPath release];
        lastIndexPath = nil;
    } 
}

#pragma - CCNetworkManager delegate
-(void)networkManager:(CCNetworkManager *)networkManager didFailWithError:(NSError *)error
{

}

-(void)didDeletePlace:(CCNetworkManager *)networkManager response:(CCResponse *)response
{
}

// successful logout
- (void)didLogout:(CCNetworkManager *)networkManager response:(CCResponse *)response
{	
	// show login window
	LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
	[self.navigationController pushViewController:loginViewController animated:NO];
	[loginViewController release];
	
}

-(void)didDeleteCurrentUser:(CCNetworkManager *)networkManager response:(CCResponse *)response
{
    // show login window
	LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
	[self.navigationController pushViewController:loginViewController animated:NO];
	[loginViewController release];
}

#pragma -
#pragma mark CCFBSessionDelegate methods
-(void)fbDidLogin
{
	NSLog(@"fbDidLogin");

    [self.tableView reloadData];
    
}

-(void)fbDidNotLogin:(BOOL)cancelled error:(NSError *)error
{
	if (error == nil) {
		// user failed to login to facebook or cancelled the login
		return;
	}
	NSString *msg = [NSString stringWithFormat:@"%@",[error localizedDescription]];
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Failed to link with Facebook" 
						  message:msg
						  delegate:self 
						  cancelButtonTitle:@"Ok"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

@end
