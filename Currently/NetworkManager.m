//
//  NetworkManager.m
//  Currently
//
//  Created by Darshan Shankar on 10/13/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

- (void)refreshTokensWithCompletionHandler: (void (^)(int, NSError*)) handler{
    NSLog(@"NMRefreshTokens");
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
    
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        int code = ((NSHTTPURLResponse *)response).statusCode;
        if(error){
            handler(code, error);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[dict objectForKey:@"access_token"] forKey:@"accesstoken"];
            [defaults setObject:[dict objectForKey:@"refresh_token"] forKey:@"refreshtoken"];
            [defaults synchronize];
            handler(code, nil);
        }
    }];
}

- (void) getLatestDataWithCompletionHandler: (void (^)(int code, NSError* error, NSArray* data)) handler{
    NSLog(@"NMGetLatestData");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [NSString stringWithFormat:@"Bearer %@", [defaults objectForKey:@"accesstoken"]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://currently-data.herokuapp.com/data"]];
    [request setHTTPMethod:@"GET"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        int code = ((NSHTTPURLResponse *)response).statusCode;
        if(error){
            handler(code, error, nil);
        } else {
            NSArray *serializedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            handler(code, nil, serializedData);
        }
    }];
}

- (void)updateStatus:(NSDictionary *)data completionHandler: (void (^)(int, NSError*)) handler{
    NSLog(@"NMUpdateStatus");
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [NSString stringWithFormat:@"Bearer %@", [defaults objectForKey:@"accesstoken"]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://currently-data.herokuapp.com/update"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        int code = ((NSHTTPURLResponse *)response).statusCode;
        if(error){
            handler(code, error);
        } else {
            handler(code, nil);
        }
    }];
}

- (void) loginWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(int, NSError *))handler{
    NSLog(@"NMLogin");
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@"password" forKey:@"grant_type"];
    [data setObject:@"currentlyiOSV1" forKey:@"client_id"];
    [data setObject:@"abc123456" forKey:@"client_secret"];
    [data setObject:username forKey:@"username"];
    [data setObject:password forKey:@"password"];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://currently-data.herokuapp.com/oauth/token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];

    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *responseError) {
        int code = ((NSHTTPURLResponse *)response).statusCode;
        if(responseError){
            handler(code, responseError);
        } else if (code == 200){
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[dict objectForKey:@"access_token"] forKey:@"accesstoken"];
            [defaults setObject:[dict objectForKey:@"refresh_token"] forKey:@"refreshtoken"];
            [defaults synchronize];
            
            handler(code, nil);
        }
    }];
}

- (void) signupWithUsername:(NSString *)username password:(NSString *)password name:(NSString *)name completionHandler:(void (^)(int code, NSError *error))handler{
    NSLog(@"NMSignup");
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@"password" forKey:@"grant_type"];
    [data setObject:@"currentlyiOSV1" forKey:@"client_id"];
    [data setObject:@"abc123456" forKey:@"client_secret"];
    [data setObject:username forKey:@"username"];
    [data setObject:password forKey:@"password"];
    [data setObject:name forKey:@"name"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://currently-data.herokuapp.com/register"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *responseError) {
        int code = ((NSHTTPURLResponse *)response).statusCode;
        if(responseError){
            handler(code, responseError);
        } else if (code == 200){
            handler(code, nil);
        }
    }];
}

- (void) updateAPNDeviceToken:(NSString *)token completionHandler: (void (^)(int code, NSError* error)) handler{
    NSLog(@"NMUpdateAPNDeviceToken");
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
    
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        int code = ((NSHTTPURLResponse *)response).statusCode;
        if(error){
            handler(code, error);
        } else {
            handler(code, nil);
        }
    }];
}

@end
