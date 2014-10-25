//
//  InvitesTableViewController.h
//  Currently
//
//  Created by Darshan Shankar on 10/17/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashViewController.h"

@class DataManager;

typedef enum : NSUInteger {
    FriendRequestActionTypeAccept,
    FriendRequestActionTypeDecline
} FriendRequestActionType;


@interface InvitesTableViewController : UITableViewController <AuthenticationCompletionProtocol>

- (id) initWithRequests:(NSArray *)requestData;
- (void) dataSourceHasUpdated;
@property (nonatomic, retain) NSArray *requests;
@property (nonatomic, retain) DataManager *dataManager;

@end
