//
//  StatusTableViewController.m
//  Currently
//
//  Created by Darshan Shankar on 9/28/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "StatusTableViewController.h"
#import "UserCell.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
//#import "UpdateTableViewController.h"
#import "UpdateController.h"
#include <math.h>
#import "LoginController.h"
#import "NetworkManager.h"
#import "AddFriendController.h"

@interface StatusTableViewController ()
{
    NSIndexPath *indexPathOfSelectedRow;
}
@end

@implementation StatusTableViewController

- (id) initWithProfileData:(NSArray *)data{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self){
        self.profileData = data;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    UIImage *updateImage = [UIImage imageNamed:@"edit"];
    UIBarButtonItem *update = [[UIBarButtonItem alloc] initWithImage:updateImage style:UIBarButtonItemStyleDone target:self action:@selector(showUpdateStatus:)];
    [update setTintColor:[UIColor grayColor]];
    
    UIImage *addFriendImage = [UIImage imageNamed:@"addfriend"];
    UIBarButtonItem *addFriend = [[UIBarButtonItem alloc] initWithImage:addFriendImage style:UIBarButtonItemStyleDone target:self action:@selector(showAddFriend:)];
    [addFriend setTintColor:[UIColor grayColor]];
    
    [self.navigationItem setRightBarButtonItems:@[update]];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationItem setLeftBarButtonItem:addFriend];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"UserCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [self registerForNotifications];
}

- (void)registerForNotifications {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS 8+
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        // iOS 7
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
}


- (void)registerEngagement:(NSString *)userAction {
#ifndef DEBUG
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"username"];
    NSLog(@"register engagement: %@ for user %@", userAction, userName);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Statuses Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"engagement"
                                                          action:userAction
                                                           label:userName
                                                           value:nil] build]];
#endif
}

