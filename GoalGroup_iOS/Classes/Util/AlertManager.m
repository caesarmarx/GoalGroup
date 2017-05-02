//
//  AlertManager.m
//
//  Created by KCHN on 3/5/15.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import "AlertManager.h"
#import "Common.h"

@implementation AlertManager

+ (void)AlertWithMessage:(NSString *)message
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:LANGUAGE(@"title")
                                                 message:message
                                                delegate:self
                                       cancelButtonTitle:LANGUAGE(@"ok")
                                       otherButtonTitles:nil
                       ];
    [av show];
}

+ (void)AlertWithMessage:(NSString *)message tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:LANGUAGE(@"title")
                                                 message:message
                                                delegate:delegate
                                       cancelButtonTitle:LANGUAGE(@"ok")
                                       otherButtonTitles:nil
                       ];
    av.tag = tag;
    [av show];
}


+ (void)ConfirmWithDelegate:(id)delegate message:(NSString *)message cancelTitle:(NSString *)cancelTitle okTitle:(NSString *)okTitle tag:(int)tag
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:LANGUAGE(@"title")
                                                 message:message
                                                delegate:delegate
                                       cancelButtonTitle:cancelTitle
                                       otherButtonTitles:okTitle, nil
                       ];
    av.tag = tag;
    [av show];
}

+ (void)ConfirmWithDelegate:(id)delegate message:(NSString *)message
{
    [AlertManager ConfirmWithDelegate:delegate message:message cancelTitle:LANGUAGE(@"cancel") okTitle:LANGUAGE(@"ok") tag:0];
}

+ (GCDiscreetNotificationView *)DiscreetNotificationWithView:(UIView *)view message:(NSString *)message
{
    GCDiscreetNotificationView *nv = [[GCDiscreetNotificationView alloc] initWithText:message
                                                                         showActivity:YES
                                                                   inPresentationMode:GCDiscreetNotificationViewPresentationModeTop
                                                                               inView:view
                                      ];
    [nv show:YES];
    return nv;
}

+ (void)WaitingWithMessage
{
    [AlertManager WaitingWithMessage:LANGUAGE(@"working...")];
}

+ (void)WaitingWithMessage:(NSString *)message
{
    if (!gWaitingAlertView)
    {
        gWaitingAlertView = [[UIAlertView alloc] initWithTitle:LANGUAGE(@"title")
                                                       message:message
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:nil
                             ];
    }
    [gWaitingAlertView show];
/*    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(gWaitingAlertView.bounds.size.width / 2, gWaitingAlertView.bounds.size.height - 50);
    [indicator startAnimating];
    [gWaitingAlertView addSubview:indicator];*/
}

+ (void)HideWaiting
{
    if (!gWaitingAlertView)
        return;
    [gWaitingAlertView dismissWithClickedButtonIndex:0 animated:YES];
}

+ (void)InputAlertWithDelegate:(id)delegate placeholder:(NSString *)placeholder
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:LANGUAGE(@"title")
                                                 message:@""
                                                delegate:delegate
                                       cancelButtonTitle:LANGUAGE(@"cancel")
                                       otherButtonTitles:LANGUAGE(@"ok"), nil
                       ];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *input = [av textFieldAtIndex:0];
    input.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    input.placeholder = placeholder;
    [av show];
}

@end
