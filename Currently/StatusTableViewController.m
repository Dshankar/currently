//
//  StatusTableViewController.m
//  Currently
//
//  Created by Darshan Shankar on 9/28/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "StatusTableViewController.h"
#import "UserCell.h"

@interface StatusTableViewController ()

@end

@implementation StatusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"UserCell"];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCell"];
        [cell.status setText:@"Hi"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

@end
