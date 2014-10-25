//
//  SplashViewController.h
//  Currently
//
//  Created by Darshan Shankar on 10/13/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AuthenticationCompletionProtocol <NSObject>

@required -(void)successfulAuthentication;

@end

@interface SplashViewController : UIViewController <AuthenticationCompletionProtocol>

@end
