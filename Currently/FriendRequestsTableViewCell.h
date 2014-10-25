//
//  FriendRequestsTableViewCell.h
//  Currently
//
//  Created by Darshan Shankar on 10/24/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendRequestsTableViewCell : UITableViewCell

@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UILabel *username;
@property (nonatomic, retain) UIImageView *image;
@property (nonatomic, retain) UIButton *confirmButton;
@property (nonatomic, retain) UIButton *cancelButton;

@end
