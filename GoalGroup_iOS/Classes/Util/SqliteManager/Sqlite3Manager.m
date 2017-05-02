//
//  Sqlite3Manager.m
//  GoalGroup
//
//  Created by lion on 5/3/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "Sqlite3Manager.h"
#import "Constants.h"
#import "Common.h"
#import "FileManager.h"

@implementation Sqlite3Manager

@synthesize localDbHandler;
+ (id)sharedInstance
{
    @synchronized(self)
    {
        if (gSqlite3Manager == nil)
            gSqlite3Manager = [[Sqlite3Manager alloc] init];
    }
    
    return gSqlite3Manager;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        sqlite3_open([[FileManager GetDatabaseFilePath] UTF8String], &localDbHandler);
        [self initDataBase];
    }
    return  self;
}

- (void)initDataBase
{
    NSString *query;
    BOOL ret;
    
    query = [NSString stringWithFormat:@"create table if not exists %@(\
             %@ integer primary key autoincrement,\
             %@ integer not null default 0,\
             %@ text not null default (''),\
             %@ timestamp not null default ('0000-00-00 00:00:00'),\
             %@ integer not null default 0,\
             %@ integer not null default 0,\
             %@ text not null default (''),\
             %@ text not null default (''),\
             %@ integer not null default 0,\
             %@ integer not null default 0,\
             %@ integer not null default 1)",
             TABLE_NAME_MESSAGE,
             COL_NAME_MSG_PK,
             COL_NAME_MSG_SENDER_ID,
             COL_NAME_MSG_MESSAGE,
             COL_NAME_MSG_SEND_TIME,
             COL_NAME_MSG_ROOM_ID,
             COL_NAME_STATE,
             COL_NAME_MSG_SENDER_PHOTO,
             COL_NAME_MSG_SENDER_NAME,
             COL_NAME_MSG_READSTATE,
             COL_NAME_MSG_OWNER,
             COL_NAME_MSG_SENDSTATE];
    
    ret = sqlite3_exec(localDbHandler, [query UTF8String], nil, nil, nil) == SQLITE_OK;
    
    query = [NSString stringWithFormat:@"create table if not exists %@(\
             %@ integer primary key autoincrement,\
             %@ integer not null default 0,\
             %@ text not null default (''),\
             %@ timestamp not null default ('0000-00-00 00:00:00'),\
             %@ integer not null default 0,\
             %@ text not null default (''),\
             %@ integer not null default 0)",
             TABLE_NAME_RECEIVEMSGTIME,
             COL_NAME_MSG_PK,
             COL_NAME_MSG_SENDER_ID,
             COL_NAME_MSG_MESSAGE,
             COL_NAME_MSG_SEND_TIME,
             COL_NAME_MSG_ROOM_ID,
             COL_NAME_MSG_SENDER_NAME,
             COL_NAME_MSG_OWNER];
    
    ret = sqlite3_exec(localDbHandler, [query UTF8String], nil, nil, nil) == SQLITE_OK;
   
}

/*
 기능: 마지막채팅시간테이블을 갱신하는 함수
 [내용정리]에 의해서는 채팅리력테이블만 지우고 채팅시간테이블은 지우지 않는다.
 */
