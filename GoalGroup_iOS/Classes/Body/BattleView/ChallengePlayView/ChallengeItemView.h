//
//  ChallengeItemView.h
//  GoalGroup
//
//  Created by KCHN on 2/14/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChallengeListRecord.h"

@class ChallengeItemView;

@protocol ChallengeItemViewDelegate <NSObject>
@optional
- (void)doClickClubDetail:(NSInteger)nClubID;
@end

@interface ChallengeItemView : UIView
{
    NSString *playerStr;
    NSString *dateStr;
    NSString *timeStr;
    NSString *playDayStr;
    NSString *extraTimeStr;
    NSString *stadiumStr;
    NSString *sendClubStr;
    NSString *recvClubStr;
    NSString *vsStr;
    UIView *center;
    UILabel *centerPeople;
    UILabel *lblClub1;
    UILabel *lblClub2;
    UILabel *lblStadium;
    UILabel *lblStadiumArrow;
    UILabel *lblDate;
    UILabel *lblTime;
    UIView *sendClubBack;
    UIView *recvClubBack;
    UIImageView *sendClubImage;
    UIImageView *recvClubImage;
    int sendClubID;
    int recvClubID;
    int tempInvState;
}

- (void)dataWithChallengeItem:(ChallengeListRecord *)record;

@property BOOL showTeam;
@property BOOL detail;
@property BOOL letterMode;
@property(nonatomic, weak) id<ChallengeItemViewDelegate> delegate;

@end
