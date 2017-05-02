#import "Chat.h"
#import "NSString+Utils.h"
#import "ChatMessage.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "Constants.h"
#import "Common.h"
#import "DiscussRoomManager.h"
#import "DateManager.h"

static Chat * sharedInstance;

@implementation Chat

@synthesize username;
@synthesize socketIO;

+ (id) sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (id) init
{
    if(chatRooms == Nil)
        chatRooms = [[NSMutableDictionary alloc] init];
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    [socketIO connectToHost:SERVER_IP_ADDRESS onPort:PORT];

    return self;
}

- (void)closeConnection
{
    if (socketIO != nil)
        [socketIO disconnect];
    socketIO = nil;
    sharedInstance = nil;
}

- (BOOL) chatEnable
{
    return socketIO.isConnected;
}

- (void)tryConnection
{
    if (socketIO == nil)
        socketIO = [[SocketIO alloc] initWithDelegate:self];
    [socketIO connectToHost:SERVER_IP_ADDRESS onPort:PORT];
}

- (void) setVerifyCodeDelegate:(id)delegate
{
    self.delegate = delegate;
}

/*
 기능: 본문채팅메쎄지를 처리하는 함수
 자기가 보낸 채팅은 아무 처리하지 않는다.
 상의마당만들기채팅, 상의마당갱신채팅은 채팅리력에 보관하지 않는다.
 채팅방에 있지 않거나 채팅방아이디가 아른 경우 카스텀노티히케션을 현시한다.
 */
- (void) receiveMessage:(NSMutableArray *)message
{
    NSDictionary *dict = [message objectAtIndex:0];
    
    ChatMessage *newMessage = [[ChatMessage alloc] init];
    newMessage.type = 1;
    NSString *chatmsg = [dict objectForKey:@"msg"];
    newMessage.msg = [Common EmojiFilterTo:chatmsg];
    newMessage.roomId = [[dict objectForKey:@"room_id"] intValue];
    newMessage.senderId = [[dict objectForKey:@"sender_id"] intValue];
    
    NSDate *tempDate = [NSDate date];
    newMessage.sendTime = curSystemTimeStr;
    newMessage.senderName = [dict objectForKey:@"sender_name"];
    newMessage.userPhoto = [dict objectForKey:@"sender_photo"];
    newMessage.readState = newMessage.senderId == UID? 1 : 0;
    newMessage.sendState = 1;
    
    if (newMessage.senderId == UID)
        return;
    
    //상의마당만들기 통신
    if ([chatmsg hasPrefix:@"create new discuss room"] || [chatmsg hasPrefix:@"Create new discuss room"])
    {
        NSArray *tmpArray = [chatmsg componentsSeparatedByString:@","];
        int nRoomID = [[[tmpArray objectAtIndex:1] substringFromIndex:8] intValue];
        NSString *roomName = [[tmpArray objectAtIndex:2] substringFromIndex:11];
        
        [[DiscussRoomManager sharedInstance] addDiscussChatRoom:nRoomID roomTitles:roomName];
        return;
    }
    
    //상의마당갱신통신
    if ([chatmsg hasPrefix:@"update discuss room"] || [chatmsg hasPrefix:@"Update discuss room"])
    {
        NSArray *tmpArray = [chatmsg componentsSeparatedByString:@","];
        int nRoomID = [[[tmpArray objectAtIndex:1] substringFromIndex:8] intValue];
        NSString *roomName = [[tmpArray objectAtIndex:2] substringFromIndex:11];
        
        [[DiscussRoomManager sharedInstance] addDiscussChatRoom:nRoomID roomTitles:roomName];
        return;
    }
    
    if ([[ClubManager sharedInstance] intClubIDWithRoomID:newMessage.roomId] == -1 && ![[DiscussRoomManager sharedInstance] checkWithRoomID:newMessage.roomId])
        return;

    
    [self.delegate addChattingMessageToVCWithMessage:newMessage recordIdx:0];
    
    //채팅방이 아니거나 채팅방아이디가 다른 경우
    if ([self nowNoChattingInRoom:newMessage.roomId])
        [[NotificationManager sharedInstance] notify:newMessage.msg who:newMessage.senderName type:newMessage.type];
    else
        newMessage.readState = 1;
    
    [ChatMessage addChatMessage:newMessage];
}

/*
 기능: 화상메세지를 처리하는 함수
 */
- (void) receivePhotoMessage:(NSMutableArray *)photomessage
{
    NSDictionary *dict = [photomessage objectAtIndex:0];
    
    ChatMessage *imageMessage = [ChatMessage new];
    imageMessage.type = 2;
    imageMessage.msg = [dict objectForKey:@"image_name"];
    imageMessage.roomId = [[dict objectForKey:@"room_id"] intValue];
    imageMessage.senderId = [[dict objectForKey:@"sender_id"] intValue];

    NSDate *tempDate = [NSDate date];
    imageMessage.sendTime = curSystemTimeStr;
    imageMessage.senderName = [dict objectForKey:@"sender_name"];
    imageMessage.userPhoto = [dict objectForKey:@"sender_photo"];
    imageMessage.readState = imageMessage.senderId == UID? 1 : 0;
    imageMessage.sendState = 1;
    
    if ([[ClubManager sharedInstance] intClubIDWithRoomID:imageMessage.roomId] == -1 && ![[DiscussRoomManager sharedInstance] checkWithRoomID:imageMessage.roomId])
        return;
    
    if (imageMessage.senderId == UID)
        return;
    
    [self.delegate addChattingMessageToVCWithMessage:imageMessage recordIdx:0];
    
    if ([self nowNoChattingInRoom:imageMessage.roomId])
        [[NotificationManager sharedInstance] notify:imageMessage.msg who:imageMessage.senderName type:imageMessage.type];
    else
        imageMessage.readState = 1;

    [ChatMessage addChatMessage:imageMessage];
}

