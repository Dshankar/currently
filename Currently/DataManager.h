//
//  DataManager.h
//  Currently
//
//  Created by Darshan Shankar on 10/23/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatusTableViewController.h"
#import "InvitesTableViewController.h"
#import "NotificationsController.h"
#import "LoginController.h"

@interface DataManager : NSObject <AuthenticationCompletionProtocol>

@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) StatusTableViewController *status;
@property (nonatomic, retain) InvitesTableViewController *pendingInvites;
@property (nonatomic, retain) NotificationsController *notifications;

- (id) initWithControllers:(NSArray *)viewControllers;
- (void) updateData;

@end
