//
//  NotificationManager.m
//  OMTelephone
//
//  Created by JinYongHao on 8/22/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//
#import "Common.h"
#import "NotificationManager.h"
//#import "MessageManager.h"
//#import "EmojiView.h"
//#import "OMTelCommon.h"
//#import "AddressManager.h"
//#import "MessageSoundEffect.h"

@implementation NotificationManager

+ (NotificationManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gNotificationManager == nil)
            gNotificationManager = [[NotificationManager alloc] init];
    }
    return gNotificationManager;
}

-(void)notify:(NSString *)message who:(NSString *)man type:(int)type
{
    NSString *notificationMessage = message;
    switch (type)
    {
        case MESSAGE_TYPE_TEXT:
            [MPNotificationView notifyWithText:LANGUAGE(@"title")
                                        detail:notificationMessage
                                         image:IMAGE(@"man_default")
                                      duration:3.0
                                 andTouchBlock:nil];

            break;
        case MESSAGE_TYPE_IMAGE:
            [MPNotificationView notifyWithText:LANGUAGE(@"title")
                                        detail:[NSString stringWithFormat:LANGUAGE(@"ImageMessage from"), man]
                                         image:IMAGE(@"man_default")
                                      duration:3.0
                                 andTouchBlock:nil];
            break;
        case MESSAGE_TYPE_AUDIO:
            [MPNotificationView notifyWithText:LANGUAGE(@"title")
                                        detail:[NSString stringWithFormat:LANGUAGE(@"VoiceMessage from"), man]
                                         image:IMAGE(@"man_default")
                                      duration:3.0
                                 andTouchBlock:nil];
            break;
        default:
            break;
    }
//    [self.delegate notificationWillShow:message];
//    AudioServicesPlaySystemSound(1007);


}
@end
