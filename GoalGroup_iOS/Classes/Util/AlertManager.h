//
//  AlertManager.h
//
//  Created by KCHN on 3/5/15.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDiscreetNotificationView.h"



UIAlertView *gWaitingAlertView;



@interface AlertManager : NSObject

+ (void)AlertWithMessage:(NSString *)message;
+ (void)AlertWithMessage:(NSString *)message tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)ConfirmWithDelegate:(id)delegate message:(NSString *)message;
+ (void)ConfirmWithDelegate:(id)delegate message:(NSString *)message cancelTitle:(NSString *)cancelTitle okTitle:(NSString *)okTitle tag:(int)tag;
+ (GCDiscreetNotificationView *)DiscreetNotificationWithView:(UIView *)view message:(NSString *)message;
+ (void)WaitingWithMessage;
+ (void)WaitingWithMessage:(NSString *)message;
+ (void)InputAlertWithDelegate:(id)delegate placeholder:(NSString *)placeholder;
+ (void)HideWaiting;

@end
