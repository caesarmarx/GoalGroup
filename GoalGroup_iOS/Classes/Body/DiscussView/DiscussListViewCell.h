//
//  DiscussListViewCell.h
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscussListRecord.h"

@interface DiscussListViewCell : UITableViewCell
{
    UIView *backView;
    UIImageView *thumbDiscuss;
    UIImageView *thumbOffer;
    UILabel *offerLabel;
    UILabel *introLabel;
    UILabel *articles;
    UIView *articleBack;
}

- (void)dataWithDiscussRecord:(DiscussListRecord *)record;
@end
