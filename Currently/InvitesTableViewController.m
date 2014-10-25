//
//  InvitesTableViewController.m
//  Currently
//
//  Created by Darshan Shankar on 10/17/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "InvitesTableViewController.h"
#import "FriendRequestsTableViewCell.h"
#import "LoginController.h"
#import "NetworkManager.h"

@interface InvitesTableViewController ()
@end

@implementation InvitesTableViewController

- (id)initWithRequests:(NSArray *)requestData {
    self = [super init];
    if(self){
        self.requests = requestData;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[FriendRequestsTableViewCell class] forCellReuseIdentifier:@"InviteCell"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"View Will Appear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.requests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FriendRequestsTableViewCell *cell = (FriendRequestsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"InviteCell"];
    if(cell == nil){
        cell = [[FriendRequestsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InviteCell"];
    }
    [cell.confirmButton addTarget:self action:@selector(acceptFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
    [cell.cancelButton addTarget:self action:@selector(declineFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *thisRequest = [self.requests objectAtIndex:[indexPath row]];
    
    [cell.name setText:[thisRequest objectForKey:@"name"]];
    [cell.username setText:[thisRequest objectForKey:@"username"]];
    
    NSString *imageURL = [thisRequest objectForKey:@"image"];
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
    NSError *error;
    NSData *imageData = [NSURLConnection sendSynchronousRequest:imageRequest returningResponse:nil error:&error];
    if(error != nil){
        NSLog(@"image error: %@", error);
    } else {
        [cell.image setImage:[UIImage imageWithData:imageData]];
    }
    return cell;
}

- (void) acceptFriendRequest:(id)sender {
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *hitIndex = [self.tableView indexPathForRowAtPoint:hitPoint];
    
    FriendRequestsTableViewCell *cell = (FriendRequestsTableViewCell *)[self.tableView cellForRowAtIndexPath:hitIndex];

    [self performAction:FriendRequestActionTypeAccept forUsername:cell.username.text];
}


- (void) declineFriendRequest:(id)sender {
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *hitIndex = [self.tableView indexPathForRowAtPoint:hitPoint];
    
    FriendRequestsTableViewCell *cell = (FriendRequestsTableViewCell *)[self.tableView cellForRowAtIndexPath:hitIndex];
    [self performAction:FriendRequestActionTypeDecline forUsername:cell.username.text];
}

- (void) performAction:(FriendRequestActionType)action forUsername:(NSString *)username {

    NetworkManager *manager = [NetworkManager getInstance];
    
    [manager sendAction:action forFriendRequestFrom:username completionHandler:^(int code, NSError *error) {
        if(code == 401 || error.code == -1012){
            NSLog(@"Update updateStatus error 401/-1012");
            [manager refreshTokensWithCompletionHandler:^(int refreshCode, NSError *refreshError) {
                if(refreshCode == 200){
                    [self performAction:action forUsername:username];
                } else if(refreshCode == 403 || refreshError){
                    LoginController *login = [[LoginController alloc] initWithNibName:nil bundle:nil];
                    login.delegate = self;
                    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:login];
                    [self presentViewController:loginNav animated:YES completion:nil];
                }
            }];
        } else if(code == 400 || code == 500){
            NSLog(@"error");
        } else if(code == 200 || error == nil){
            // success
            NSLog(@"success");
        }
    }];
}

- (void) successfulAuthentication {
    // do nothing?
}

- (void) dataSourceHasUpdated {
    [self.tableView reloadData];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

@end
