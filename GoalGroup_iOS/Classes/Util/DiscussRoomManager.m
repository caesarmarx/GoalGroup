//
//  DiscussRoomManager.m
//  GoalGroup
//
//  Created by MacMini on 5/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DiscussRoomManager.h"
#import "Sqlite3Manager.h"
#import "ClubManager.h"
#import "Common.h"


@implementation DiscussRoomItem

- (id)initWithRoomID:(int)roomID sendTeam:(int)nTeam1 recvTeam:(int)nTeam2 gameType:(int)gameType gameID:(int)gameID date:(NSString *)date sendStr1:(NSString *)teamName1 recvStr2:(NSString *)teamName2 title:(NSString *)roomTitle createDate:(NSString *)createdate sendImage:(NSString *)image1 recvImage:(NSString *)image2 players:(int)player challState:(int)challState gameState:(int)gameState
{
    nRoomID = roomID;
    sendClubID = nTeam1;
    recvClubID = nTeam2;
    nGameType = gameType;
    nGameID = gameID;
    gameDate = date;
    sendClubStr1 = teamName1;
    recvClubStr2 = teamName2;
    roomTitleStr = roomTitle;
    sendImgUrl = image1;
    recvImgUrl = image2;
    players = player;
    nChallState = challState;
    nGameState = gameState;
    lastChattingDate = [[Sqlite3Manager sharedInstance] lastChattingTimeInRoom:roomID];
    return self;
}

- (int)intWithRoomID
{
    return nRoomID;
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
    return nGameID;
}

- (int)intWithGameType
{
    return nGameType;
}

- (NSString *)stringWithGameDate
{
    return gameDate;
}

- (NSString *)stringWithSendName
{
    return sendClubStr1;
}

- (NSString *)stringWithRecvName
{
    return recvClubStr2;
}

- (NSString *)stringWithRoomTitle
{
    return roomTitleStr;
}

- (NSString *)stringWithLastChattingDate
{
    return [[Sqlite3Manager sharedInstance] lastChattingTimeInRoom:nRoomID];
}

- (int)unreadCount
{
    return [[Sqlite3Manager sharedInstance] intWithUnreadMessageCountInRoom:nRoomID];
}

/*
 기능: 상의마당에서 마지작채팅메쎄지와 유저이름얻기
 */
- (NSString *)lastChatMsgMan
{
    return [[Sqlite3Manager sharedInstance] lastChattingLog:nRoomID];
}

- (int)intWithGamePlayers
{
    return players;
}

- (NSString *)stringWithSendImageUrl
{
    return sendImgUrl;
}

- (NSString *)stringWithRecvImageUrl
{
    return recvImgUrl;
}

- (void)setGameType:(int)gameType
{
    nGameType = gameType;
}

- (void)setGameID:(int)gameID
{
    nGameID = gameID;
}

- (void)setGameState:(int)state
{
    nGameState = state;
}

- (void)setGamePlayer:(int)player
{
    players = player;
}

- (void)setRoomTitle:(NSString *)strRoomTitle
{
    roomTitleStr = strRoomTitle;
}

- (void)setChallState:(int)state
{
    nChallState = state;
}

- (int)intWithGameState
{
    return nGameState;
}

- (void)setGameDate:(NSString *)strDate
{
    gameDate = strDate;
}

- (int)intWithChallState
{
    return nChallState;
}

- (void)updateDiscussRoomWithgameID:(int)gameID gameType:(int)gameType gameDate:(NSString *)strDate roomTitle:(NSString *)roomTitle challState:(int)challState gameState:(int)gameState player:(int)player
{
    nGameID = gameID;
    nGameType = gameType;
    gameDate = strDate;
    roomTitleStr = roomTitle;
    nChallState = challState;
    nGameState = gameState;
    players = player;
    
#ifdef DEMO_MODE
    NSLog(@"%@상의마당이 갱신되였습니다. 방 = %d", LOGTAG, nRoomID);
#endif
}

- (void)deleteAllMessages
{
    [[Sqlite3Manager sharedInstance] removeAllMessagesInRoom:nRoomID];
}

@end


@implementation DiscussRoomManager

+ (DiscussRoomManager *)sharedInstance{
    @synchronized(self)
    {
        if (gDiscussRoomManager == nil)
            gDiscussRoomManager = [[DiscussRoomManager alloc] init];
    }
    return gDiscussRoomManager;
}

