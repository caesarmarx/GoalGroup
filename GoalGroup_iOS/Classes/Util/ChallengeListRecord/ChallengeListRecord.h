//
//  ChallengeListRecord.h
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChallengeListRecord : NSObject
{
    int playerNumber;
    NSString *playDate;
    int playDay;
    NSString *playTime;
    NSString *playStadiumArea;
    NSString *playStadiumAddress;
    NSString *sendClubName;
    NSString *recvClubName;
    NSString *sendImageUrl;
    NSString *recvImageUrl;
    int sendClubID;
    int recvClubID;
    int gameID;
    int nTempInvState;
    int nVSStatus;
    BOOL bTempUnread;
}

//Used in ChallengeList, NoticeList
- (id)initWithSendClubName:(NSString *)name1
             sendImageUrl:(NSString *)imageUrl1
              recvClubName:(NSString *)name2
             recvImageUrl:(NSString *)imageUrl2
              playerNumber:(int)peoples
                  playDate:(NSString *)pDate
                   playDay:(int)pDay
                  playTime:(NSString *)pTime
           playStadiumArea:(NSString *)pStadiumArea
        playStadiumAddress:(NSString *)pStadiumAddr
                sendClubID:(int)s_id
                recvClubID:(int)r_id
                    gameID:(int)gid
              tempInvState:(int)tIState
                  vcStatus:(int)status
                 tempUnread:(int)read;

- (NSString *)stringWithPlayers;
- (int)intWithPlayers;
- (NSString *)stringWithPlayDate;
- (int)intWithPlayDay;
- (NSString*)stringWithPlayDay;
- (NSString *)stringWithPlayStadiumAreaAndAddress;
- (NSString *)stringWithPlayStadiumArea;
- (NSString *)stringWithPlayStadiumAddress;
- (NSString *)stringWithPlayTime;
- (NSString *)stringWithSendClubName;
- (NSString *)stringWithRecvClubName;
- (NSString *)stringWithSendImageUrl;
- (NSString *)stringWithRecvImageUrl;
- (int)intWithSendClubID;
- (int)intWithRecvClubID;
- (int)intWithGameID;
- (int)intWithTempInvState;
- (int)intWithCallClubID;
- (int)intWithVSStatus;
- (BOOL)booleanWithTempUnread;
- (void)itemRead;

@end

@class ChallengeListManager;
ChallengeListManager *gChallengeListManager;

@interface ChallengeListManager : NSObject

+ (ChallengeListManager *)sharedInstance;

@end

