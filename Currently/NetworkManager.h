//
//  NetworkManager.h
//  Currently
//
//  Created by Darshan Shankar on 10/13/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InvitesTableViewController.h"

@interface NetworkManager : NSObject

- (void) getLatestDataWithCompletionHandler: (void (^)(int code, NSError* error, NSDictionary *data)) handler;
- (void) refreshTokensWithCompletionHandler: (void (^)(int code, NSError* error)) handler;
- (void) updateStatus:(NSDictionary *)data completionHandler: (void (^)(int code, NSError* error)) handler;
- (void) sendFriendRequest:(NSString *)username completionHandler: (void (^)(int code, NSError *error)) handler;
- (void) sendAction:(FriendRequestActionType)action forFriendRequestFrom:(NSString *)username completionHandler: (void (^)(int code, NSError*error)) handler;
- (void) loginWithUsername:(NSString *)username password:(NSString *)password completionHandler: (void (^)(int code, NSError* error)) handler;
- (void) signupWithUsername:(NSString *)username password:(NSString *)password name:(NSString *)name completionHandler:(void (^)(int code, NSError *error))handler;
- (void) updateAPNDeviceToken:(NSString *)token completionHandler: (void (^)(int code, NSError* error)) handler;

+ (NetworkManager *)getInstance;

@property (nonatomic, retain) NSOperationQueue *opqueue;

@end
