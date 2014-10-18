//
//  InvitesController.h
//  Currently
//
//  Created by Darshan Shankar on 10/17/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InvitesTableViewController.h"
#import "InviteFriendController.h"

@interface InvitesController : UIViewController

@property (nonatomic, retain) InviteFriendController *inviteFriend;
@property (nonatomic, retain) InvitesTableViewController *pendingInvites;

@end
