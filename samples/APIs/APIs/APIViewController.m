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
@synthesize isDeletePlace;
@synthesize isDeletePhoto;

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

#pragma mark - CCNetworkManager delegate on failure
-(void)networkManager:(CCNetworkManager *)networkManager didFailWithError:(NSError *)error
{
    statusLabel.text = @"Failed";
    header.text = [error localizedDescription];
}

#pragma mark - get callback
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didGet:(NSArray *)objectArray pagination:(CCPagination *)pagination
{
    [self showSuccessHeader:response];
    body.text = [self arrayDescription:objectArray ];
}


#pragma mark - update callback
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didUpdate:(CCObject *)object
{
    [self showSuccessHeader:response];
    body.text = [object description];
}

#pragma mark - create callback
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didCreate:(CCObject *)object
{
    [self showSuccessHeader:response];
    body.text = [object description];
    if ([object isKindOfClass:[CCPlace class]]) {
        ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPlace = (CCPlace *)object;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:object.objectId forKey:@"test_place_id"];
    } else if ([object isKindOfClass:[CCPhoto class]] && ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPhoto == nil) {
        ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPhoto = (CCPhoto *)object;
    }
}

#pragma mark - delete callback
-(void)didDelete:(CCNetworkManager *)networkManager response:(CCResponse *)response
{
    [self showSuccessHeader:response];
    if (isDeletePlace) {
        ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPlace = nil;
    } else if (isDeletePhoto) {
        ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPhoto = nil;
    }
}


#pragma mark - Users APIs callbacks
-(void)networkManager:(CCNetworkManager *)networkManager response:(CCResponse *)response didUpdateUser:(CCUser *)user
{
    [self showSuccessHeader:response];
    body.text = [user description];
}

@end
