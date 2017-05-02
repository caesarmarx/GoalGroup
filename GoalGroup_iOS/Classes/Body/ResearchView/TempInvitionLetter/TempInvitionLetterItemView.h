//
//  TempInvitionLetterItemView.h
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChallengeItemView.h"
#import "SwipeMenuViewCell.h"

@class TempInvitionLetterItemView;

@protocol TempInvitioLetterItemViewDelegate <NSObject>

@optional
- (void)doClickAgree:(TempInvitionLetterItemView *) cell;
- (void)doClickDisagress:(TempInvitionLetterItemView *) cell;
- (void)doClickClubDetail:(TempInvitionLetterItemView *)cell clubID:(int)c_id;
- (void)menuDidShowInCell:(TempInvitionLetterItemView *)cell;
- (void)menuDidHideInCell;

@end

@interface TempInvitionLetterItemView : SwipeMenuViewCell<ChallengeItemViewDelegate>
{
    ChallengeItemView *itemView;
}

- (void)drawTempLetterWithRecord:(ChallengeListRecord *)record;
- (void)closeMenu;

@property(nonatomic, strong) UIButton *agreeButton;
@property(nonatomic, strong) UIButton *disagreeButton;
@property(nonatomic, weak) id<TempInvitioLetterItemViewDelegate> delegate;

@end
