//
//  SignupController.m
//  Currently
//
//  Created by Darshan Shankar on 10/13/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "SignupController.h"
#import "LoginCredentialCell.h"
#import "NetworkManager.h"
#import "StatusTableViewController.h"

@interface SignupController ()

@end

@implementation SignupController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Sign Up"];
    [self.tableView registerClass:[LoginCredentialCell class] forCellReuseIdentifier:@"SignupCell"];
    
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(signup:)];
    [self.navigationItem setRightBarButtonItem:submit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)signup:(id)sender {
    NSString *name = ((LoginCredentialCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField.text;
    NSString *username = ((LoginCredentialCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField.text;
    NSString *password = ((LoginCredentialCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]).textField.text;
    
    NetworkManager *manager = [NetworkManager new];
    [manager signupWithUsername:username password:password name:name completionHandler:^(int code, NSError *registerError) {
        if(code == 200){
            [manager loginWithUsername:username password:password completionHandler:^(int loginCode, NSError *loginError) {
                if(loginCode == 200){
                    // this is used to track metrics
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:username forKey:@"username"];
                    [defaults synchronize];
                    
                    // TODO if successfully logged in after a newly registered user, show onboarding flow
                    [manager getLatestDataWithCompletionHandler:^(int dataCode, NSError *dataError, NSArray *data) {
                        if(dataCode == 200){
                            StatusTableViewController *status = [[StatusTableViewController alloc] initWithProfileData:data];
                            [self.navigationController pushViewController:status animated:YES];
                        } else if(dataError){
                            NSLog(@"Error getting latest data for newly registered user, with Error:\n%@", dataError);
                        }
                     }];
                } else if(loginError){
                    // TODO if login error?
                    NSLog(@"Error logging in with newly registered user, with Error:\n%@", loginError);
                }
            }];
        } else if(registerError){
            // TODO if signup error?
            NSLog(@"Error registering new user, with Error:\n%@", registerError);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginCredentialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SignupCell"];
    if(cell == nil){
        cell = [[LoginCredentialCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SignupCell"];
    }
    switch (indexPath.row) {
        case 0:
            [cell.label setText:@"Name"];
            [cell.textField setPlaceholder:@"ex. John Appleseed"];
            break;
        case 1:
            [cell.label setText:@"Username"];
            [cell.textField setPlaceholder:@"ex. jappleseed"];
            break;
        case 2:
            [cell.label setText:@"Password"];
            [cell.textField setPlaceholder:@"ex. mypassword"];
            break;
    }
    return cell;
}

@end
