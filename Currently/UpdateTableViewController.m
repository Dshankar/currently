//
//  UpdateTableViewController.m
//  Currently
//
//  Created by Darshan Shankar on 9/30/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "UpdateTableViewController.h"
#import "UpdateStatusCell.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "NetworkManager.h"
#import "LoginController.h"

@interface UpdateTableViewController ()
@end

@implementation UpdateTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Update Status"];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView:)];
    [self.navigationItem setLeftBarButtonItem:cancel];
    
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(updateStatus:)];
    [self.navigationItem setRightBarButtonItem:submit];
    
    [self.tableView registerClass:[UpdateStatusCell class] forCellReuseIdentifier:@"UpdateStatusCell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    #ifndef DEBUG
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Update Status Screen"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    #endif
    
    UpdateStatusCell *cell = (UpdateStatusCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.textField becomeFirstResponder];
}

- (void)dismissView:(id)sender {
    UpdateStatusCell *verbCell = (UpdateStatusCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UpdateStatusCell *nounCell = (UpdateStatusCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UpdateStatusCell *locationCell = (UpdateStatusCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [verbCell.textField resignFirstResponder];
    [nounCell.textField resignFirstResponder];
    [locationCell.textField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateStatus:(id)sender {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    UpdateStatusCell *verbCell = (UpdateStatusCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UpdateStatusCell *nounCell = (UpdateStatusCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UpdateStatusCell *locationCell = (UpdateStatusCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    NSString *verb = verbCell.textField.text;
    NSString *noun = nounCell.textField.text;
    NSString *location = locationCell.textField.text;
    if(verb.length > 0) {
        [data setObject:verb forKey:@"verb"];
    }
    if(noun.length > 0) {
        [data setObject:noun forKey:@"noun"];
    }
    if(location.length > 0) {
        [data setObject:location forKey:@"location"];
    }
    [self publishUpdatedStatus:data];
}

- (void) publishUpdatedStatus:(NSDictionary *)data{
    //    NetworkManager *manager = [NetworkManager new];
    NetworkManager *manager = [NetworkManager getInstance];

    [manager updateStatus:data completionHandler:^(int code, NSError *error) {
        if(code == 200 || error == nil){
            [self.delegate statusHasUpdated];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else if(code == 401 || error.code == -1012){
            NSLog(@"Update updateStatus error 401/-1012");
            [manager refreshTokensWithCompletionHandler:^(int refreshCode, NSError *refreshError) {
                if(refreshCode == 200){
                    [self publishUpdatedStatus:data];
                } else if(refreshCode == 403 || refreshError){
                    LoginController *login = [[LoginController alloc] initWithNibName:nil bundle:nil];
                    login.shouldDismissOnSuccess = YES;
                    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:login];
                    [self presentViewController:loginNav animated:YES completion:nil];
                }
            }];
        }
    }];
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
    UpdateStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpdateStatusCell" forIndexPath:indexPath];
    if(cell == nil){
        cell = [[UpdateStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UpdateStatusCell"];
    }
    switch (indexPath.row) {
        case 0:
            [cell.label setText:@"Verb"];
            [cell.textField setPlaceholder:@"ex. eating, sleeping"];
            break;
        case 1:
            [cell.label setText:@"Noun"];
            [cell.textField setPlaceholder:@"ex. a burger, a book"];
            break;
        case 2:
            [cell.label setText:@"Location"];
            [cell.textField setPlaceholder:@"ex. Home, Work"];
            break;
    }
    return cell;
}

@end
