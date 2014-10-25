//
//  FriendRequestsTableViewCell.m
//  Currently
//
//  Created by Darshan Shankar on 10/24/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "FriendRequestsTableViewCell.h"

@implementation FriendRequestsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 320 - 88 - 70, 20)];
        [self.name setFont:[UIFont fontWithName:@"Gotham-Medium" size:15.0]];
        [self.name setTextColor:[UIColor blackColor]];
        [self addSubview:self.name];
        
        self.username = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, 320 - 88 - 70, 20)];
        [self.username setFont:[UIFont fontWithName:@"Gotham-Book" size:14.0]];
        [self.username setTextColor:[UIColor grayColor]];
        [self addSubview:self.username];
        
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [self addSubview:self.image];
        
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.confirmButton setFrame:CGRectMake(320 - 88, 9, 44, 44)];
        [self.confirmButton setImage:[UIImage imageNamed:@"confirm"] forState:UIControlStateNormal];
        [self addSubview:self.confirmButton];
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelButton setFrame:CGRectMake(320 - 44, 9, 44, 44)];
        [self.cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [self addSubview:self.cancelButton];
    }
    return self;
}

@end
