//
//  NotificationsController.m
//  Currently
//
//  Created by Darshan Shankar on 10/19/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "NotificationsController.h"

@interface NotificationsController ()

@end

@implementation NotificationsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *comingSoon = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 100)];
    [comingSoon setText:@"Coming Soon"];
    [comingSoon setFont:[UIFont fontWithName:@"Gotham-Book" size:20.0]];
    [self.view addSubview:comingSoon];
}

@end
