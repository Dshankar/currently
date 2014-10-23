//
//  CommonStatusTableViewController.h
//  Currently
//
//  Created by Darshan Shankar on 10/21/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CommonStatusTypeActivity,
    CommonStatusTypeLocation
} CommonStatusType;

@protocol CommonStatusProtocol <NSObject>

- (void)didSelectCommonStatus:(NSString *)status withType:(CommonStatusType)type;

@end

@interface CommonStatusTableViewController : UITableViewController

- (id)initType:(CommonStatusType)type WithData:(NSArray *)newData;
@property (nonatomic) id <CommonStatusProtocol>delegate;

@end
