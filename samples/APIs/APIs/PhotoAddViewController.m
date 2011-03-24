//
//  PhotoAddViewController.m
//  APIs
//
//  Created by Wei Kong on 3/23/11.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import "PhotoAddViewController.h"
#import "APIViewController.h"
#import "CocoaFishLibrary.h"

// review photo image size
#define PHOTO_MAX_SIZE 800

// define jpeg compression factor
#define JPEG_COMPRESSION 0.5

@interface PhotoAddViewController ()
-(void)preparePhoto:(UIImage *)image;
-(void)dismissKeyboard;
- (void)showImagePicker:(NSInteger)sourceType rectForPopover:(CGRect)rect;
@end

@implementation PhotoAddViewController
@synthesize object;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	photoView.delegate = self;
    collectionName.delegate = self;
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [object release];
    [super dealloc];
}


- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint
{
	[self dismissKeyboard];
	// Show the action sheet if we have a camera
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:nil
									  delegate:self
									  cancelButtonTitle:@"Cancel"
									  destructiveButtonTitle:nil
									  otherButtonTitles:@"Take Photo", @"Choose from Library",nil];
		[actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
		[actionSheet showInView:[[self view] window]];
		[actionSheet release];
		
		// Otherwise go directly to the photo library chooser
	} else {
		[self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary rectForPopover:CGRectZero];
	}
}


#pragma mark -
#pragma mark UIActionSheet Delegate Methods

// action delegate will only be shown on devices with cameras
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self showImagePicker:UIImagePickerControllerSourceTypeCamera rectForPopover:CGRectZero];
	} else if (buttonIndex == 1) {
		[self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary rectForPopover:CGRectZero];
	}
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{	
	if (photoData) {
		[photoData release];
		photoData = nil;
	}
	
	// get the image
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	//photoImage = [image retain];
	
	// Dismiss the image selection, hide the picker and show the image view with the picked image
	[picker dismissModalViewControllerAnimated:YES];
	
	// Write the image to the photo album if we took it with the camera
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		NSLog(@"Start saving fullsize image to the camera roll");
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
		NSLog(@"End saving fullsize image to the camera roll");
	}
	
	[self preparePhoto:image];
	
	photoLabel.hidden = YES;
	[photoView setImage:image];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{
	[picker dismissModalViewControllerAnimated:YES];
}

-(void)preparePhoto:(UIImage *)photoImage
{		
	if (photoData == nil) {
		
		// Resample the image for sending
		NSLog(@"Start scale and rotate image from original size to %d", PHOTO_MAX_SIZE);
		UIImage *image = scaleAndRotateImage(photoImage, PHOTO_MAX_SIZE);
		NSLog(@"End scale and rotate image from original size to %d", PHOTO_MAX_SIZE);
		
		// convert to jpeg and save
		photoData = [UIImageJPEGRepresentation(image, JPEG_COMPRESSION) retain];
	}
    
}

// Set up the image picker controller and add it to the view
- (void)showImagePicker:(NSInteger)sourceType rectForPopover:(CGRect)rect {
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.delegate = self;
	[self presentModalViewController:imagePickerController animated:YES];
	[imagePickerController release];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	UIBarButtonItem *doneButton;
	
	// create the login button	
	doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissKeyboard)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}

-(void)dismissKeyboard
{
	self.navigationItem.rightBarButtonItem = nil;
	[collectionName resignFirstResponder];
}

-(IBAction)startAdd
{
    //  [self.navigationController popViewControllerAnimated:YES];
    
    APIViewController *apiController = [[APIViewController alloc] initWithNibName:@"APIViewController" bundle:nil];  
    
    [apiController.ccNetworkManager  createPhoto:object collectionName:collectionName.text photoData:photoData contentType:@"image/jpeg"];
    [self.navigationController pushViewController:apiController animated:YES];
    [apiController release];
    
}

@end