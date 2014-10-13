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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (void)login:(id)sender {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    LoginCredentialCell *username = (LoginCredentialCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    LoginCredentialCell *password = (LoginCredentialCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    [data setObject:@"password" forKey:@"grant_type"];
    [data setObject:@"currentlyiOSV1" forKey:@"client_id"];
    [data setObject:@"abc123456" forKey:@"client_secret"];
    [data setObject:username.textField.text forKey:@"username"];
    [data setObject:password.textField.text forKey:@"password"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username.textField.text forKey:@"username"];
    [defaults synchronize];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://currently-data.herokuapp.com/oauth/token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response %@", response);
    if([(NSHTTPURLResponse *)response statusCode] == 200){
        // ???
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[dict objectForKey:@"access_token"] forKey:@"accesstoken"];
    [defaults setObject:[dict objectForKey:@"refresh_token"] forKey:@"refreshtoken"];
    [defaults synchronize];
    
    StatusTableViewController *status = [[StatusTableViewController alloc] initWithNibName:nil bundle:nil];
    [status applicationActive:nil];
    [self.navigationController pushViewController:status animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginCredentialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoginCredentialCell"];
    if(cell == nil){
        cell = [[LoginCredentialCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoginCredentialCell"];
    }
    switch (indexPath.row) {
        case 0:
            [cell.label setText:@"Username"];
            [cell.textField setPlaceholder:@"ex. Mom"];
//            [cell.textField setText:@"Darshan"];
            break;
        case 1:
            [cell.label setText:@"Password"];
            [cell.textField setPlaceholder:@"ex. password"];
//            [cell.textField setText:@"simplepassword"];
            break;
    }
    return cell;
}

@end
