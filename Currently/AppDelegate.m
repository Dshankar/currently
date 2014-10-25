//
//  AppDelegate.m
//  Currently
//
//  Created by Darshan Shankar on 9/28/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "AppDelegate.h"
#import "SplashViewController.h"
#import "NetworkManager.h"
#import "GAI.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
//     clears NSUserDefaults for testing purposes
//            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    SplashViewController *splash = [[SplashViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = splash;
    [self.window makeKeyAndVisible];
    
#ifndef DEBUG
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-55270322-1"];
#endif
    
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
    }
}

- (void) updateServerWithNotificationsDeviceToken:(NSString *)token {
    NetworkManager *manager = [NetworkManager new];
    [manager updateAPNDeviceToken:token completionHandler:^(int code, NSError *error) {
        if(code == 401 || error.code == -1012){
            NSLog(@"updateAPNDeviceToken error 401/-1012");
            [manager refreshTokensWithCompletionHandler:^(int refreshCode, NSError *refreshError) {
                if(refreshCode == 200){
                    [self updateServerWithNotificationsDeviceToken:token];
                } // else, if we can't refresh tokens, do nothing. deal with this next time user logs in.
            }];
        } else if (code == 200){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:token forKey:@"apnDeviceToken"];
        }
    }];
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
