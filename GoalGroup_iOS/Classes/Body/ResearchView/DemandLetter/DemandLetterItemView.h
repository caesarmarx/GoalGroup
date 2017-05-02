//
//  DemandLetterItemView.h
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DemandListRecord.h"
#import "SwipeMenuViewCell.h"
#import "MarqueeLabel.h"

@class DemandLetterItemView;

@protocol DemandLetterItemViewDelegate <NSObject>

@optional
- (void)doClickAgree:(DemandLetterItemView *) cell;
- (void)doClickDisagress:(DemandLetterItemView *) cell;
- (void)doClickClubDetail:(DemandLetterItemView *)cell;
- (void)menuDidShowInCell:(DemandLetterItemView *)cell;
- (void)menuDidHideInCell;

@end

@interface DemandLetterItemView : SwipeMenuViewCell
{
    UIImageView *thumbImage;
    MarqueeLabel *titleLabel;
    UILabel *dateLabel;
}

- (void)drawDemandLetterWithRecord:(DemandListRecord *)record;
- (void)closeMenu;

@property(nonatomic, strong) UIButton *agreeButton;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, weak) id<DemandLetterItemViewDelegate> delegate;

@end
