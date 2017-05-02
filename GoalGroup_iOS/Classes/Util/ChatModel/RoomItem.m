//
//  ChattingRoomItem.m
//  Chatting
//
//  Created by YunCholHo on 3/2/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import "RoomItem.h"
#import "ggaAppDelegate.h"
#import "Constants.h"

@implementation RoomItem

@synthesize roomId, roomName, sendTime, msg;

+ (NSMutableArray *) getRoomsList
{
/*    ggaAppDelegate *appDelegate = (ggaAppDelegate *)[[UIApplication sharedApplication] delegate];
    sqlite3 *dbHandler = appDelegate.localDbHandler;
    sqlite3_stmt *stmt;
    
    NSString *joinTable = [NSString stringWithFormat:@"Select r.%@, r.%@ From %@ r, %@ f Where r.%@ = f.%@ And f.%@ = %d",
                           COL_NAME_ROOM_ID, 
                           COL_NAME_ROOM_NAME,
                           TABLE_NAME_ROOM, 
                           TABLE_NAME_ROOM_REF,
                           COL_NAME_ROOM_ID, 
                           COL_NAME_REF_ROOM_ID, 
                           COL_NAME_REF_USER_ID, 
                           PARAM_USER_ID];
    
    NSString *where = [NSString stringWithFormat:@"(Select %@ From %@ Where %@ = m.%@ Order by %@ desc limit 1)",
                          COL_NAME_MSG_SEND_TIME,  
                          TABLE_NAME_MESSAGE,
                          COL_NAME_MSG_ROOM_ID, 
                          COL_NAME_MSG_ROOM_ID, 
                          COL_NAME_MSG_SEND_TIME];
    
    NSString *query = @"";
    
    query = [NSString stringWithFormat:@"Select m.%@, r_f.%@, m.%@, substr(m.%@, 1, 19) send_time\
                                           From %@ m\
                                                join (%@) r_f on m.%@ = r_f.%@\
                                                join %@ u on u.%@ = m.%@\
                                          Where m.%@ = %@\
                                          Order by m.%@ desc",
             COL_NAME_MSG_ROOM_ID, 
             COL_NAME_ROOM_NAME, 
             COL_NAME_MSG_MESSAGE, 
             COL_NAME_MSG_SEND_TIME,
             TABLE_NAME_MESSAGE,
             joinTable,
             COL_NAME_MSG_ROOM_ID,  
             COL_NAME_ROOM_ID,
             TABLE_NAME_USER,  
             COL_NAME_USER_ID, 
             COL_NAME_MSG_SENDER_ID, 
             COL_NAME_MSG_SEND_TIME, 
             where,
             COL_NAME_MSG_SEND_TIME];
    
    
    int ret = sqlite3_prepare(dbHandler, [query UTF8String], -1, &stmt, nil);
    if(ret != SQLITE_OK)
        return nil;
    
    NSMutableArray *roomsList = [[NSMutableArray alloc] init];
    
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        int roomId = (int)sqlite3_column_int(stmt, 0);
        char *roomName = (char *)sqlite3_column_text(stmt, 1);
        char *msg = (char *)sqlite3_column_text(stmt, 2);
        char *sendTime = (char *)sqlite3_column_text(stmt, 3);
        
        RoomItem *item = [[RoomItem alloc] init];
        item.roomId = roomId;
        item.roomName = [NSString stringWithUTF8String:roomName];
        item.msg = [NSString stringWithUTF8String:msg];
        item.sendTime = [NSString stringWithUTF8String:sendTime];
        
        [roomsList addObject:item];
    }
    
    sqlite3_finalize(stmt);
    */
        NSMutableArray *roomsList = [[NSMutableArray alloc] init];
    return roomsList;
}

@end
