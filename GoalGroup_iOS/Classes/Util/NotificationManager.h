//
//  NotificationManager.h
//  OMTelephone
//
//  Created by JinYongHao on 8/22/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPNotificationView.h"

@protocol INotificationManagerDelegate

-(void)tapNotificaionMessage:(NSString *)fromPN;
-(void)notificationWillShow:(NSString *)message;

@end



@interface NotificationManager : NSObject

+ (NotificationManager *)sharedInstance;
- (void)notify:(NSString *)message who:(NSString *)man type:(int)type;

@property(nonatomic, retain)id<INotificationManagerDelegate> delegate;

@end

NotificationManager *gNotificationManager;