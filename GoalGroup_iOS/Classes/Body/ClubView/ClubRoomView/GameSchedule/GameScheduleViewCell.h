//
//  GameScheduleViewCell.h
//  GoalGroup
//
//  Created by KCHN on 2/13/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameScheduleRecord.h"

@class GameScheduleViewCell;
@protocol GameScheduleViewCellDelegate <NSObject>

@optional
- (void)joinGameClick:(GameScheduleViewCell *)cell;
- (void)gotoDiscussRoomClick:(GameScheduleViewCell *)cell;
- (void)sendClubPlayerClick:(GameScheduleViewCell *)cell;
- (void)recvClubPlayerClick:(GameScheduleViewCell *)cell;
- (void)menuDidShowInCell:(GameScheduleViewCell *)cell;
- (void)clubDetailClick:(GameScheduleViewCell *)cell send:(BOOL)sendClub;
- (void)menuDidHideInCell;

@end

@interface GameScheduleViewCell : UITableViewCell
{
    UIImageView *sendClubImage;
    UIImageView *recvClubImage;
    UILabel *team1Label;
    UILabel *team2Label;
    UILabel *vsLabel;
    UILabel *playerLabel;
    UILabel *sendPlayerLabel;
    UILabel *recvPlayerLabel;
    UILabel *timeLabel;
}
- (void)drawWithGameScheduleRecord:(GameScheduleRecord *)record;

@property(nonatomic, weak) id<GameScheduleViewCellDelegate> delegate;

//This means whether Club -> PlusView -> GameSchedule or Search -> TempInvitation
//YES: TempInvitation, NO:Club ->...
@property(nonatomic) BOOL mode;
@property(nonatomic) int nMineClub;
- (void)closeMenu;

@end
