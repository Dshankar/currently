//
//  NetworkManager.h
//  Currently
//
//  Created by Darshan Shankar on 10/13/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <Foundation/Foundation.h>

//@protocol NetworkManagerProtocol <NSObject>
//@required
//- (void)showLoginView;
//- (void)downloadedLatestProfileData:(NSArray *)data;
//@end

@interface NetworkManager : NSObject

- (void) getLatestDataWithCompletionHandler: (void (^)(int code, NSError* error, NSArray* data)) handler;
- (void) refreshTokensWithCompletionHandler: (void (^)(int code, NSError* error)) handler;
- (void) updateStatus:(NSDictionary *)data completionHandler: (void (^)(int code, NSError* error)) handler;
- (void) loginWithUsername:(NSString *)username password:(NSString *)password completionHandler: (void (^)(int code, NSError* error)) handler;
- (void) registerWithUsername:(NSString *)username password:(NSString *)password name:(NSString *)name completionHandler:(void (^)(int, NSError *))handler;
- (void) updateAPNDeviceToken:(NSString *)token completionHandler: (void (^)(int code, NSError* error)) handler;

@property (nonatomic, retain) NSURLConnection *updateDataConnection;
@property (nonatomic, retain) NSURLConnection *updateStatusConnection;
@property (nonatomic, retain) NSURLConnection *refreshTokenConnection;

//@property (nonatomic, retain) id <NetworkManagerProtocol> delegate;

@end