- (void)updateReceivedChattingTimeWithChat:(ChatMessage *)msg
{
    NSString *query = [NSString stringWithFormat:@"select count(*) as count from %@ where %@ = %d",
             TABLE_NAME_RECEIVEMSGTIME,
             COL_NAME_MSG_ROOM_ID,
             (int)msg.roomId];
    
    sqlite3_stmt *stmt;
    BOOL ret = sqlite3_prepare(localDbHandler, [query UTF8String], -1, &stmt, nil);
    
    if (ret != SQLITE_OK)
        return;
    
    int nRet = 0;
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        nRet = (int)sqlite3_column_int(stmt, 0);
    }

    if (nRet != 0)
    {
        query = [NSString stringWithFormat:@"update %@ set \
                 %@ = %d, \
                 %@ = \"%@\", \
                 %@ = \"%@\", \
                 %@ = \"%@\", \
                 %@ = %d where \
                 %@ = %d",
                 TABLE_NAME_RECEIVEMSGTIME,
                 COL_NAME_MSG_SENDER_ID,
                 (int)msg.senderId,
                 COL_NAME_MSG_MESSAGE,
                 msg.msg,
                 COL_NAME_MSG_SEND_TIME,
                 msg.sendTime,
                 COL_NAME_MSG_SENDER_NAME,
                 msg.senderName,
                 COL_NAME_MSG_OWNER,
                 UID,
                 COL_NAME_MSG_ROOM_ID,
                 (int)msg.roomId];
        
        sqlite3_exec(localDbHandler, [query UTF8String], nil, nil, nil);
    }
    else
    {
        query = [NSString stringWithFormat:@"insert into %@ (%@, %@, %@, %@, %@, %@) values (%d,\"%@\", \"%@\", %d, \"%@\", %d)",
                 TABLE_NAME_RECEIVEMSGTIME,
                 COL_NAME_MSG_SENDER_ID,
                 COL_NAME_MSG_MESSAGE,
                 COL_NAME_MSG_SEND_TIME,
                 COL_NAME_MSG_ROOM_ID,
                 COL_NAME_MSG_SENDER_NAME,
                 COL_NAME_MSG_OWNER,
                 (int)msg.senderId,
                 msg.msg,
                 msg.sendTime,
                 (int)msg.roomId,
                 msg.senderName,
                 UID
                 ];
        sqlite3_exec(localDbHandler, [query UTF8String], nil, nil, nil);
    }
}

/*
 기능: 채팅히스토리보관
 파람: chatmessage : 채팅클래스
      send : YES - 보내거나 받은 메쎄지, NO - 채팅통신불량으로 보내지 못한 메쎄지
 */
- (int)addChattingMessage:(ChatMessage *)chatmessage
{
    NSString *query = @"";
    
    query = [NSString stringWithFormat:@"insert into %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@) values (%d,\"%@\", \"%@\", %d, %d, \"%@\", \"%@\", %d, %d, %d)",
             TABLE_NAME_MESSAGE,
             COL_NAME_MSG_SENDER_ID,
             COL_NAME_MSG_MESSAGE,
             COL_NAME_MSG_SEND_TIME,
             COL_NAME_MSG_ROOM_ID,
             COL_NAME_STATE,
             COL_NAME_MSG_SENDER_PHOTO,
             COL_NAME_MSG_SENDER_NAME,
             COL_NAME_MSG_READSTATE,
             COL_NAME_MSG_OWNER,
             COL_NAME_MSG_SENDSTATE,
             (int)chatmessage.senderId,
             chatmessage.msg,
             chatmessage.sendTime,
             (int)chatmessage.roomId,
             chatmessage.type,
             chatmessage.userPhoto,
             chatmessage.senderName,
             chatmessage.readState,
             UID,
             chatmessage.sendState
            ];
    
    BOOL ret;
    ret = sqlite3_exec(localDbHandler, [query UTF8String], nil, nil, nil) == SQLITE_OK;
    
    query = [NSString stringWithFormat:@"select * from %@ order by %@ desc limit 0, 1",
             TABLE_NAME_MESSAGE,
             COL_NAME_MSG_PK];
    
    sqlite3_stmt *stmt;
    ret = sqlite3_prepare(localDbHandler, [query UTF8String], -1, &stmt, nil);
    
    if (ret != SQLITE_OK)
        return -1;
    
    int nRet = -1;
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        nRet = (int)sqlite3_column_int(stmt, 0);
    }
    
    if (chatmessage.senderId != UID)
        [self updateReceivedChattingTimeWithChat:chatmessage];
    
    return nRet;
}

/*
 기능: 채티리력얻는 함수
 파람: nRoom: 방아이디
 */
