//
//  UserCell.h
//  Currently
//
//  Created by Darshan Shankar on 9/28/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell

@property (nonatomic, retain) UIImageView *profile;
@property (nonatomic, retain) UILabel *status;
@property (nonatomic, retain) UILabel *time;
@property (nonatomic, retain) NSString *imessage;
@property (nonatomic, retain) NSString *sms;
@property (nonatomic, retain) NSString *facebook;
@property (nonatomic, retain) NSString *whatsapp;

@end
