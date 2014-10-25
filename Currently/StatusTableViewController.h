//
//  StatusTableViewController.h
//  Currently
//
//  Created by Darshan Shankar on 9/28/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateController.h"
#import "SplashViewController.h"

@class DataManager;

@interface StatusTableViewController : UITableViewController <StatusUpdatedProtocol>

@property (nonatomic, retain) NSArray *profileData;
@property (nonatomic, retain) NSDictionary *myData;
@property (nonatomic, retain) DataManager *dataManager;

- (id) initWithData:(NSDictionary *)data;
- (void) applicationActive:(id)sender;
- (void) dataSourceHasUpdated;

@end