- (NSArray *)getMessageInRoom:(int)nRoomID
{
    sqlite3_stmt *stmt;
    
    NSString *query = [NSString stringWithFormat:@"select * from %@ where %@ = %d and %@ = %d",
                       TABLE_NAME_MESSAGE,
                       COL_NAME_ROOM_ID,
                       nRoomID,
                       COL_NAME_MSG_OWNER,
                       UID];
    
    int ret = sqlite3_prepare(localDbHandler, [query UTF8String], -1, &stmt, nil);
    
    if(ret != SQLITE_OK)
        return nil;
    NSMutableArray *chatmessageList = [[NSMutableArray alloc] init];
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        int senderid = (int)sqlite3_column_int(stmt, 1);
        char *msg = (char *)sqlite3_column_text(stmt, 2);
        char *sendtime = (char *)sqlite3_column_text(stmt, 3);
        int roomid = (int)sqlite3_column_int(stmt, 4);
        int type = (int)sqlite3_column_int(stmt, 5);
        char *photo = (char *)sqlite3_column_text(stmt, 6);
        char *name = (char *)sqlite3_column_text(stmt, 7);
        int sendState = (int)sqlite3_column_int(stmt, 10);
        
        ChatMessage *item = [[ChatMessage alloc] init];
        item.type = type;
        item.senderId = senderid;
        item.msg = [NSString stringWithUTF8String:msg];
        item.sendTime = [NSString stringWithUTF8String:sendtime];
        item.roomId = roomid;
        item.userPhoto = [NSString stringWithUTF8String:photo];
        item.senderName = [NSString stringWithUTF8String:name];
        item.sendState = sendState;
        
        [chatmessageList addObject:item];
        
    }
    
    sqlite3_finalize(stmt);
    
    [self allMessageStateToReadInRoom:nRoomID];
    
    return chatmessageList;
}

/*
 기능: 읽지 않은 대화를 얻는 함수
 */
- (NSArray *)getUnreadMessageInRoom:(int)nRoomID
{
    sqlite3_stmt *stmt;
    
    NSString *query = [NSString stringWithFormat:@"select * from %@ where %@ = %d and %@ = %d and %@ = %d",
                       TABLE_NAME_MESSAGE,
                       COL_NAME_ROOM_ID,
                       nRoomID,
                       COL_NAME_MSG_OWNER,
                       UID,
                       COL_NAME_MSG_READSTATE,
                       0];
    
    int ret = sqlite3_prepare(localDbHandler, [query UTF8String], -1, &stmt, nil);
    
    if(ret != SQLITE_OK)
        return nil;
    NSMutableArray *chatmessageList = [[NSMutableArray alloc] init];
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        int senderid = (int)sqlite3_column_int(stmt, 1);
        char *msg = (char *)sqlite3_column_text(stmt, 2);
        char *sendtime = (char *)sqlite3_column_text(stmt, 3);
        int roomid = (int)sqlite3_column_int(stmt, 4);
        int type = (int)sqlite3_column_int(stmt, 5);
        char *photo = (char *)sqlite3_column_text(stmt, 6);
        char *name = (char *)sqlite3_column_text(stmt, 7);
        int sendState = (int)sqlite3_column_int(stmt, 10);
        
        ChatMessage *item = [[ChatMessage alloc] init];
        item.type = type;
        item.senderId = senderid;
        item.msg = [NSString stringWithUTF8String:msg];
        item.sendTime = [NSString stringWithUTF8String:sendtime];
        item.roomId = roomid;
        item.userPhoto = [NSString stringWithUTF8String:photo];
        item.senderName = [NSString stringWithUTF8String:name];
        item.sendState = sendState;
        
        [chatmessageList addObject:item];
        
    }
    
    sqlite3_finalize(stmt);
    
    [self allMessageStateToReadInRoom:nRoomID];
    
    return chatmessageList;
}

/*
 기능: 보내지 못한 대화를 얻는 함수
 */
