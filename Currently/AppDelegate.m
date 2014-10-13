//
//  AppDelegate.m
//  Currently
//
//  Created by Darshan Shankar on 9/28/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginController.h"
#import "StatusTableViewController.h"
#import "GAI.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
//     clears NSUserDefaults for testing purposes
//            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    UINavigationController *nav;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // TODO better check than 'username' to determine whether user is logged in. check whether access token is valid instead?
    if ([defaults objectForKey:@"username"]) {
        StatusTableViewController *status = [[StatusTableViewController alloc] initWithNibName:nil bundle:nil];
        nav = [[UINavigationController alloc] initWithRootViewController:status];
    } else {
//        SelectUserController *selectUser = [[SelectUserController alloc] initWithNibName:nil bundle:nil];
        LoginController *selectUser = [[LoginController alloc] initWithNibName:nil bundle:nil];
        nav = [[UINavigationController alloc] initWithRootViewController:selectUser];
    }
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-55270322-1"];
    
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    NSLog(@"didRegisterUserNotificationSettings");
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
        NSLog(@"declineAction");
    } else if ([identifier isEqualToString:@"answerAction"]){
        NSLog(@"answerAction");
    }
}
#endif

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"error registering for token: %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"registered for notifications");
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *originalToken = [defaults objectForKey:@"apnDeviceToken"];
    if (!originalToken || ![originalToken isEqualToString:token]) {
        [self updateServerWithNotificationsDeviceToken:token];
        [defaults setObject:token forKey:@"apnDeviceToken"];
    }
}

- (void) updateServerWithNotificationsDeviceToken:(NSString *)token {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *accesstoken = [NSString stringWithFormat:@"Bearer %@", [defaults objectForKey:@"accesstoken"]];
    
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setObject:token forKey:@"apnDeviceToken"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://currently-data.herokuapp.com/devicetoken"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:accesstoken forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:jsonData];
    
    self.updateDeviceTokenConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.updateDeviceTokenConnection start];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection == self.updateDeviceTokenConnection){
        int code = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"Update Server APN Device Token Response %i", code);
        if(code == 401){
            [self refreshTokens];
        }
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

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data {
    if(connection == self.refreshTokenConnection){
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@", dict);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[dict objectForKey:@"access_token"] forKey:@"accesstoken"];
        [defaults setObject:[dict objectForKey:@"refresh_token"] forKey:@"refreshtoken"];
        [defaults synchronize];
        
        NSString *token = [defaults objectForKey:@"apnDeviceToken"];
        [self updateServerWithNotificationsDeviceToken:token];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
