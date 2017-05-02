//
//  ChattingRoomItem.h
//  Chatting
//
//  Created by YunCholHo on 3/2/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomItem : NSObject
//{
//
//    int roomId;
//    NSString *roomName;
//    NSString *chatContent;
//    NSString *date;
//    
//    
//}

@property int roomId;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) NSString *sendTime;

+ (NSMutableArray *) getRoomsList; 



@end