- (NSArray *)getUnsendMessage
{
    sqlite3_stmt *stmt;
    
    NSString *query = [NSString stringWithFormat:@"select * from %@ where %@ = %d and %@ = %d",
                       TABLE_NAME_MESSAGE,
                       COL_NAME_MSG_OWNER,
                       UID,
                       COL_NAME_MSG_SENDSTATE,
                       0];
    
    int ret = sqlite3_prepare(localDbHandler, [query UTF8String], -1, &stmt, nil);
    
    if(ret != SQLITE_OK)
        return nil;
    NSMutableArray *chatmessageList = [[NSMutableArray alloc] init];
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        int senderid = (int)sqlite3_column_int(stmt, 1);
        char *msg = (char *)sqlite3_column_text(stmt, 2);
        char *sendtime = (char *)sqlite3_column_text(stmt, 3);
        int roomid = (int)sqlite3_column_int(stmt, 4);
        int type = (int)sqlite3_column_int(stmt, 5);
        char *photo = (char *)sqlite3_column_text(stmt, 6);
        char *name = (char *)sqlite3_column_text(stmt, 7);
        
        ChatMessage *item = [[ChatMessage alloc] init];
        item.type = type;
        item.senderId = senderid;
        item.msg = [NSString stringWithUTF8String:msg];
        item.sendTime = [NSString stringWithUTF8String:sendtime];
        item.roomId = roomid;
        item.userPhoto = [NSString stringWithUTF8String:photo];
        item.senderName = [NSString stringWithUTF8String:name];
        
        [chatmessageList addObject:item];
        
    }
    
    sqlite3_finalize(stmt);
    
    [self allMessageStateToSend];
    
    return chatmessageList;
}

- (int)intWithUnreadMessageCountInRoom:(int)nRoomID
{
    int count = 0;
    
    sqlite3_stmt *stmt;
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ = %d AND %@ = %d AND %@ = %d",
                       TABLE_NAME_MESSAGE,
                       COL_NAME_ROOM_ID,
                       nRoomID,
                       COL_NAME_MSG_READSTATE,
                       0,
                       COL_NAME_MSG_OWNER,
                       UID];
    
    int ret = sqlite3_prepare(localDbHandler, [query UTF8String], -1, &stmt, nil);
    
    if(ret != SQLITE_OK)
        return 0;
    
    @try {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = (int)sqlite3_column_int(stmt, 0);
        }
        
        sqlite3_finalize(stmt);
    }
    @catch (NSException *exception) {
        
#ifdef DEMO_MODE
        NSLog(@"%@ 읽지 않은 메쎄지개수읽기오유 %@", LOGTAG, exception);
#endif
    }
    
    
    return count;
}

/*
 기능: 대화리력에서 대보내지 못한 대화들의 상태를 보낸 상태로 변경하는 함수
 */
- (void)allMessageStateToReadInRoom:(int)nRoomID
{
    NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ = %d AND %@ = %d",
                       TABLE_NAME_MESSAGE,
                       COL_NAME_MSG_READSTATE,
                       1,
                       COL_NAME_ROOM_ID,
                       nRoomID,
                       COL_NAME_MSG_OWNER,
                       UID];
    sqlite3_exec(localDbHandler, [query UTF8String], nil, nil, nil);
}

- (void)allMessageStateToSend
{
    NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ = %d",
                       TABLE_NAME_MESSAGE,
                       COL_NAME_MSG_SENDSTATE,
                       1,
                       COL_NAME_MSG_OWNER,
                       UID];
    
    @try {
        sqlite3_exec(localDbHandler, [query UTF8String], nil, nil, nil);
    }
    @catch (NSException *exception) {
#ifdef DEMO_MODE
        NSLog(@"%@ 메쎄지상태변경오유 %@", LOGTAG, exception);
#endif
    }
    
}
/*
 기능:대화방리력삭제함수
 */
- (void)removeAllMessagesInRoom:(int)nRoomID
{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %d AND %@ = %d",
                       TABLE_NAME_MESSAGE,
                       COL_NAME_ROOM_ID,
                       nRoomID,
                       COL_NAME_MSG_OWNER,
                       UID
                       ];
    sqlite3_exec(localDbHandler, [query UTF8String], nil, nil, nil);
}

