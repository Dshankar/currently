//
//  UpdateStatusCell.m
//  Currently
//
//  Created by Darshan Shankar on 10/1/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "UpdateStatusCell.h"

@implementation UpdateStatusCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 44)];
        [self.label setNumberOfLines:1];
        [self addSubview:self.label];
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(120, 0, 190, 44)];
        [self addSubview:self.textField];
        self.textField.textAlignment = NSTextAlignmentRight;
    }
    return self;
}
@end
