//
//  SignupController.h
//  Currently
//
//  Created by Darshan Shankar on 10/13/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashViewController.h"

@interface SignupController : UITableViewController

@property (nonatomic) id<AuthenticationCompletionProtocol> delegate;

@end
