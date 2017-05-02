//
//  ClubListViewCell.h
//  GoalGroup
//
//  Created by KCHN on 2/6/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClubListRecord.h"

@class ClubListViewCell;
@protocol ClubListViewCellDelegate <NSObject>
- (void)clubDetailClick:(ClubListViewCell *)cell;
@end

@interface ClubListViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *thumbImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *unreadLabel;
@property (nonatomic, strong) UIView *unreadView;

@property (nonatomic, strong) id<ClubListViewCellDelegate> delegate;
- (void)dataWithClubRecord:(ClubListRecord *)record;

@end
