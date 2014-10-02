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
        self.profile = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [self addSubview:self.profile];
        
        self.status = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 190, 60)];
        [self.status setNumberOfLines:2];
        [self addSubview:self.status];
        
        self.time = [[UILabel alloc] initWithFrame:CGRectMake(250, 0, 60, 60)];
        [self.time setTextAlignment:NSTextAlignmentRight];
        [self addSubview:self.time];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