- (id)init
{
    self = [super init];
    if (self)
        discussChatRooms = [[NSMutableArray alloc] init];
    return self;
}

- (void)setDiscussChatRooms:(NSArray *)rooms
{
    for (NSDictionary *item in rooms) {
        NSArray *array = [[item valueForKey:@"chat_room_title"] componentsSeparatedByString:@"::"];
        
        int nRoomID = [[item valueForKey:@"chat_room_id"] intValue];
        int team1 = [[array objectAtIndex:0] intValue];
        NSString *teamStr1 = [array objectAtIndex:1];
        int team2 = [[array objectAtIndex:2] intValue];
        NSString *teamStr2 = [array objectAtIndex:3];
        int nGameType = [[array objectAtIndex:4] intValue];
        int nGameID = [[array objectAtIndex:5] intValue];
        NSString *gameDate = [array objectAtIndex:6];
        int players = [[array objectAtIndex:7] intValue];
        NSString *imageUrl1 = [array objectAtIndex:8];
        NSString *imageUrl2 = [array objectAtIndex:9];
        int challState = [[array objectAtIndex:10] intValue];
        int gameState = [[array objectAtIndex:11] intValue];

        NSString *title = [NSString stringWithFormat:@"%@ VS %@ %@", teamStr1, teamStr2, gameDate];
        NSString *createDate = [item valueForKey:@"create_datetime"];
        
        if (![[ClubManager sharedInstance] checkAdminClub:team1] && ![[ClubManager sharedInstance] checkAdminClub:team2])
            continue;

        if ([self checkWithRoomID:nRoomID])
        {
            [self updateDiscussRoom:nRoomID gameID:nGameID gameType:nGameType gameDate:gameDate roomTitle:title challState:challState gameState:gameState player:players];
            continue;
        }
        
        DiscussRoomItem *room = [[DiscussRoomItem alloc] initWithRoomID:nRoomID sendTeam:team1 recvTeam:team2 gameType:nGameType gameID:nGameID date:gameDate sendStr1:teamStr1 recvStr2:teamStr2 title:title createDate:createDate sendImage:imageUrl1 recvImage:imageUrl2 players:players challState:challState gameState:gameState];
        
        [discussChatRooms addObject:room];
        
#ifdef DEMO_MODE
        NSLog(@"%@상의마당이 추가되였습니다. %d", LOGTAG, nRoomID);
#endif
    }
}

- (void)addDiscussChatRoom:(DiscussRoomItem *)room
{
    if (discussChatRooms == nil)
        discussChatRooms = [[NSMutableArray alloc] init];
    
    [discussChatRooms addObject:room];
    
#ifdef DEMO_MODE
    NSLog(@"%@상의마당이 추가되였습니다. %d", LOGTAG, [room intWithRoomID]);
#endif
}

/*
 기능: 상의마당추가 및 정보갱신함수
      관리자권한을 검사한다.
      상의마당아이디를 검사하여 없으면 추가하고 있으면 정보를 갱신한다.
 파람: nRoomID - 상의마당아이디
      roomTitles - 상의마당정보 팀아이디1::팀이름1::팀아이디2::팀이름2::게임형태::게임아이디::게임시간::선수개수::팀쌈브1::팀쌈브2::도전상태::경기상태
 */
- (void)addDiscussChatRoom:(int)nRoomID roomTitles:(NSString *)roomTitles
{
    NSArray *array = [roomTitles componentsSeparatedByString:@"::"];
    
    if (array.count != 12)
        return;
    
    int team1 = [[array objectAtIndex:0] intValue];
    NSString *teamStr1 = [array objectAtIndex:1];
    int team2 = [[array objectAtIndex:2] intValue];
    NSString *teamStr2 = [array objectAtIndex:3];
    int nGameType = [[array objectAtIndex:4] intValue];
    int nGameID = [[array objectAtIndex:5] intValue];
    NSString *gameDate = [array objectAtIndex:6];
    int players = [[array objectAtIndex:7] intValue];
    NSString *imageUrl1 = [array objectAtIndex:8];
    NSString *imageUrl2 = [array objectAtIndex:9];
    int nChallState = [[array objectAtIndex:10] intValue];
    int nGameState = [[array objectAtIndex:11] intValue];
    
    NSString *title = [NSString stringWithFormat:@"%@ VS %@ %@", teamStr1, teamStr2, gameDate];
    NSString *createDate = @"";
    
    if (![[ClubManager sharedInstance] checkAdminClub:team1] && ![[ClubManager sharedInstance] checkAdminClub:team2])
        return;
    
    if ([self checkWithRoomID:nRoomID])
    {
        [self updateDiscussRoom:nRoomID gameID:nGameID gameType:nGameType gameDate:gameDate roomTitle:title challState:nChallState gameState:nGameState player:players];
        return;
    }

    DiscussRoomItem *room = [[DiscussRoomItem alloc] initWithRoomID:nRoomID sendTeam:team1 recvTeam:team2 gameType:nGameType gameID:nGameID date:gameDate sendStr1:teamStr1 recvStr2:teamStr2 title:title createDate:createDate sendImage:imageUrl1 recvImage:imageUrl2 players:players challState:nChallState gameState:nGameState];

    [[DiscussRoomManager sharedInstance] addDiscussChatRoom:room];
}

