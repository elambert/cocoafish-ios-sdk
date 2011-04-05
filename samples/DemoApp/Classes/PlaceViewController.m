//
//  PlaceViewController.m
//  Demo
//
//  Created by Wei Kong on 10/17/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "PlaceViewController.h"
#import "CheckinViewController.h"
#import "CocoaFishLibrary.h"

@implementation PlaceViewController

@synthesize place;
@synthesize placeCheckins;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

	if (placeCheckins == nil) {
		placeCheckins = [[NSMutableArray alloc] init];
	}
	if (_ccNetworkManager == nil) {
		_ccNetworkManager = [[CCNetworkManager alloc] initWithDelegate:self];
	}
	[_ccNetworkManager searchCheckins:place page:CC_FIRST_PAGE perPage:CC_DEFAULT_PER_PAGE];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePhotoDownloaded:) name:@"PhotoDownloadFinished" object:[Cocoafish defaultCocoafish]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePhotoProcessed:) name:@"PhotosProcessed" object:[Cocoafish defaultCocoafish]];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)handlePhotoProcessed:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];

	NSDictionary *photos = [userInfo valueForKey:@"photos"];
	@synchronized (self) {
		int i = 0;
		for (CCCheckin *checkin in placeCheckins) {
			CCPhoto *photo = [photos objectForKey:checkin.photo.objectId];
			if (photo) {
				[photo asyncGetPhoto:CC_THUMB_100];
			}
			
			i++;
			if (i == [photos count]) {
				break;
			}
		}
	}
		
}

-(void)handlePhotoDownloaded:(NSNotification *)notification
{
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark CCNetworkManager Delegate Methods
-(void)networkManager:(CCNetworkManager *)networkManager didGet:(NSArray *)objectArray objectType:(Class)objectType pagination:(CCPagination *)pagination
{
    if (objectType == [CCCheckin class]) {

        @synchronized(self) {
            self.placeCheckins = nil;
            placeCheckins = [[NSMutableArray alloc] initWithArray:objectArray];
        }
        [self.tableView reloadData];
    }
	
}

-(void)showCheckin
{
	CheckinViewController *controller = [[CheckinViewController alloc] initWithNibName:@"CheckinViewController" bundle:nil];
	controller.delegate = self;
	
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

-(void)startCheckin:(CheckinViewController *)controller message:(NSString *)message image:(CCUploadImage *)image
{
	[_ccNetworkManager createCheckin:place message:message image:image];
}

-(void)networkManager:(CCNetworkManager *)networkManager didCreate:(NSArray *)objectArray objectType:(Class)objectType
{
    CCCheckin *checkin;
    if (objectType == [CCCheckin class]) {
        checkin = [objectArray objectAtIndex:0];;
    }
	if (checkin) {
		@synchronized(self) {
			[placeCheckins insertObject:checkin atIndex:0];
		}
	
		[self.tableView reloadData];
	}
	
}


- (void)networkManager:(CCNetworkManager *)networkManager didFailWithError:(NSError *)error
{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Error!" 
						  message:[error localizedDescription]
						  delegate:self 
						  cancelButtonTitle:@"Ok"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	if ([[Cocoafish defaultCocoafish] getCurrentUser] != nil) {
		UIBarButtonItem *checkinButton = [[UIBarButtonItem alloc] initWithTitle:@"Checkin" style:UIBarButtonItemStylePlain target:self action:@selector(showCheckin)];
		self.navigationItem.rightBarButtonItem = checkinButton;
		[checkinButton release];
	}
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [placeCheckins count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell...
	CCCheckin *checkin = [placeCheckins objectAtIndex:indexPath.row];
	cell.imageView.image = nil;
	if (checkin.photo && checkin.photo.processed != NO) {
		cell.imageView.image = [checkin.photo getPhoto:CC_THUMB_100];
		if (cell.imageView.image == nil) {
			[checkin.photo asyncGetPhoto:CC_THUMB_100];
		}
	}
		
	cell.textLabel.text = checkin.message;
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Checked in %@", [[checkin user] firstName], timeElapsedFrom([checkin createdAt])];
	
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];

}


- (void)dealloc {
    [_ccNetworkManager release];
    [super dealloc];
}


@end

