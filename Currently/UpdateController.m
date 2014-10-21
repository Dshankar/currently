//
//  UpdateController.m
//  Currently
//
//  Created by Darshan Shankar on 10/19/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "UpdateController.h"
#import "NetworkManager.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "LoginController.h"

@interface UpdateController ()

@end

@implementation UpdateController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width, 40)];
    [timeLabel setText:@"Today, 9:41 AM"];
    [timeLabel setFont:[UIFont fontWithName:@"Gotham-Book" size:16.0]];
    [timeLabel setTextColor:[UIColor grayColor]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:timeLabel];

    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    locationButton.frame = CGRectMake(20, 140, 44, 44);
    UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [locationImageView setImage:[UIImage imageNamed:@"location"]];
    [locationButton addSubview:locationImageView];
    [locationButton addTarget:self action:@selector(changeLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 140, 220, 44)];
    [locationLabel setText:@"Add a location"];
    [locationLabel setFont:[UIFont fontWithName:@"Gotham-Book" size:16.0]];
    [locationLabel setTextColor:[UIColor grayColor]];
    [self.view addSubview:locationLabel];

    UIButton *activityButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    activityButton.frame = CGRectMake(20, 190, 44, 44);
    UIImageView *activityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [activityImageView setImage:[UIImage imageNamed:@"activity-active"]];
    [activityButton addSubview:activityImageView];
    [activityButton addTarget:self action:@selector(changeLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 190, 220, 44)];
    [activityLabel setText:@"Sleeping"];
    [activityLabel setFont:[UIFont fontWithName:@"Gotham-Book" size:16.0]];
    [activityLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:activityLabel];
    
    UIButton *textButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    textButton.frame = CGRectMake(20, 240, 44, 44);
    UIImageView *textImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [textImageView setImage:[UIImage imageNamed:@"text"]];
    [textButton addSubview:textImageView];
    [textButton addTarget:self action:@selector(changeLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    self.note = [[UITextField alloc] initWithFrame:CGRectMake(80, 240, 220, 44)];
    self.note.placeholder = @"What's up?";
    [self.note setFont:[UIFont fontWithName:@"Gotham-Book" size:16.0]];
    
    [self.view addSubview:locationButton];
    [self.view addSubview:activityButton];
    [self.view addSubview:textButton];
    [self.view addSubview:self.note];
    
    [self setTitle:@"Update Status"];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView:)];
    [self.navigationItem setLeftBarButtonItem:cancel];
    
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(updateStatus:)];
    [self.navigationItem setRightBarButtonItem:submit];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
#ifndef DEBUG
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Update Status Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
#endif
    [self.note becomeFirstResponder];
}

- (void)dismissView:(id)sender {
    [self.note resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateStatus:(id)sender {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    NSString *note = self.note.text;
    NSString *activity = self.activity;
    NSString *location = self.location;
    if(note.length > 0) {
        [data setObject:note forKey:@"note"];
    }
    if(activity.length > 0) {
        [data setObject:activity forKey:@"activity"];
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

@end