/*
 기능: 음성메세지를 처리하는 함수
 */
- (void) receiveAudioMessage:(NSMutableArray *)audiomessage
{
    NSDictionary *dict = [audiomessage objectAtIndex:0];
    
    ChatMessage *audioMessage = [ChatMessage new];
    audioMessage.type = 3;
    audioMessage.msg = [dict objectForKey:@"audio_name"];
    audioMessage.roomId = [[dict objectForKey:@"room_id"] intValue];
    audioMessage.senderId = [[dict objectForKey:@"sender_id"] intValue];

    NSDate *tempDate = [NSDate date];
    audioMessage.sendTime = curSystemTimeStr;
    audioMessage.senderName = [dict objectForKey:@"sender_name"];
    audioMessage.userPhoto = [dict objectForKey:@"sender_photo"];
    audioMessage.readState = audioMessage.senderId == UID? 1 : 0;
    audioMessage.sendState = 1;
    
    if ([[ClubManager sharedInstance] intClubIDWithRoomID:audioMessage.roomId] == -1 && ![[DiscussRoomManager sharedInstance] checkWithRoomID:audioMessage.roomId])
        return;
    
    if (audioMessage.senderId == UID)
        return;
    
    if ([self nowNoChattingInRoom:audioMessage.roomId])
        [[NotificationManager sharedInstance] notify:audioMessage.msg who:audioMessage.senderName type:audioMessage.type];
    else
        audioMessage.readState = 1;

    int recordIdx =[ChatMessage addChatMessage:audioMessage];
    [self.delegate addChattingMessageToVCWithMessage:audioMessage recordIdx:recordIdx];
    
    [[HttpManager newInstance] downloadVoiceMail:self.delegate filePath:audioMessage.msg recordIdx:recordIdx];
    
    [ChatMessage addChatMessage:audioMessage]; //Added By Boss.2015/06/06
}

/*
 기능: 메쎄지를 접수하는 함수
 */
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSDictionary *json = [packet dataAsJSON];
    
    NSString *eventName = [json objectForKey:@"name"];
    NSMutableArray *args = [[json objectForKey:@"args"] mutableCopy];
    if([eventName isEqualToString:@"updatechat"])
        [self receiveMessage:args];
    else if([eventName isEqualToString:@"update_img_chat"])
        [self receivePhotoMessage:args];
    else if([eventName isEqualToString:@"update_audio_chat"])
        [self receiveAudioMessage:args];
    
    if ([eventName isEqualToString:@"updatechat"] ||
        [eventName isEqualToString:@"update_img_chat"] ||
        [eventName isEqualToString:@"update_audio_chat"])
    {
        int room = [[[args objectAtIndex:0] objectForKey:@"room_id"] intValue];
        [[ggaAppDelegate sharedInstance] refreshCountView:room];
    }
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
}


- (void) sendEvent:(NSString *)eventName withData:(NSDictionary *)data {
    [socketIO sendEvent:eventName withData:data];
}

- (void) sendEvent:(NSString *)eventName withData:(NSDictionary *)data andAcknowledge:(SocketIOCallback)function {
    [socketIO sendEvent:eventName withData:data andAcknowledge:function];
}

- (void) sendMessage:(NSString *)data {
    [socketIO sendMessage:data];
}

- (void) sendMessage:(NSString *)data withAcknowledge:(SocketIOCallback)function {
    [socketIO sendMessage:data withAcknowledge:function];
}

- (void) sendJSON:(NSDictionary *)data {
    [socketIO sendJSON:data];
}

- (void) sendJSON:(NSDictionary *)data withAcknowledge:(SocketIOCallback)function {
    [socketIO sendJSON:data withAcknowledge:function];
}

/*
 기능: 메쎄지를 소케트에 보내는 함수
 */
- (void)sendChatMessage:(ChatMessage *)message withDelegate:(id<ChatDelegate>)delegate
{
    self.delegate = delegate;
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[NSNumber numberWithInt: message.roomId]   forKey: @"room_id"];
    [dict setObject:[NSNumber numberWithInt: message.senderId] forKey: @"sender_id"];
    [dict setObject:message.userPhoto forKey:@"sender_photo"];
    [dict setObject:message.senderName forKey:@"sender_name"];
    if(message.type == 1)
    {
        [dict setObject:message.msg forKey: @"msg"];
        [socketIO sendEvent:@"sendchat" withData:dict];
    }
    else
    {
        [dict setObject:message.msg forKey: @"server_path"];
        NSArray *components = [message.msg componentsSeparatedByString:@"/"];
        NSString *msgString = [components objectAtIndex:(components.count - 1)];
        [dict setObject:msgString forKey: @"msg"];
        if (message.type == 2)
            [socketIO sendEvent:@"send_img_chat" withData:dict];
        else if (message.type == 3)
            [socketIO sendEvent:@"send_audio_chat" withData:dict];
    }
}



+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

- (BOOL)nowNoChattingInRoom:(int)room
{
    return (!bIsChatting || (bIsChatting && nCurChattingRoom != room));
}

@end
