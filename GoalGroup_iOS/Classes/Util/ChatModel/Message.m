//
//  ItemDialogContent.m
//  DialogRommProject
//
//  Created by YunCholHo on 5/31/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "Message.h"
#import "ggaAppDelegate.h"
#import "Constants.h"

@implementation Message
@synthesize messageContent, messageSentTime, senderName;


-(NSMutableArray *)getMessageList{
    
//    ggaAppDelegate *appDelegate = (ggaAppDelegate *)[[UIApplication sharedApplication] delegate];
//    sqlite3 *dbHandler = appDelegate.localDbHandler;
//    sqlite3_stmt *stmt;
//    
//    NSString *query = @"";
//    NSString *queryPart1 = @"";
//    NSString *queryPart2 = @"";
//    NSString *queryPart3 = @"";
//    
//    
//    queryPart1 =[NSString stringWithFormat:@"select %@.%@, %@.%@, %@.%@ %@, substr(%@.%@,1,19) %@ from %@",
//                 TABLE_NAME_R_F,COL_NAME_ROOM_NAME,TABLE_NAME_MESSAGE,COL_NAME_MSG_MESSAGE,TABLE_NAME_USER,COL_NAME_USER_NAME,COL_NAME_SENDER_NAME,TABLE_NAME_MESSAGE,COL_NAME_MSG_SEND_TIME,COL_NAME_MSG_SEND_TIME,TABLE_NAME_MESSAGE];
//    queryPart2 =[NSString stringWithFormat:@" join (select %@.%@, %@.%@ from %@, %@ where %@.%@=%@.%@ and %@.%@=1 and %@.%@=1) %@",
//                 TABLE_NAME_ROOM,COL_NAME_ROOM_ID,TABLE_NAME_ROOM,COL_NAME_ROOM_NAME,TABLE_NAME_ROOM,TABLE_NAME_ROOM_REF,TABLE_NAME_ROOM,COL_NAME_ROOM_ID,TABLE_NAME_ROOM_REF,COL_NAME_ROOM_ID,TABLE_NAME_ROOM_REF,COL_NAME_REF_USER_ID,TABLE_NAME_ROOM,COL_NAME_ROOM_ID,TABLE_NAME_R_F];
//    queryPart3 =[NSString stringWithFormat:@" on %@.%@=%@.%@ join %@ on %@.%@=%@.%@ order By %@.%@ ",
//                 TABLE_NAME_MESSAGE,COL_NAME_MSG_ROOM_ID,TABLE_NAME_R_F,COL_NAME_REF_ROOM_ID,TABLE_NAME_USER,TABLE_NAME_USER,COL_NAME_USER_ID,TABLE_NAME_MESSAGE,COL_NAME_MSG_SENDER_ID,TABLE_NAME_MESSAGE,COL_NAME_MSG_SEND_TIME];
//    query=[NSString stringWithFormat:@"%@ %@ %@",queryPart1,queryPart2,queryPart3];
//    
//    int ret = sqlite3_prepare(dbHandler, [query UTF8String], -1, &stmt, nil);
//    if(ret != SQLITE_OK)
//        return nil;
//    
//    NSMutableArray *sql_messageList = [[NSMutableArray alloc] init];
//    
//    while (sqlite3_step(stmt) == SQLITE_ROW)
//    {
//        char *sql_msg = (char *)sqlite3_column_text(stmt, 1);
//        char *sql_sender_name = (char *)sqlite3_column_text(stmt, 2);
//        char *sql_send_time = (char *)sqlite3_column_text(stmt, 3);
//        
//        Message *item = [[Message alloc] init];
//        item.messageContent =[NSString stringWithUTF8String:sql_msg];
//        item.messageSentTime=[NSString stringWithUTF8String:sql_send_time];
//        item.senderName=[NSString stringWithUTF8String:sql_sender_name];
//        
//        [sql_messageList addObject:item];
//    }
//    
//    sqlite3_finalize(stmt);
//    
//    return sql_messageList;
    return nil;
    
}

-(BOOL)insertMessage:(NSInteger *)sender_id msg:(NSString *)msg room_id:(NSInteger *) room_id
{
//    ggaAppDelegate *appDelegate = (ggaAppDelegate *)[[UIApplication sharedApplication] delegate];
//    sqlite3 *dbHandler = appDelegate.localDbHandler;
//    
//    NSString *query = @"";
//    
//    query = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@) values (%d,'%@',%d,%@)",
//             TABLE_NAME_MESSAGE,
//             COL_NAME_MSG_SENDER_ID,
//             COL_NAME_MSG_MESSAGE,
//             COL_NAME_MSG_ROOM_ID,
//             COL_NAME_MSG_SEND_TIME,
//             sender_id,
//             msg,
//             room_id,
//             PARAM_SEND_TIME];
//    
//    BOOL ret = sqlite3_exec(dbHandler, [query UTF8String], nil, nil, nil) == SQLITE_OK;
//    return ret;
    return YES;
}


@end
