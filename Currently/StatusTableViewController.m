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
#import "UpdateTableViewController.h"
#include <math.h>

@interface StatusTableViewController ()
{
    NSIndexPath *indexPathOfSelectedRow;
}
@end

@implementation StatusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Currently"];
    
    UIBarButtonItem *update = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStylePlain target:self action:@selector(updateStatus:)];
    [self.navigationItem setRightBarButtonItem:update];
    self.navigationItem.hidesBackButton = YES;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"UserCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
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

- (void)updateData {
    NSLog(@"updating data");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [NSString stringWithFormat:@"Bearer %@", [defaults objectForKey:@"accesstoken"]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://currently-data.herokuapp.com/data"]];
    [request setHTTPMethod:@"GET"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    self.updateDataConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.updateDataConnection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection == self.updateDataConnection){
        if([((NSHTTPURLResponse *)response) statusCode] == 401) {
            // access token has expired, refresh with refresh token
            [self refreshTokens];
        }
    } else if(connection == self.refreshTokenConnection){
        
    }
}

- (void)refreshTokens{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@"refresh_token" forKey:@"grant_type"];
    [data setObject:@"currentlyiOSV1" forKey:@"client_id"];
    [data setObject:@"abc123456" forKey:@"client_secret"];
    [data setObject:[defaults objectForKey:@"refreshtoken"] forKey:@"refresh_token"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://currently-data.herokuapp.com/oauth/token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    self.refreshTokenConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.refreshTokenConnection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection == self.updateDataConnection){
        self.profileData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [self.tableView reloadData];
    } else if(connection == self.refreshTokenConnection){
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@", dict);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[dict objectForKey:@"access_token"] forKey:@"accesstoken"];
        [defaults setObject:[dict objectForKey:@"refresh_token"] forKey:@"refreshtoken"];
        [defaults synchronize];
        
        [self updateData];
    }
}

- (void)registerEngagement:(NSString *)userAction {
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
}

- (void)updateStatus:(id)sender {
    UpdateTableViewController *updateController = [[UpdateTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    updateController.delegate = self;
    UINavigationController *updateNav = [[UINavigationController alloc] initWithRootViewController:updateController];
    [self.navigationController presentViewController:updateNav animated:YES completion:nil];
}

- (void)statusHasUpdated
{
    [self updateData];
    [self registerEngagement:@"updated_status"];
}

- (void)applicationActive:(id)sender {
    [self updateData];
    [self registerEngagement:@"opened_app"];
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
            NSLog(@"It has been %f seconds. display: %@", seconds, myTime);
    
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
