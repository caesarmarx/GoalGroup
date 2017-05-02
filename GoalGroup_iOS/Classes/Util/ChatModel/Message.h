//
//  ItemDialogContent.h
//  DialogRommProject
//
//  Created by YunCholHo on 5/31/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject{
    NSString *messageContent;
    NSString *messageSentTime;
    NSString *senderName;
}
//@property (nonatomic, retain) UIImageView *dialogImage;
@property (nonatomic, retain) NSString *messageContent;
@property (nonatomic, retain) NSString *messageSentTime;
@property (nonatomic, retain) NSString *senderName;
-(NSMutableArray *)getMessageList;
-(BOOL)insertMessage:(NSInteger *)sender_id msg:(NSString *)msg room_id:(NSInteger *) room_id;
@end
