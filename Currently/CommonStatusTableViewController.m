//
//  CommonStatusTableViewController.m
//  Currently
//
//  Created by Darshan Shankar on 10/21/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "CommonStatusTableViewController.h"

@interface CommonStatusTableViewController ()
{
    NSArray *data;
    CommonStatusType statusType;
}
@end

@implementation CommonStatusTableViewController

- (id)initType:(CommonStatusType)type WithData:(NSArray *)newData {
    self = [super initWithStyle:UITableViewStylePlain];
    if(self){
        data = newData;
        statusType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(statusType == CommonStatusTypeActivity){
        [self setTitle:@"Select an Activity"];
    } else if(statusType == CommonStatusTypeLocation){
        [self setTitle:@"Select a Location"];
    }
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView:)];
    [self.navigationItem setLeftBarButtonItem:cancel];
    UIBarButtonItem *custom = [[UIBarButtonItem alloc] initWithTitle:@"Custom" style:UIBarButtonItemStylePlain target:self action:@selector(customStatusType:)];
    [self.navigationItem setRightBarButtonItem:custom];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CommonCell"];
}

- (void)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)customStatusType:(id)sender {
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonCell" forIndexPath:indexPath];
    [cell.textLabel setText:[data objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate didSelectCommonStatus:[data objectAtIndex:indexPath.row] withType:statusType];
    [self dismissView:nil];
}
@end