- (NSArray *)getChatRooms
{
    return discussChatRooms;
}

- (DiscussRoomItem *)getChatRoomAtIndex:(int)index
{
    return [discussChatRooms objectAtIndex:index];
}

- (DiscussRoomItem *)discussRoomWithID:(int)roomID
{
    for (DiscussRoomItem *room in discussChatRooms) {
        if ([room intWithRoomID] == roomID)
            return room;
    }
    return nil;
}

- (int)discussRoomIDWithSendID:(int)sendID recvID:(int)recvID gameID:(int)gameID gametype:(int)gameType
{
    for (DiscussRoomItem *item in discussChatRooms) {
        if ([item intWithSendClubID] != sendID) continue;
        if ([item intWithRecvClubID] != recvID) continue;
        if ([item intWithGameID] != gameID) continue;
        if ([item intWithGameType] != gameType) continue;
        return [item intWithRoomID];
    }
    return -1;
}

- (int)discussIndexWithSendID:(int)sendID recvID:(int)recvID
{
    int i = -1;
    for (DiscussRoomItem *item in discussChatRooms) {
        i ++;
        if ([item intWithSendClubID] != sendID) continue;
        if ([item intWithRecvClubID] != recvID) continue;
        return i;
    }
    return i;
}

- (int)unreadCountInRoomID:(int)index
{
    int count = 0;
    for (DiscussRoomItem *room in discussChatRooms) {
        if ([room intWithRoomID] == index)
            count = [room unreadCount];
    }
    return count;
}

- (NSString *)lastChattingMsgAndManInRoomID:(int)index
{
    NSString *ret = @"";
    for (DiscussRoomItem *room in discussChatRooms) {
        if ([room intWithRoomID] == index)
            ret = [room lastChatMsgMan];
    }
    return ret;
}

- (int)unreadCountAll
{
    int count = 0;
    for (DiscussRoomItem *room in discussChatRooms)
        count += [room unreadCount];
    return count;
}

- (NSString *)lastChattingTimeInRoomID:(int)nRoomID
{
    return [[Sqlite3Manager sharedInstance] lastChattingTimeInRoom:nRoomID];
}

- (void)updateLastChattingTimeForRoom:(int)nRoomID
{
//    for (DiscussRoomItem *room in discussChatRooms)
//        if ([room intWithRoomID] == nRoomID)
//            room.
//            
}

- (BOOL)checkWithRoomID:(int)roomID
{
    for (DiscussRoomItem *room in discussChatRooms)
    {
        if ([room intWithRoomID] == roomID)
            return YES;
    }
    return NO;
}

- (void)removeChatRoomsWithClubID:(int)nClubID
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (DiscussRoomItem *room in discussChatRooms)
    {
        if ([room intWithSendClubID] == nClubID || [room intWithRecvClubID] == nClubID)
            continue;
        [arr addObject:room];
    }
    discussChatRooms = arr;
}

- (void)updateDiscussRoom:(int)nRoomID gameID:(int)gameID gameType:(int)gameType gameDate:(NSString *)gameDate roomTitle:(NSString *)roomTitle challState:(int)challState gameState:(int)gameState player:(int)player
{
    for (DiscussRoomItem *room in discussChatRooms)
    {
        if ([room intWithRoomID] == nRoomID)
            [room updateDiscussRoomWithgameID:gameID gameType:gameType gameDate:gameDate roomTitle:roomTitle challState:challState gameState:gameState player:player];
    }
}

- (void)deleteAllMessages
{
    for (DiscussRoomItem *room in discussChatRooms)
    {
        [room deleteAllMessages];
    }
}
@end
