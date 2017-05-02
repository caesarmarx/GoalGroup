//
//  Common.m
//
//  Created by JinYongHao on 9/25/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import "Common.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation Common

+ (void)DialPhoneNumber:(NSString *)dialNum
{
    NSString *strPhoneNum = [NSString stringWithFormat:@"telprompt://%@", dialNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strPhoneNum]];
}

+ (void)BackToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

+ (NSString *)appNameAndVersionNumberDisplayString
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}

+ (NSString*)EmojiFilterFrom:(NSString*)text
{
    NSString *result = [NSString stringWithString:text];
    for (int i=0; i<ARR_EMOJI.count; i++)
    {
        NSString *ascii = [[ARR_EMOJI objectAtIndex:i] objectAtIndex:0];
        NSString *omEmoji = [[ARR_EMOJI objectAtIndex:i] objectAtIndex:1];
        result = [result stringByReplacingOccurrencesOfString:ascii withString:omEmoji];
    }
    return result;
}

+ (NSString*)EmojiFilterTo:(NSString*)text
{
    NSString *result = [NSString stringWithString:text];
    for (int i=0; i<ARR_EMOJI.count; i++)
    {
        NSString *ascii = [[ARR_EMOJI objectAtIndex:i] objectAtIndex:0];
        NSString *omEmoji = [[ARR_EMOJI objectAtIndex:i] objectAtIndex:1];
        result = [result stringByReplacingOccurrencesOfString:omEmoji withString:ascii];
    }
    return result;
}

@end
