//
//  ChallengeListRecord.m
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ChallengeListRecord.h"
#import "Common.h"

@implementation ChallengeListRecord

- (id) initWithSendClubName:(NSString *)name1 sendImageUrl:(NSString *)imageUrl1 recvClubName:(NSString *)name2 recvImageUrl:(NSString *)imageUrl2 playerNumber:(int)peoples playDate:(NSString *)pDate playDay:(int)pDay playTime:(NSString *)pTime playStadiumArea:(NSString *)pStadiumArea playStadiumAddress:(NSString *)pStadiumAddr sendClubID:(int)s_id recvClubID:(int)r_id gameID:(int)gid tempInvState:(int)tIState vcStatus:(int)status tempUnread:(int)read
{
    sendClubName = name1;
    recvClubName = name2;
    sendImageUrl = imageUrl1;
    recvImageUrl = imageUrl2;
    playerNumber = peoples;
    playDate = pDate;
    playDay = pDay;
    playTime = pTime;
    playStadiumAddress = pStadiumAddr;
    playStadiumArea = pStadiumArea;
    sendClubID = s_id;
    recvClubID = r_id;
    gameID = gid;
    nTempInvState = tIState;
    nVSStatus = status;
    bTempUnread = read;
    return self;
}

- (NSString *)stringWithPlayers
{
    return [[NSString stringWithFormat:@"%i", playerNumber] stringByAppendingString:LANGUAGE(@"player number")];
}

- (int)intWithPlayers
{
    return playerNumber;
}

- (NSString *)stringWithPlayDate
{
    return playDate;
}
- (int)intWithPlayDay
{
    return playDay;
}

- (NSString*)stringWithPlayDay
{
    NSString* week_day[] = {
        LANGUAGE(@"week_mon"),LANGUAGE(@"week_tue"),LANGUAGE(@"week_web"),LANGUAGE(@"week_thu"),LANGUAGE(@"week_fri"),LANGUAGE(@"week_sat"),LANGUAGE(@"week_sun")
    };
    if (playDay == 0)
        return week_day[6];
    return week_day[playDay-1];
}
- (NSString *)stringWithPlayStadiumAddress
{
    return playStadiumAddress;
}

- (NSString *)stringWithPlayStadiumArea
{
    return playStadiumArea;
}

- (NSString *)stringWithPlayStadiumAreaAndAddress
{
    return [playStadiumArea stringByAppendingString:playStadiumAddress];
}

- (NSString *)stringWithPlayTime
{
    return playTime;
}

- (NSString *)stringWithSendClubName
{
    return sendClubName;
}

- (NSString *)stringWithRecvClubName
{
    return recvClubName;
}

- (NSString *)stringWithSendImageUrl
{
    return sendImageUrl;
}

- (NSString *)stringWithRecvImageUrl;
{
    return recvImageUrl;
}

- (int)intWithSendClubID
{
    return sendClubID;
}

- (int)intWithRecvClubID
{
    return recvClubID;
}

- (int)intWithGameID
{
    return gameID;
}

- (int)intWithTempInvState
{
    return nTempInvState;
}

- (int)intWithCallClubID
{
    return nTempInvState == 1? sendClubID: recvClubID;
}

- (int)intWithVSStatus
{
    return nVSStatus;
}
- (BOOL)booleanWithTempUnread
{
    return bTempUnread;
}
- (void)itemRead
{
    bTempUnread = NO;
}
@end

@implementation ChallengeListManager

+ (ChallengeListManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gChallengeListManager == nil)
            gChallengeListManager = [[ChallengeListManager alloc] init];
    }
    return gChallengeListManager;
}

@end