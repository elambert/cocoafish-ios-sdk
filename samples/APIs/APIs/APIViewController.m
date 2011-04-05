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

#pragma mark - CCNetworkManager delegate on failure
-(void)networkManager:(CCNetworkManager *)networkManager didFailWithError:(NSError *)error
{
    statusLabel.text = @"Failed";
    body.text = [error localizedDescription];
}

#pragma mark - get callback
-(void)networkManager:(CCNetworkManager *)networkManager didGet:(NSArray *)objectArray objectType:(Class)objectType pagination:(CCPagination *)pagination
{
    statusLabel.text = @"Success";
    if (pagination) {
        body.text = [NSString stringWithFormat:@"%@\n%@", [pagination description], [self arrayDescription:objectArray]];
    } else {
        body.text = [self arrayDescription:objectArray];
    }
}

#pragma mark - update callback
-(void)networkManager:(CCNetworkManager *)networkManager didUpdate:(NSArray *)objectArray objectType:(Class)objectType
{
    statusLabel.text = @"Success";
    body.text = [self arrayDescription:objectArray];
}

#pragma mark - create callback
-(void)networkManager:(CCNetworkManager *)networkManager didCreate:(NSArray *)objectArray objectType:(Class)objectType
{
    statusLabel.text = @"Success";
    body.text = [self arrayDescription:objectArray];
    if (objectType == [CCPlace class]) {
        CCPlace *place = [objectArray objectAtIndex:0];
        ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPlace = place;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:place.objectId forKey:@"test_place_id"];
    } else if (objectType == [CCPhoto class] && ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPhoto == nil) {
        CCPhoto *photo = [objectArray objectAtIndex:0];
        ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPhoto = photo;
    } else if (objectType == [CCEvent class]) {
        CCEvent *event = [objectArray objectAtIndex:0];
        ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testEvent = event;
    }
}

#pragma mark - delete callback
-(void)networkManager:(CCNetworkManager *)networkManager didDelete:(Class)objectType
{
    statusLabel.text = @"Success";
    if (objectType == [CCPlace class]) {
        ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPlace = nil;
    } else if (objectType == [CCPhoto class]) {
        ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testPhoto = nil;
    } else if (objectType == [CCEvent class]) {
        ((APIsAppDelegate *)[UIApplication sharedApplication].delegate).testEvent = nil;
    }
}

@end
