//
//  AddFriendController.m
//  Currently
//
//  Created by Darshan Shankar on 10/19/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "AddFriendController.h"
#import "NetworkManager.h"
#import "LoginController.h"

@interface AddFriendController ()
{
    UITextField *textField;
}
@end

@implementation AddFriendController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Friend" style:UIBarButtonItemStyleDone target:self action:@selector(addFriend:)];
    [self.navigationItem setRightBarButtonItem:addButton];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(dismissView:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width-40, 70)];
    [textField setPlaceholder:@"Username"];
    [textField setFont:[UIFont fontWithName:@"Gotham-Book" size:16.0]];
    [self.view addSubview:textField];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissView:(id)sender {
    [textField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addFriend:(id)sender {
    [self sendFriendRequest:textField.text];
}

- (void)sendFriendRequest:(NSString *)username {
    NetworkManager *manager = [NetworkManager getInstance];
    [manager sendFriendRequest:username completionHandler:^(int code, NSError *error) {
        if(code == 400) {
//            NSLog(@"error sendFriendRequest HTTP %i with Error\n%@", code, error);
        } else if(code == 500) {
//            NSLog(@"error sendFriendRequest HTTP %i with Error\n%@", code, error);            
        } else if(code == 401 || error.code == -1012){
            NSLog(@"Update updateStatus error 401/-1012");
            [manager refreshTokensWithCompletionHandler:^(int refreshCode, NSError *refreshError) {
                if(refreshCode == 200){
                    [self sendFriendRequest:username];
                } else if(refreshCode == 403 || refreshError){
                    LoginController *login = [[LoginController alloc] initWithNibName:nil bundle:nil];
                    login.delegate = self;
                    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:login];
                    [self presentViewController:loginNav animated:YES completion:nil];
                }
            }];
        } else if(code == 200 || error == nil){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)successfulAuthentication {
    [self addFriend:nil];
}



@end
