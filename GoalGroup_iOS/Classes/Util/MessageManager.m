//
//  MessageManager.m
//  iOM
//
//  Created by JinYongHao on 8/8/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "MessageManager.h"
#import "OMTelCommon.h"

@implementation MessageManager

+ (MessageType)GetMessageType:(NSString *)message
{
    NSRange range;
    range = [message rangeOfString:MESSAGE_TYPE_TEXT];
    if (range.length > 0)
        return MessageTypeText;
    range = [message rangeOfString:MESSAGE_TYPE_IMAGE];
    if (range.length > 0)
        return MessageTypeImage;
    range = [message rangeOfString:MESSAGE_TYPE_VOICE];
    if (range.length > 0)
        return MessageTypeVoice;
    return MessageTypeNone;
}

+ (NSString *)GetFromPhoneNumber:(NSString *)message
{
    NSArray *messageItems = [message componentsSeparatedByString:@"_"];
    return [messageItems objectAtIndex:2];
}

+ (NSString *)GetToPhoneNumber:(NSString *)message
{
    NSArray *messageItems = [message componentsSeparatedByString:@"_"];
    return [messageItems objectAtIndex:3];
}

+ (NSString *)BuildTextMessage:(NSString *)fromPN toPN:(NSString *)toPN text:(NSString *)text
{
    return [NSString stringWithFormat:@"%@%@_%@_%@_text_start_%@", MESSAGE_TYPE_TEXT, fromPN, toPN, [MessageManager DateTime], text, nil];
}

+ (NSString *)ParseTextMessage:(NSString *)text
{
    NSRange range = [text rangeOfString:@"_text_start_"];
    return [text substringFromIndex:(range.location + range.length)];
}

+ (NSString *)BuildImageMessage:(NSString *)fromPN toPN:(NSString *)toPN
{
    return [NSString stringWithFormat:@"%@%@_%@_%@", MESSAGE_TYPE_IMAGE, fromPN, toPN, [MessageManager DateTime], nil];
}

+ (NSString *)ParseImageMessage:(NSString *)text
{
    return [text stringByAppendingString:@".bci"];
}

+ (NSString *)BuildVoiceMessage:(NSString *)fromPN toPN:(NSString *)toPN
{
    return [NSString stringWithFormat:@"%@%@_%@_%@", MESSAGE_TYPE_VOICE, fromPN, toPN, [MessageManager DateTime], nil];
}

+ (NSString *)ParseVoiceMessage:(NSString *)text
{
    return [text stringByAppendingString:@".bcv"];
}

+ (NSString *)MessageWithLimit:(NSString *)message limit:(NSInteger)limit
{
    if (message.length > limit - 1)
        return [NSString stringWithFormat:@"%@...", [message substringToIndex:limit]];
    else
        return message;
}

+ (NSInteger)GetDateTime:(NSString *)message
{
    NSArray *messageItems = [message componentsSeparatedByString:@"_"];
    NSString *dateString = [messageItems objectAtIndex:4];
    NSString *timeString = [messageItems objectAtIndex:5];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMdd HHmmss"];
    NSDate *date = [df dateFromString:[NSString stringWithFormat:@"%@ %@", dateString, timeString]];
    return [date timeIntervalSince1970];
}

+ (NSString *)DateTime
{
    NSDate *now = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [df setDateFormat:@"yyyyMMdd_HHmmss"];
    return [df stringFromDate:now];
}

@end