- (NSString *)lastChattingTimeInRoom:(int)nRoomID
{
    sqlite3_stmt *stmt;
    NSString *query = [NSString stringWithFormat:@"select %@ from %@ where %@ = %d and %@ = %d order by %@ desc limit 0, 1",
                       COL_NAME_MSG_SEND_TIME,
                       TABLE_NAME_MESSAGE,
                       COL_NAME_ROOM_ID,
                       nRoomID,
                       COL_NAME_MSG_OWNER,
                       UID,
                       COL_NAME_MSG_SEND_TIME];
    
    int ret = sqlite3_prepare(localDbHandler, [query UTF8String], -1, &stmt, nil);
    if(ret != SQLITE_OK)
        return nil;
    
    NSString *lastTime = @"";
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        char *sendtime = (char *)sqlite3_column_text(stmt, 0);
        lastTime = [NSString stringWithUTF8String:sendtime];
    }
    sqlite3_finalize(stmt);

    return lastTime;
}

/*
 기능: 대화방에서 마지막채팅메쌔지와 채팅유저이름얻기
 */
- (NSString *)lastChattingLog:(int)nRoomID;
{
    sqlite3_stmt *stmt;
    NSString *query = [NSString stringWithFormat:@"select %@, %@, %@ from %@ where %@ = %d and %@ = %d order by %@ desc limit 0, 1",
                       COL_NAME_MSG_MESSAGE,
                       COL_NAME_MSG_SENDER_NAME,
                       COL_NAME_STATE,
                       TABLE_NAME_MESSAGE,
                       COL_NAME_ROOM_ID,
                       nRoomID,
                       COL_NAME_MSG_OWNER,
                       UID,
                       COL_NAME_MSG_SEND_TIME];
    
    int ret = sqlite3_prepare(localDbHandler, [query UTF8String], -1, &stmt, nil);
    if(ret != SQLITE_OK)
        return nil;
    
    NSString *lastChat = @"";
    NSString *lastMan = @"";
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        char *msg = (char *)sqlite3_column_text(stmt, 0);
        lastChat = [NSString stringWithUTF8String:msg];
        
        char *man = (char *)sqlite3_column_text(stmt, 1);
        lastMan = [NSString stringWithUTF8String:man];
        
        int type = (int)sqlite3_column_int(stmt, 2);
        
        if (type == 2)
            lastChat = LANGUAGE(@"image_mail");
        if (type == 3)
            lastChat = LANGUAGE(@"voice_mail");

    }
    sqlite3_finalize(stmt);
    
    if ([lastMan compare:@""] == NSOrderedSame && [lastChat compare:@""] == NSOrderedSame) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@ : %@", lastMan, lastChat];
}

/*
 기능: 전체 대화방에서 마지막으로 등록된 채팅시간을 얻는 함수
 */
- (NSString *)lastReceivedChattingTimeAllRoom
{
    sqlite3_stmt *stmt;
    
    if (UID == NSNotFound) return @"";
    NSString *query = [NSString stringWithFormat:@"select %@ from %@ where %@ = %d order by %@ desc limit 0, 1",
                       COL_NAME_MSG_SEND_TIME,
                       TABLE_NAME_RECEIVEMSGTIME,
                       COL_NAME_MSG_OWNER,
                       UID,
                       COL_NAME_MSG_SEND_TIME];
    
    int ret = sqlite3_prepare(localDbHandler, [query UTF8String], -1, &stmt, nil);
    if(ret != SQLITE_OK)
        return nil;
    
    NSString *lastTime = @"";
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        char *sendtime = (char *)sqlite3_column_text(stmt, 0);
        lastTime = [NSString stringWithUTF8String:sendtime];
    }
    sqlite3_finalize(stmt);
    
    return lastTime;
}

- (void)updateAudioMessagePath:(NSString *)filePath atIndex:(int)index
{
    NSString *query = [NSString stringWithFormat:@"update %@ set %@ = '%@' where %@ = %d",
                       TABLE_NAME_MESSAGE,
                       COL_NAME_MSG_MESSAGE,
                       filePath,
                       COL_NAME_MSG_PK,
                       index];
    char *error = NULL;
    sqlite3_exec(localDbHandler, [query UTF8String], nil, 0, &error);
}


@end
