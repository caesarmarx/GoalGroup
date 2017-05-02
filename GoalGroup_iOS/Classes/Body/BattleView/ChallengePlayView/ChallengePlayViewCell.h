//
//  ChallengePlayViewCell.h
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "challengeListRecord.h"
#import "ChallengeItemView.h"
#import "SwipeMenuViewCell.h"

@class ChallengePlayViewCell;
@protocol ChallengePlayViewCellDelegate <NSObject>

@optional
- (void)gotoClubDetail:(ChallengePlayViewCell *) cell clubID:(int)c_id;
- (void)recommandToClubRoom:(ChallengePlayViewCell *)cell;
- (void)gotoChallengeDiscuss:(ChallengePlayViewCell *)cell withArrowView:(ChallengeItemView *)arrowView;
- (void)agreeGame:(ChallengePlayViewCell *)cell withArrowView:(ChallengeItemView *)arrowView;
- (void)menuDidShowInCell:(ChallengePlayViewCell *)cell;
- (void)menuDidHideInCell;
@end

@interface ChallengePlayViewCell : SwipeMenuViewCell<ChallengeItemViewDelegate>
{
    BOOL showTeam;
}

@property(nonatomic, weak) id<ChallengePlayViewCellDelegate> delegate;
@property(nonatomic, weak) ChallengeListRecord *challengeRecord;


- (void)dataWithChallengeRecord:(ChallengeListRecord *)data;
- (id)initMyChallengeWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (id)initChallengeWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (id)initNoticeWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)closeMenu;

@end
