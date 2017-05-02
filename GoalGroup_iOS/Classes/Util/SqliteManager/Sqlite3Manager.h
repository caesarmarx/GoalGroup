//
//  Sqlite3Manager.h
//  GoalGroup
//
//  Created by lion on 5/3/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ChatMessage.h"

@class Sqlite3Manager;
Sqlite3Manager *gSqlite3Manager;

@interface Sqlite3Manager : NSObject

+ (id)sharedInstance;
- (id)init;
- (void)initDataBase;
- (int)addChattingMessage:(ChatMessage *)msg;
- (NSArray *)getMessageInRoom:(int)nRoomID;
- (NSArray *)getUnreadMessageInRoom:(int)nRooID;
- (NSArray *)getUnsendMessage;
- (int)intWithUnreadMessageCountInRoom:(int)nRoomID;
- (void)allMessageStateToReadInRoom:(int)nRoomID;
- (void)allMessageStateToSend;
- (void)removeAllMessagesInRoom:(int)nRoomID;
- (NSString *)lastChattingTimeInRoom:(int)RoomID;
- (NSString *)lastReceivedChattingTimeAllRoom;
- (NSString *)lastChattingLog:(int)RoomID;
- (void)updateAudioMessagePath:(NSString *)filePath atIndex:(int)index;
- (void)updateReceivedChattingTimeWithChat:(ChatMessage *)msg;

@property (nonatomic, assign) sqlite3 *localDbHandler;

@end