- (void)showAddFriend:(id)sender{
    AddFriendController *addFriendController = [[AddFriendController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *addFriendNav = [[UINavigationController alloc] initWithRootViewController:addFriendController];
    [self.navigationController presentViewController:addFriendNav animated:YES completion:nil];
}

- (void)showUpdateStatus:(id)sender {
//    UpdateTableViewController *updateController = [[UpdateTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UpdateController *updateController = [[UpdateController alloc] init];
    updateController.delegate = self;
    UINavigationController *updateNav = [[UINavigationController alloc] initWithRootViewController:updateController];
    [self.navigationController presentViewController:updateNav animated:YES completion:nil];
}

- (void)statusHasUpdated {
    [self updateData];
    [self registerEngagement:@"updated_status"];
}

- (void)applicationActive:(id)sender {
    [self updateData];
    [self registerEngagement:@"opened_app"];
}

- (void) updateData {
    NetworkManager *manager = [NetworkManager getInstance];
    
    [manager getLatestDataWithCompletionHandler:^(int code, NSError *error, NSArray *data) {
        if(error == nil){
            self.profileData = data;
            [self.tableView reloadData];
        } else if(code == 401 || error.code == -1012){
            NSLog(@"Status getLatestData error 401/-1012");
            [manager refreshTokensWithCompletionHandler:^(int refreshCode, NSError *refreshError) {
                if(refreshCode == 200){
                    [self updateData];
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
    return self.profileData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCell"];
    }
    
    NSString *profileURL = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"image"];
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:profileURL]];
    NSError *error;
    NSData *imageData = [NSURLConnection sendSynchronousRequest:imageRequest returningResponse:nil error:&error];
    if(error != nil){
        NSLog(@"image error: %@", error);
    } else {
        [cell.profile setImage:[UIImage imageWithData:imageData]];
    }
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    NSDictionary *mediumAttribute = @{NSFontAttributeName: [UIFont fontWithName:@"Gotham-Medium" size:16.0f]};
    NSDictionary *bookAttribute = @{NSFontAttributeName: [UIFont fontWithName:@"Gotham-Book" size:16.0f]};
    NSDictionary *timeAttribute = @{NSFontAttributeName: [UIFont fontWithName:@"Gotham-Book" size:13.0f], NSForegroundColorAttributeName: [UIColor grayColor]};
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5.0f];

    NSString *myName = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSAttributedString *name = [[NSAttributedString alloc] initWithString:myName attributes:mediumAttribute];
    [attrString appendAttributedString:name];
    NSAttributedString *is = [[NSAttributedString alloc] initWithString:@" is " attributes:bookAttribute];
    [attrString appendAttributedString:is];
 
    NSString *myVerb = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"verb"];
    if(myVerb.length > 0){
        NSAttributedString *verb = [[NSAttributedString alloc] initWithString:myVerb attributes:bookAttribute];
        [attrString appendAttributedString:verb];
    }
    NSString *myNoun = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"noun"];
    if(myNoun.length > 0){
        NSAttributedString *noun = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", myNoun] attributes:mediumAttribute];
        [attrString appendAttributedString:noun];
    }
    NSString *myLocation = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"location"];
    if(myLocation.length > 0){
        NSAttributedString *at = [[NSAttributedString alloc] initWithString:@" at " attributes:bookAttribute];
        [attrString appendAttributedString:at];

        NSAttributedString *location = [[NSAttributedString alloc] initWithString:myLocation attributes:mediumAttribute];
        [attrString appendAttributedString:location];
    }
    
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrString.string length])];
    [cell.status setAttributedText:attrString];
    
    cell.imessage = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"imessage"];
    cell.sms = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"sms"];
    cell.facebook = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"facebook"];
    cell.whatsapp = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"whatsapp"];
    
    NSString *serverUpdatedTime = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"time"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDate *sourceDate = [dateFormatter dateFromString:serverUpdatedTime];
    NSTimeInterval seconds = [sourceDate timeIntervalSinceNow] * -1;
    
    NSString *myTime;
    if(seconds > 86400.0){
        // more than 24 hours ago, display Day abbreviated
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit fromDate:sourceDate];
        NSInteger day = [components day];
        NSInteger month = [components month];
        myTime = [NSString stringWithFormat:@"%i/%i", month, day];
    } else if(seconds > 3600.0){
        // more than 60 minutes ago, display in HH'h'
        myTime = [NSString stringWithFormat:@"%ih", (int)floor(seconds/3600.0)];
    } else if(seconds > 60.0){
        // more than 1 minute ago, display in MM'm'
        myTime = [NSString stringWithFormat:@"%im", (int)floor(seconds/60.0)];
    } else {
        // less than 1 minute, display in SS'm'
        myTime = [NSString stringWithFormat:@"%is", (int)floor(seconds)];
    }
    
    NSAttributedString *time = [[NSAttributedString alloc] initWithString:myTime attributes:timeAttribute];
    [cell.time setAttributedText:time];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    indexPathOfSelectedRow = indexPath;
    UserCell *cell = (UserCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Send a Message" preferredStyle:UIAlertControllerStyleActionSheet];
    if(cell.imessage){
        UIAlertAction *imessage = [UIAlertAction actionWithTitle:@"iMessage" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", cell.imessage]]];
        }];
        [alertController addAction:imessage];
    }
    if(cell.sms){
        UIAlertAction *sms = [UIAlertAction actionWithTitle:@"SMS" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", cell.sms]]];
        }];
        [alertController addAction:sms];
    }
    if(cell.facebook){
        UIAlertAction *fb = [UIAlertAction actionWithTitle:@"Facebook Messenger" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb-messenger://"]]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb-messenger://user-thread/%@", cell.facebook]]];
            } else {
                UIAlertController *cannotOpen = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Please install the Facebook Messenger app first!" preferredStyle:UIAlertControllerStyleAlert];
                [cannotOpen addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:cannotOpen animated:YES completion:nil];
            }
        }];
        [alertController addAction:fb];
    }
    if(cell.whatsapp){
        UIAlertAction *whatsapp = [UIAlertAction actionWithTitle:@"Whatsapp" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", cell.whatsapp]]];
        }];
        [alertController addAction:whatsapp];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end