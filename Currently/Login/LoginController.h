//
//  LoginController.h
//  Currently
//
//  Created by Darshan Shankar on 10/10/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashViewController.h"

@interface LoginController : UITableViewController

@property (nonatomic) id<AuthenticationCompletionProtocol> delegate;

@end
