//
//  SplashViewController.m
//  Currently
//
//  Created by Darshan Shankar on 10/13/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "SplashViewController.h"
#import "LoginController.h"
#import "SignupController.h"
#import "StatusTableViewController.h"
#import "NetworkManager.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Welcome"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NetworkManager *network = [NetworkManager new];

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
    UIButton *login = [UIButton buttonWithType:UIButtonTypeCustom];
    [login setFrame:CGRectMake(0, 300, 320, 80)];
    [login setBackgroundColor:[UIColor greenColor]];
    [login setTitle:@"Log in" forState:UIControlStateNormal];
    [login addTarget:self action:@selector(showLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:login];
    
    UIButton *signup = [UIButton buttonWithType:UIButtonTypeCustom];
    [signup setFrame:CGRectMake(0, 400, 320, 80)];
    [signup setBackgroundColor:[UIColor blueColor]];
    [signup setTitle:@"Sign up" forState:UIControlStateNormal];
    [signup addTarget:self action:@selector(showSignup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signup];
}

- (void)showLogin:(id)sender {
    LoginController *login = [[LoginController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:login animated:YES];
}

- (void)showSignup:(id)sender {
    SignupController *signup = [[SignupController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:signup animated:YES];
}

@end
