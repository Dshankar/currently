//
//  SplashViewController.m
//  Currently
//
//  Created by Darshan Shankar on 10/13/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "SplashViewController.h"
#import "LoginController.h"
#import "StatusTableViewController.h"
#import "NetworkManager.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NetworkManager *network = [NetworkManager new];
    // TODO better check than 'username' to determine whether user is logged in. check whether access token is valid instead?
    if ([defaults objectForKey:@"accesstoken"]) {
        [network getLatestDataWithCompletionHandler:^(int code, NSError *error, NSArray *data) {
            if(code == 200){
                NSLog(@"getLatestData OK 200");
                [self showStatusesWithData:data];
            } else if (code == 401){
                NSLog(@"getLatestData error 401");
                [network refreshTokensWithCompletionHandler:^(int refreshCode, NSError *refreshError) {
                    if (refreshCode == 200) {
                        [self showStatusesWithData:data];
                    } else {
                        [self displayLoginOrSignup];
                    }
                }];
            } else {
                NSLog(@"getLatestData error");
                // what about non-authentication errors? server down etc.
                [self displayLoginOrSignup];
            }
        }];
    } else {
        NSLog(@"No accesstoken stored");
        [self displayLoginOrSignup];
    }
}

- (void)showStatusesWithData:(NSArray *)data {
    StatusTableViewController *status = [[StatusTableViewController alloc] initWithProfileData:data];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:status];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void) displayLoginOrSignup {
    UIButton *login = [[UIButton alloc] initWithFrame:CGRectMake(0, 300, 320, 80)];
    [login setTitle:@"Log in" forState:UIControlStateNormal];
    [login addTarget:self action:@selector(showLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:login];
    
    UIButton *signup = [[UIButton alloc] initWithFrame:CGRectMake(0, 400, 320, 80)];
    [signup setTitle:@"Sign up" forState:UIControlStateNormal];
    [signup addTarget:self action:@selector(showLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signup];
}

- (void)showLogin:(id)sender {
    LoginController *login = [[LoginController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showSignup:(id)sender {
    
}

@end
