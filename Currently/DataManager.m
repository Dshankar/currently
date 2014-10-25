//
//  DataManager.m
//  Currently
//
//  Created by Darshan Shankar on 10/23/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "NetworkManager.h"
#import "LoginController.h"

@implementation DataManager

- (id) initWithControllers:(NSArray *)viewControllers{

    self = [super init];
    if(self){
        self.tabBarController = [viewControllers objectAtIndex:0];
        self.status = [viewControllers objectAtIndex:1];
        self.pendingInvites = [viewControllers objectAtIndex:2];
        self.notifications = [viewControllers objectAtIndex:3];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    return self;
}

- (void) applicationActive:(id)sender {
    NSLog(@"application active, updating data");
    [self updateData];
}

- (void) updateData {
    NSLog(@"DataManger is updating dataa");
    NetworkManager *manager = [NetworkManager getInstance];
    
    [manager getLatestDataWithCompletionHandler:^(int code, NSError *error, NSDictionary *data) {
        if(error == nil){
            self.status.profileData = [data objectForKey:@"friends"];
            self.status.myData = [data objectForKey:@"me"];
            [self.status dataSourceHasUpdated];
            
            int pendingRequests = [[[data objectForKey:@"me"] objectForKey:@"requests"] count];
            if(pendingRequests > 0){
                [[self.tabBarController.toolbarItems objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%i", pendingRequests]];
            } else {
                [[self.tabBarController.toolbarItems objectAtIndex:1] setBadgeValue:nil];
            }
            self.pendingInvites.requests = [[data objectForKey:@"me"] objectForKey:@"requests"];
            [self.pendingInvites dataSourceHasUpdated];
        } else if(code == 401 || error.code == -1012){
            NSLog(@"Status getLatestData error 401/-1012");
            [manager refreshTokensWithCompletionHandler:^(int refreshCode, NSError *refreshError) {
                if(refreshCode == 200){
                    [self updateData];
                } else if(refreshCode == 403 || refreshError){
                    LoginController *login = [[LoginController alloc] initWithNibName:nil bundle:nil];
                    login.delegate = self;
                    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:login];
                    [self.tabBarController presentViewController:loginNav animated:YES completion:nil];
                }
            }];
        }
    }];
}

- (void) successfulAuthentication {
    [self updateData];
}

@end
