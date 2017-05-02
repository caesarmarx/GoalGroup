//
//  ProcessRemoteNotification.h
//  GoalGroup
//
//  Created by JinYongHao on 2015. 5. 28..
//  Copyright (c) 2015년 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@interface ProcessRemoteNotification : NSObject
{
    NSDictionary *remoteInfo;
    NSDictionary *senderInfo;
    ggaAppDelegate *appDelegate;
}

- (void)initWithDelegate;
- (void)setRemoteNotification:(NSDictionary *)remoteInfoParam;
- (int)getNotificationType;

- (void) gotoChat;
- (void) gotoInvitation;
- (void) gotoTempInvitation;
- (void) gotoRegisterRequest;
- (void) gotoSchedule;
- (void) gotoDeleteChallenge;
- (void) gotoSetGameResult;
- (void) gotoDismissClub;
- (void) gotoCreateChatRoom;
- (void) gotoNewsAlarm;
@end
