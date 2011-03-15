//
//  ListViewController.h
//  Demo
//
//  Created by Wei Kong on 10/7/10.
//  Copyright 2011 Cocoafish Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListViewController : UITableViewController {

	NSArray *places;
}

@property (nonatomic, retain) NSArray *places;
-(void)showPlaces:(NSArray *)places;

@end
