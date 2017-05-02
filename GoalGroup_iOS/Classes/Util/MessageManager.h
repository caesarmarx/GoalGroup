//
//  MessageManager.h
//  iOM
//
//  Created by JinYongHao on 8/8/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    MessageTypeNone = 0,
    MessageTypeText,
    MessageTypeImage,
    MessageTypeVoice
} MessageType;


@interface MessageManager : NSObject

+ (MessageType)GetMessageType:(NSString *)message;
+ (NSString *)GetFromPhoneNumber:(NSString *)message;
+ (NSString *)GetToPhoneNumber:(NSString *)message;
+ (NSString *)BuildTextMessage:(NSString *)fromPN toPN:(NSString *)toPN text:(NSString *)text;
+ (NSString *)ParseTextMessage:(NSString *)text;
+ (NSString *)BuildImageMessage:(NSString *)fromPN toPN:(NSString *)toPN;
+ (NSString *)ParseImageMessage:(NSString *)text;
+ (NSString *)BuildVoiceMessage:(NSString *)fromPN toPN:(NSString *)toPN;
+ (NSString *)ParseVoiceMessage:(NSString *)text;
+ (NSString *)MessageWithLimit:(NSString *)message limit:(NSInteger)limit;
+ (NSInteger)GetDateTime:(NSString *)message;
+ (NSString *)DateTime;

@end
