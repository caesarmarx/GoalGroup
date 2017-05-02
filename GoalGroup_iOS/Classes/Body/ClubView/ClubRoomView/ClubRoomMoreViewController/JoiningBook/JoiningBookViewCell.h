//
//  JoiningBookViewCell.h
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerListRecord.h"
#import "SwipeMenuViewCell.h"

@class JoiningBookViewCell;
@protocol JoiningBookViewCellDelegate <NSObject>

@optional

- (void)doClickAgree:(JoiningBookViewCell *) cell;
- (void)doClickDisagress:(JoiningBookViewCell *) cell;
- (void)doClickPlayerDetail:(JoiningBookViewCell *)cell;
- (void)menuDidShowInCell:(JoiningBookViewCell *)cell;
- (void)menuDidHideInCell;
@end

@interface JoiningBookViewCell : SwipeMenuViewCell
{
    UIImageView *thumbImage;
    UILabel *namePosLabel;
    UILabel *bookingDateLabel;
    UILabel *posLabel;
}

- (void)drawJoiningBookWithRecord:(PlayerListRecord *)record;
- (void)closeMenu;

@property(nonatomic, strong) UIButton *agreeButton;
@property(nonatomic, strong) UIButton *disagreeButton;
@property(nonatomic, weak) id<JoiningBookViewCellDelegate> delegate;

@end
