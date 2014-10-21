//
//  AddFriendController.m
//  Currently
//
//  Created by Darshan Shankar on 10/19/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "AddFriendController.h"
#import "LoginCredentialCell.h"

@interface AddFriendController ()

@end

@implementation AddFriendController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[LoginCredentialCell class] forCellReuseIdentifier:@"AddFriendCell"];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Friend" style:UIBarButtonItemStyleDone target:self action:@selector(addFriend:)];
    [self.navigationItem setRightBarButtonItem:addButton];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(dismissView:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}

- (void)viewDidAppear:(BOOL)animated {
    LoginCredentialCell *cell = (LoginCredentialCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissView:(id)sender {
    LoginCredentialCell *cell = (LoginCredentialCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.textField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addFriend:(id)sender {
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Add a friend by entering their username";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginCredentialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFriendCell"];
    if(cell == nil){
        cell = [[LoginCredentialCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddFriendCell"];
    }
    cell.label.text = @"Username";
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
