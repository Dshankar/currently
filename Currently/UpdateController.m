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
#import "CommonStatusTableViewController.h"

@interface UpdateController ()
{
    UIButton *locationButton;
    UIButton *locationCancelButton;
    CGRect locationButtonRect;
    UIImageView *locationImageView;
    UILabel *locationLabel;
    NSString *locationLabelPlaceholder;
    UIButton *activityButton;
    UIButton *activityCancelButton;
    CGRect activityButtonRect;
    UIImageView *activityImageView;
    UILabel *activityLabel;
    NSString *activityLabelPlaceholder;
}
@end

@implementation UpdateController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    locationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    locationButtonRect = CGRectMake(0, 140, self.view.bounds.size.width, 44);
    locationButton.frame = locationButtonRect;
    locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 44, 44)];
    [locationImageView setImage:[UIImage imageNamed:@"location"]];
    [locationButton addSubview:locationImageView];
    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, self.view.bounds.size.width - 100, 44)];
    locationLabelPlaceholder = @"Add a location";
    [locationLabel setText:locationLabelPlaceholder];
    [locationLabel setTextColor:[UIColor grayColor]];
    [locationLabel setFont:[UIFont fontWithName:@"Gotham-Book" size:16.0]];
    [locationButton addSubview:locationLabel];
    [locationButton addTarget:self action:@selector(changeLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationButton];
    
    UIImageView *cancel1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [cancel1 setImage:[UIImage imageNamed:@"cancel"]];
    locationCancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [locationCancelButton addTarget:self action:@selector(clearLocationSelection:) forControlEvents:UIControlEventTouchUpInside];
    locationCancelButton.frame = CGRectMake(self.view.bounds.size.width - 60, locationButton.frame.origin.y, 60, 44);
    [locationCancelButton addSubview:cancel1];

    activityButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    activityButtonRect = CGRectMake(0, 190, self.view.bounds.size.width, 44);
    activityButton.frame = activityButtonRect;
    activityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 44, 44)];
    [activityImageView setImage:[UIImage imageNamed:@"activity"]];
    [activityButton addSubview:activityImageView];
    activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, self.view.bounds.size.width - 100, 44)];
    activityLabelPlaceholder = @"Add an activity";
    [activityLabel setText:activityLabelPlaceholder];
    [activityLabel setTextColor:[UIColor grayColor]];
    [activityLabel setFont:[UIFont fontWithName:@"Gotham-Book" size:16.0]];
    [activityButton addSubview:activityLabel];
    [activityButton addTarget:self action:@selector(changeActivity:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:activityButton];
    
    UIImageView *cancel2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [cancel2 setImage:[UIImage imageNamed:@"cancel"]];
    activityCancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [activityCancelButton addTarget:self action:@selector(clearActivitySelection:) forControlEvents:UIControlEventTouchUpInside];
    activityCancelButton.frame = CGRectMake(self.view.bounds.size.width - 60, activityButton.frame.origin.y, 60, 44);
    [activityCancelButton addSubview:cancel2];
    
    
//    UIButton *textButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    textButton.frame = CGRectMake(20, 240, 44, 44);
    UIImageView *textImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 240, 44, 44)];
    [textImageView setImage:[UIImage imageNamed:@"text"]];
    [self.view addSubview:textImageView];
    
    self.note = [[UITextField alloc] initWithFrame:CGRectMake(80, 240, 220, 44)];
    self.note.placeholder = @"What's up?";
    [self.note setFont:[UIFont fontWithName:@"Gotham-Book" size:16.0]];
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
}

- (void)viewWillAppear:(BOOL)animated{
    [self.note becomeFirstResponder];
}

- (void)dismissView:(id)sender {
    [self.note resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeActivity:(id)sender {
    NSArray *data = @[@"Walking", @"Sleeping", @"Eating", @"Working", @"Playing", @"Running", @"Working out"];
    CommonStatusTableViewController *activity = [[CommonStatusTableViewController alloc] initType:CommonStatusTypeActivity WithData:data];
    activity.delegate = self;
    UINavigationController *activityNav = [[UINavigationController alloc] initWithRootViewController:activity];
    [self.navigationController presentViewController:activityNav animated:YES completion:nil];
    NSLog(@"changeActivity");
}

- (void)changeLocation:(id)sender {
    NSArray *data = @[@"Home", @"Work", @"Gym", @"Cafe", @"Bar", @"Office", @"Starbucks"];
    CommonStatusTableViewController *location = [[CommonStatusTableViewController alloc] initType:CommonStatusTypeLocation WithData:data];
    location.delegate = self;
    UINavigationController *locationNav = [[UINavigationController alloc] initWithRootViewController:location];
    [self.navigationController presentViewController:locationNav animated:YES completion:nil];
    NSLog(@"changeLocation");
}

- (void)didSelectCommonStatus:(NSString *)status withType:(CommonStatusType)type {
    if (type == CommonStatusTypeLocation) {
        [locationLabel setText:status];
        [locationLabel setTextColor:[UIColor blackColor]];
        [locationImageView setImage:[UIImage imageNamed:@"location-active"]];
        [locationButton setFrame:CGRectMake(locationButton.frame.origin.x, locationButton.frame.origin.y, self.view.bounds.size.width - 60, locationButton.frame.size.height)];
        [self.view addSubview:locationCancelButton];
    } else if (type == CommonStatusTypeActivity ) {
        [activityLabel setText:status];
        [activityLabel setTextColor:[UIColor blackColor]];
        [activityImageView setImage:[UIImage imageNamed:@"activity-active"]];
        [activityButton setFrame:CGRectMake(activityButton.frame.origin.x, activityButton.frame.origin.y, self.view.bounds.size.width - 60, activityButton.frame.size.height)];
        [self.view addSubview:activityCancelButton];
    }
}

- (void)clearActivitySelection:(id)sender {
    [activityCancelButton removeFromSuperview];
    [activityLabel setText:activityLabelPlaceholder];
    [activityLabel setTextColor:[UIColor grayColor]];
    [activityImageView setImage:[UIImage imageNamed:@"activity"]];
    [activityButton setFrame:activityButtonRect];
}

- (void)clearLocationSelection:(id)sender {
    [locationCancelButton removeFromSuperview];
    [locationLabel setText:locationLabelPlaceholder];
    [locationLabel setTextColor:[UIColor grayColor]];
    [locationImageView setImage:[UIImage imageNamed:@"location"]];
    [locationButton setFrame:locationButtonRect];
}

- (void)updateStatus:(id)sender {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    if(self.note.text.length > 0) {
        [data setObject:self.note.text forKey:@"note"];
    }
    if(![activityLabel.text isEqualToString:activityLabelPlaceholder]) {
        [data setObject:activityLabel.text forKey:@"activity"];
    }
    if(![locationLabel.text isEqualToString:locationLabelPlaceholder]) {
        [data setObject:locationLabel.text forKey:@"location"];
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
