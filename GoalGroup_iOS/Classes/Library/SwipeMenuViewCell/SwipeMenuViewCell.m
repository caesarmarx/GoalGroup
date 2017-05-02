//
//  SwipeMenuViewCell.m
//  GoalGroup
//
//  Created by MacMini on 3/21/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "SwipeMenuViewCell.h"

@implementation SwipeMenuViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        swiped = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)prepareForReuse
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)closeMenuView
{
}

- (void)openMenuView
{
}
@end
