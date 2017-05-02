//
//  PlayerMarkectItemView.h
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerListRecord.h"
#import "SwipeMenuViewCell.h"

@class PlayerMarkectItemView;
@protocol PlayerMarketItemViewDelegate <NSObject>

@optional

- (void)doClickRecommend:(PlayerMarkectItemView *) cell;
- (void)doClickTempInvite:(PlayerMarkectItemView *) cell withFromView:(UIView *)view;
- (void)doClickInvite:(PlayerMarkectItemView *) cell withFromView:(UIView *)view;
- (void)doClickPlayerDetail:(PlayerMarkectItemView *)cell;
- (void)menuDidShowInCell:(PlayerMarkectItemView *)cell;
- (void)menuDidHideInCell;
@end

@interface PlayerMarkectItemView : SwipeMenuViewCell

- (void)drawPlayerWithRecord:(PlayerListRecord *)record;
- (void)closeMenu;

@property(nonatomic, weak) id<PlayerMarketItemViewDelegate> delegate;

@property (nonatomic, strong) UIImageView *thumbImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *ageLabel;
@property (nonatomic, strong) UILabel *footballAgeLabel;
@property (nonatomic, strong) UILabel *heightLabel;
@property (nonatomic, strong) UILabel *weightLabel;
@property (nonatomic, strong) UILabel *posLabel;
@property (nonatomic, strong) UILabel *areaLabel;
@property (nonatomic, strong) UILabel *weekLabel;
@property (nonatomic, strong) UILabel *posResultLabel;
@property (nonatomic, strong) UILabel *areaResultLabel;
@property (nonatomic, strong) UILabel *weekResultLabel;

//【推】
//【租】
//【邀】
@property (nonatomic, strong) UIButton *recommendButton;
@property (nonatomic, strong) UIButton *tempInviteButton;
@property (nonatomic, strong) UIButton *inviteButton;

@property NSInteger playerID;


@end
