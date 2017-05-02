//
//  ConferenceListRecord.m
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ConferenceListRecord.h"
#import "DiscussRoomManager.h"

@implementation ConferenceListRecord

- (id)initWithID:(int)room sendImage:(NSString *)sendImage recvImage:(NSString *)recvImage dateTime:(NSString *)datetime  gameType:(int)type gameId:(int)game_id team1:(int)t1 team2:(int)t2 teamStr1:(NSString *)teamName1 teamStr2:(NSString *)teamName2 unread:(int)count players:(int)p challState:(int)challState gameState:(int)gameState lastChatInfo:(NSString *)chatInfo
{
    nRoomID = room;
    sendImageUrl = sendImage;
    recvImageUrl = recvImage;
    gameDateTime = datetime;
    nGameID = game_id;
    nGameType = type;
    team1 = t1;
    team2 = t2;
    teamStr1 = teamName1;
    teamStr2 = teamName2;
    unreadCnt = count;
    players = p;
    nGameState = gameState;
    nChallState = challState;
    lastMssgTextAndChatter = chatInfo;
    return self;
}

- (NSString *)stringWithGameDateTime
{
    return gameDateTime;
}

- (NSString *)stringWithTeam1
{
    return teamStr1;
}

- (NSString *)stringWithTeam2
{
    return teamStr2;
}

- (NSString *)stringWithSendClubImage
{
    return sendImageUrl;
}

- (NSString *)stringWithRecvClubImage
{
    return recvImageUrl;
}

- (int)intWithGameID
{
    return nGameID;
}

- (int)intWithGameType
{
    return nGameType;
}

- (int)intWithTeam1
{
    return team1;
}
- (int)intWithTeam2
{
    return team2;
}

- (int)intWithRoomID
{
    return nRoomID;
}

- (int)intWithGamePlayers
{
    return players;
}

- (int)intWithUnreadCount
{
    return [[DiscussRoomManager sharedInstance] unreadCountInRoomID:nRoomID];
}

- (NSString *)stringWithLastMsgChatter
{
//    return [[DiscussRoomManager sharedInstance] lastChattingMsgAndManInRoomID:nRoomID];
    return lastMssgTextAndChatter;
}

- (NSString *)stringWithLastTime
{
    return [[DiscussRoomManager sharedInstance] lastChattingTimeInRoomID:nRoomID];
}

- (int)intWithChallState
{
    return nChallState;
}

- (int)intWithGameState
{
    return nGameState;
}
@end

@implementation ConferenceListManager

+ (ConferenceListManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gConferenceListManager == nil)
            gConferenceListManager = [[ConferenceListManager alloc] init];
    }
    return gConferenceListManager;
}

@end