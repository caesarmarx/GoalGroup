//
//  ClubMarketItemView.h
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClubListRecord.h"
#import "SwipeMenuViewCell.h"

@class ClubMarketItemView;

@protocol ClubMarketItemViewDelegate <NSObject>

@optional
- (void)doClickJoin:(ClubMarketItemView *) cell;
- (void)doClickNotie:(ClubMarketItemView *) cell fromView:(UIView *)view;
- (void)doClickClubDetail:(ClubMarketItemView *) cell;
- (void)menuDidShowInCell:(ClubMarketItemView *)cell;
- (void)menuDidHideInCell;

@end

@interface ClubMarketItemView : SwipeMenuViewCell

- (void)drawClubWithRecord:(ClubListRecord *)record;
- (void)closeMenu;

@property(nonatomic, weak) id<ClubMarketItemViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *thumbImage;
@property (nonatomic, strong) UIImageView *memberIcon;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *ageLabel;
@property (nonatomic, strong) UILabel *ageResultLabel;
@property (nonatomic, strong) UILabel *weekLabel;
@property (nonatomic, strong) UILabel *weekResultLabel;
@property (nonatomic, strong) UILabel *areaLabel;
@property (nonatomic, strong) UILabel *areaResultLabel;
@property (nonatomic, strong) UILabel *memberLabel;
@property (nonatomic, strong) UILabel *rateLabel;
@property (nonatomic, strong) UIButton *joinButton;
@property (nonatomic, strong) UIButton *noticeButton;
@property NSInteger activeRate;

@end
