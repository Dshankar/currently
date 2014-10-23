//
//  StatusTableViewController.h
//  Currently
//
//  Created by Darshan Shankar on 9/28/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateController.h"

@interface StatusTableViewController : UITableViewController <StatusUpdatedProtocol>

@property (nonatomic, retain) NSArray *profileData;

- (id) initWithProfileData:(NSArray *)data;
- (void)applicationActive:(id)sender;
    
@end
