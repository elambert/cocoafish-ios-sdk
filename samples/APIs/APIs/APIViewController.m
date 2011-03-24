//
//  APIViewController.m
//  APIs
//
//  Created by Wei Kong on 3/21/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "APIViewController.h"
#import "APIsAppDelegate.h"

@interface APIViewController ()

-(NSString *)arrayDescription:(NSArray *)array;
-(void)showSuccessHeader:(CCResponse *)response;
@end

@implementation APIViewController

@synthesize ccNetworkManager = _ccNetworkManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _ccNetworkManager = [[CCNetworkManager alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_ccNetworkManager cancelAllRequests];
    [_ccNetworkManager release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSString *)arrayDescription:(NSArray *)array
{
    return [NSString stringWithFormat:@"{\n%@\n}", [array componentsJoinedByString:@"\n"]];
}

-(void)showSuccessHeader:(CCResponse *)response
{
    statusLabel.text = @"Success";
    header.text = [response.meta description];
}

#pragma mark - CCNetworkManager delegate
-(void)networkManager:(CCNetworkManager *)networkManager didFailWithError:(NSError *)error
{
    statusLabel.text = @"Failed";
    header.text = [error localizedDescription];
}

#pragma mark - Users APIs callbacks
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGetUser:(CCUser *)user
{
    [self showSuccessHeader:response];
    body.text = [user description];
}

-(void)didDeleteCurrentUser:(CCNetworkManager *)networkManager response:(CCResponse *)response
{
    [self showSuccessHeader:response];
}

#pragma mark - Places APIs callbacks
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGetPlaces:(NSArray *)places
{
    [self showSuccessHeader:response];
    body.text = [self arrayDescription:places];
}

-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didCreatePlace:(CCPlace *)place
{
    [self showSuccessHeader:response];

    body.text = [place description];
    ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPlace = place;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:place.objectId forKey:@"test_place_id"];
}

-(void)didDeletePlace:(CCNetworkManager *)networkManager response:(CCResponse *)response
{
    [self showSuccessHeader:response];

    ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPlace = nil;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"test_place_id"];


}

#pragma mark - Statues APIs callbacks
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didCreateStatus:(CCStatus *)status
{
    [self showSuccessHeader:response];

    body.text = [status description];
}

-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGetStatuses:(NSArray *)statuses
{

    [self showSuccessHeader:response];
    body.text = [self arrayDescription:statuses];
}

#pragma mark - Key Value APIs callbacks
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didSetKeyValue:(CCKeyValuePair *)keyvalue
{
    [self showSuccessHeader:response];
    body.text = [keyvalue description];
}

-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGetKeyValue:(CCKeyValuePair *)keyvalue
{
    [self showSuccessHeader:response];
    body.text = [keyvalue description];
}

-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didAppendKeyValue:(CCKeyValuePair *)keyvalue
{
    [self showSuccessHeader:response];
    body.text = [keyvalue description];
}

-(void)didDeleteKeyValue:(CCNetworkManager *)networkManager response:(CCResponse *)response
{
    [self showSuccessHeader:response];
}

#pragma mark - Checkins API Callbacks
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGetCheckins:(NSArray *)checkins
{
    [self showSuccessHeader:response];
    body.text = [self arrayDescription:checkins];
}

-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didCheckin:(CCCheckin *)checkin
{
    [self showSuccessHeader:response];
    body.text = [checkin description];
}

#pragma mark - Photos API Callbacks
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didCreatePhoto:(CCPhoto *)photo
{
    [self showSuccessHeader:response];
    if (((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPhoto == nil) {
        ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPhoto = photo;
    }
    body.text = [photo description];
}

-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGetPhotos:(NSArray *)photos
{
    [self showSuccessHeader:response];
    body.text = [self arrayDescription:photos];
}

-(void)didDeletePhoto:(CCNetworkManager *)networkManager response:(CCResponse *)response
{
    [self showSuccessHeader:response];
    ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPhoto = nil;
}
@end
