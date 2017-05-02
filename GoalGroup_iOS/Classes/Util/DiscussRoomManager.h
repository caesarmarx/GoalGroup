//
//  DiscussRoomManager.h
//  GoalGroup
//
//  Created by MacMini on 5/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DiscussRoomManager;
DiscussRoomManager *gDiscussRoomManager;

@interface DiscussRoomItem : NSObject
{
    int nRoomID;
    int sendClubID;
    int recvClubID;
    int nGameType;
    int nGameID;
    NSString *gameDate;
    NSString *lastChattingDate;
    NSString *sendClubStr1;
    NSString *recvClubStr2;
    NSString *roomTitleStr;
    NSString *sendImgUrl;
    NSString *recvImgUrl;
    int players;
    int nChallState;
    int nGameState;
}

- (id)initWithRoomID:(int)roomID sendTeam:(int)nTeam1 recvTeam:(int)nTeam2 gameType:(int)gameType gameID:(int)gameID date:(NSString *)date sendStr1:(NSString *)teamName1 recvStr2:(NSString *)teamName2 title:(NSString *)roomTitle createDate:(NSString *)createdate sendImage:(NSString *)image1 recvImage:(NSString *)image2 players:(int)player challState:(int)challState gameState:(int)gameState;
- (int)intWithRoomID;
- (int)intWithSendClubID;
- (int)intWithRecvClubID;
- (int)intWithGameID;
- (int)intWithGameType;
- (NSString *)stringWithGameDate;
- (NSString *)stringWithSendName;
- (NSString *)stringWithRecvName;
- (NSString *)stringWithRoomTitle;
- (NSString *)stringWithLastChattingDate;
- (NSString *)stringWithSendImageUrl;
- (NSString *)stringWithRecvImageUrl;
- (NSString *)lastChatMsgMan;
- (int)intWithGameState;
- (int)intWithChallState;
- (int)unreadCount;
- (int)intWithGamePlayers;
- (void)setGameType:(int)gameType;
- (void)setGameID:(int)gameID;
- (void)setGameDate:(NSString *)strDate;
- (void)setRoomTitle:(NSString *)strRoomTitle;
- (void)setChallState:(int)state;
- (void)setGameState:(int)state;
- (void)setGamePlayer:(int)player;
- (void)updateDiscussRoomWithgameID:(int)gameID gameType:(int)gameType gameDate:(NSString *)strDate roomTitle:(NSString *)roomTitle challState:(int)challState gameState:(int)gameState player:(int)player;
- (void)deleteAllMessages;

@end

@interface DiscussRoomManager : NSObject
{
    NSMutableArray *discussChatRooms;
}

+ (DiscussRoomManager *)sharedInstance;
- (void)setDiscussChatRooms:(NSArray *)rooms;
- (void)addDiscussChatRoom:(DiscussRoomItem *)room;
- (void)addDiscussChatRoom:(int)nRoomID roomTitles:(NSString *)roomTitles;
- (NSArray *)getChatRooms;
- (DiscussRoomItem *)getChatRoomAtIndex:(int)index;
- (DiscussRoomItem *)discussRoomWithID:(int)roomID;
- (int)discussRoomIDWithSendID:(int)sendID recvID:(int)recvID gameID:(int)gameID gametype:(int)gameType;
- (int)unreadCountInRoomID:(int)index;
- (NSString *)lastChattingMsgAndManInRoomID:(int)index;
- (int)unreadCountAll;
- (void)updateLastChattingTimeForRoom:(int)nRoomID;
- (NSString *)lastChattingTimeInRoomID:(int)nRoomID;
- (void)removeChatRoomsWithClubID:(int)nClubID;
- (void)updateDiscussRoom:(int)nRoomID gameID:(int)gameID gameType:(int)gameType gameDate:(NSString *)gameDate roomTitle:(NSString *)roomTitle challState:(int)challState gameState:(int)gameState player:(int)player;
- (BOOL)checkWithRoomID:(int)roomID;
- (void)deleteAllMessages;

@end
