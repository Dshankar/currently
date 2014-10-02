//
//  SelectUserController.m
//  Currently
//
//  Created by Darshan Shankar on 10/1/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "SelectUserController.h"
#import "StatusTableViewController.h"

@interface SelectUserController ()

@end

@implementation SelectUserController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Who are you?"];
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectUserCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectUserCell"];
    }
    if (indexPath.row == 0) {
        [cell.textLabel setText:@"Darshan"];
    } else {
        [cell.textLabel setText:@"Mom"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (indexPath.row == 0) {
        [defaults setObject:@"Darshan" forKey:@"UDID"];
        [defaults synchronize];
    } else {
        [defaults setObject:@"Mom" forKey:@"UDID"];
        [defaults synchronize];
    }
    StatusTableViewController *status = [[StatusTableViewController alloc] initWithNibName:nil bundle:nil];
    [status applicationActive:nil];
    [self.navigationController pushViewController:status animated:YES];
}

@end
