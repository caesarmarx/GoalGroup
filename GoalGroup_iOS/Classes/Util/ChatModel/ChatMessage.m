#import "ChatMessage.h"
#import "ggaAppDelegate.h"
#import "Constants.h"
#import "Sqlite3Manager.h"

@implementation ChatMessage 

@synthesize msg;
@synthesize senderId;
@synthesize roomId;
@synthesize sendTime;
@synthesize senderName;
@synthesize type;
@synthesize thumbImageUrl;
@synthesize contentIcon;
@synthesize userPhoto, img_name;
@synthesize readState;
@synthesize sendState;

/*
 기능: 메쎄지를 자료기지에 보관하는 함수
 */
+ (int)addChatMessage:(ChatMessage *)chatmessage
{
    int r = [[Sqlite3Manager sharedInstance] addChattingMessage:chatmessage];
    return r;
}

+ (NSMutableArray *)getMessageByroomId:(int)roomId
{
    return [[NSMutableArray alloc] initWithArray:[[Sqlite3Manager sharedInstance] getMessageInRoom:roomId]];
}

+ (NSMutableArray *)getUnreadMessageByroomId:(int)roomId
{
    return [[NSMutableArray alloc] initWithArray:[[Sqlite3Manager sharedInstance] getUnreadMessageInRoom:roomId]];
}

+ (NSMutableArray *)getUnsendMessage
{
    return [[NSMutableArray alloc] initWithArray:[[Sqlite3Manager sharedInstance] getUnsendMessage]];
}



@end
