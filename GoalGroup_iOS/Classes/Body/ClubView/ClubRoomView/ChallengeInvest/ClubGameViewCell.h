//
//  ClubGameViewCell.h
//  GoalGroup
//
//  Created by KCHN on 2/26/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChallengeListRecord.h"
#import "SwipeMenuViewCell.h"
#import "ChallengeItemView.h"

@class ClubGameViewCell;
@protocol ClubGameViewCellDelegate <NSObject>
- (void)cancelButtonClick:(ClubGameViewCell *)cell;
- (void)gotoClubDetail:(ClubGameViewCell *)cell clubID:(int)c_id;
- (void)recommandToClubRoom:(ClubGameViewCell *)cell;
- (void)gotoChallengeDiscuss:(ClubGameViewCell *)cell withArrowView:(ChallengeItemView *)arrowView;
- (void)agreeGame:(ClubGameViewCell *)cell withArrowView:(ChallengeItemView *)arrowView;
- (void)menuDidShowInCell:(ClubGameViewCell *)cell;
- (void)menuDidHideInCell;
@end

@interface ClubGameViewCell : SwipeMenuViewCell<ChallengeItemViewDelegate>
{
    BOOL showTeam;
}

@property(nonatomic, retain) id<ClubGameViewCellDelegate> delegate;
@property int nclub;

- (void)dataWithChallengeRecord:(ChallengeListRecord *)data;
- (id)initMyChallengeWithStyle:(UITableViewCellStyle)style resueIdentifier:(NSString *)resueIdentifier;
- (id)initMyNoticeWithStyle:(UITableViewCellStyle)style resueIdentifier:(NSString *)resueIdentifier;
- (void)closeMenu;
@end
