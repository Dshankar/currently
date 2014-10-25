//
//  LoginController.m
//  Currently
//
//  Created by Darshan Shankar on 10/10/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "LoginController.h"
#import "LoginCredentialCell.h"
#import "StatusTableViewController.h"
#import "NetworkManager.h"

@interface LoginController ()

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Login"];
    [self.tableView registerClass:[LoginCredentialCell class] forCellReuseIdentifier:@"LoginCredentialCell"];
    
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(login:)];
    [self.navigationItem setRightBarButtonItem:submit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login:(id)sender {
    LoginCredentialCell *username = (LoginCredentialCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    LoginCredentialCell *password = (LoginCredentialCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    NetworkManager *manager = [NetworkManager getInstance];
    
    [manager loginWithUsername:username.textField.text password:password.textField.text completionHandler:^(int code, NSError *error) {
        if(error == nil){
            // this is used to track metrics. in future store this in Keychain securely?
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:username.textField.text forKey:@"username"];
            [defaults setObject:password.textField.text forKey:@"password"];
            [defaults synchronize];

            [self.delegate successfulAuthentication];
            [self dismissViewControllerAnimated:YES completion:nil];
        }  // TODO if login error?
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginCredentialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoginCredentialCell"];
    if(cell == nil){
        cell = [[LoginCredentialCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoginCredentialCell"];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (indexPath.row) {
        case 0:
            [cell.label setText:@"Username"];
            [cell.textField setPlaceholder:@"ex. Mom"];
            if([defaults objectForKey:@"username"]){
                [cell.textField setText:[defaults objectForKey:@"username"]];
            }
            break;
        case 1:
            [cell.label setText:@"Password"];
            [cell.textField setPlaceholder:@"ex. password"];
            if([defaults objectForKey:@"password"]){
                [cell.textField setText:[defaults objectForKey:@"password"]];
            }
            break;
    }
    return cell;
}

@end
