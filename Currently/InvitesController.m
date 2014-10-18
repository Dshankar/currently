//
//  InvitesController.m
//  Currently
//
//  Created by Darshan Shankar on 10/17/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "InvitesController.h"
#import "InvitesTableViewController.h"
#import "InviteFriendController.h"

@interface InvitesController ()
{
    UINavigationController *segmentedNavigation;
}
@end

@implementation InvitesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inviteFriend = [[InviteFriendController alloc] initWithNibName:nil bundle:nil];
    self.pendingInvites = [[InvitesTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
//    InviteFriendController *pendingInvites = [[InviteFriendController alloc] initWithNibName:nil bundle:nil];
    
//    viewControllers = [NSArray arrayWithObjects:pendingInvites, inviteFriend, nil];

    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Invite", @"Friends"]];
    [segmentControl addTarget:self action:@selector(indexDidChangeForSegmentControl:) forControlEvents:UIControlEventValueChanged];
    [self.navigationItem setTitleView:segmentControl];
    
    segmentedNavigation = [[UINavigationController alloc] initWithRootViewController:self.pendingInvites];
    segmentControl.selectedSegmentIndex = 0;
    [self.view addSubview:segmentedNavigation.view];
    

}

- (void)indexDidChangeForSegmentControl:(UISegmentedControl *)segmentControl {
    if(segmentControl.selectedSegmentIndex == 0){
        NSLog(@"0");
        [segmentedNavigation popViewControllerAnimated:YES];
    } else if(segmentControl.selectedSegmentIndex == 1){
        NSLog(@"1");
        [segmentedNavigation pushViewController:self.inviteFriend animated:YES];
    }
}


@end
