//
//  ConferenceListRecord.h
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConferenceListRecord : NSObject
{
    int nRoomID;
    int nGameType;
    int nGameID;
    int team1;
    int team2;
    int unreadCnt;
    int players;
    int nGameState;
    int nChallState;
    
    NSString *sendImageUrl;
    NSString *recvImageUrl;
    NSString *lastMssgTextAndChatter;
    NSString *teamStr1;
    NSString *teamStr2;
    NSString *gameDateTime;
}

- (id)initWithID:(int)room
       sendImage:(NSString *)sendImage
       recvImage:(NSString *)recvImage
            dateTime:(NSString *)datetime
           gameType:(int)type
             gameId:(int)game_id
              team1:(int)t1
              team2:(int)t2
           teamStr1:(NSString *)teamName1
           teamStr2:(NSString *)teamName2
          unread:(int)count
         players:(int)p
      challState:(int)challState
       gameState:(int)gameState
    lastChatInfo:(NSString *)chatInfo;


- (NSString *)stringWithGameDateTime;
- (NSString *)stringWithTeam1;
- (NSString *)stringWithTeam2;
- (NSString *)stringWithSendClubImage;
- (NSString *)stringWithRecvClubImage;
- (NSString *)stringWithLastMsgChatter;
- (int)intWithGameID;
- (int)intWithGameType;
- (int)intWithTeam1;
- (int)intWithTeam2;
- (int)intWithRoomID;
- (int)intWithUnreadCount;
- (int)intWithGamePlayers;
- (int)intWithChallState;
- (int)intWithGameState;
- (NSString *)stringWithLastTime;
@end


@class ConferenceListManager;
ConferenceListManager *gConferenceListManager;

@interface ConferenceListManager : NSObject

+ (ConferenceListManager *) sharedInstance;

@end