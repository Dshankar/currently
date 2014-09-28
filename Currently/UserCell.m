//
//  UserCell.m
//  Currently
//
//  Created by Darshan Shankar on 9/28/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.profile = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [self.profile setImage:[UIImage imageNamed:@"profile@2x.jpg"]];
        [self addSubview:self.profile];
        
        self.status = [[UILabel alloc] initWithFrame:CGRectMake(140, 0, 100, 100)];
        [self.status setText:@"Darshan is working."];
        [self.status setFont:[UIFont fontWithName:@"Gotham-Medium" size:20.0f]];
        [self addSubview:self.status];
    }
    return self;
}

@end
