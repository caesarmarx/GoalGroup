//
//  ProcessRemoteNotification.m
//  GoalGroup
//
//  Created by JinYongHao on 2015. 5. 28..
//  Copyright (c) 2015년 KCHN. All rights reserved.
//

#import "ProcessRemoteNotification.h"

#import "ClubRoomViewController.h"
#import "DemandLetterController.h"
#import "TempInvitionLetterController.h"
#import "JoiningBookController.h"
#import "GameScheduleController.h"
#import "ConferenceController.h"

@implementation ProcessRemoteNotification

-(void)initWithDelegate
{
    appDelegate = APP_DELEGATE;
}

- (void)setRemoteNotification:(NSDictionary *)remoteInfoParam
{
    remoteInfo = remoteInfoParam;
    if (remoteInfo != nil) {
        senderInfo = [remoteInfo objectForKey:@"sender"];
    }
}

- (int)getNotificationType
{
    if (remoteInfo == nil || remoteInfo.count == 0) {
        return 0;
    }
    
    NSInteger nMsgType = [[remoteInfo objectForKey:@"msg_type"] integerValue];
    
    return (int)nMsgType;
}

- (void) gotoChat
{
    int nClubID = 0;
    int nRoomID = 0;
    
    nRoomID = (int)[[senderInfo objectForKey:@"roomID"] integerValue];
    
    if (nRoomID > 0) {
        nClubID = [[ClubManager sharedInstance] intClubIDWithRoomID:nRoomID];
    } else {
        nClubID = (int)[[senderInfo objectForKey:@"clubID"] integerValue];
    }
    
    ggaAppDelegate *AppDelegate = APP_DELEGATE;
    
    if (AppDelegate.ggaNav == nil) {
        NSLog(@"AppDelegate's NavigationController is Empty");
        return;
    }
    
    if (nClubID > 0) {
        [appDelegate.ggaNav pushViewController:[[ClubRoomViewController alloc] initWithNibName:@"ClubRoomViewController" clubID:nClubID bundle:nil] animated:YES];
    } else {
        NSLog(@"GotoChat:RemoteNotification is from unknown club");
    }
}

- (void) gotoInvitation
{
    
#ifdef DEMO_MODE
    [FileManager WriteErrorData:[NSString stringWithFormat:@"%@, 초청장알람접수처리\r\n", LOGTAG]];
#endif
    
    DemandLetterController *vc = [[DemandLetterController alloc] init];
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

- (void) gotoTempInvitation
{
    TempInvitionLetterController *vc = [[TempInvitionLetterController alloc] init];
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

- (void) gotoRegisterRequest
{
#ifdef DEMO_MODE
    [FileManager WriteErrorData:[NSString stringWithFormat:@"%@, 가맹신청알람접수처리\r\n", LOGTAG]];
    NSLog(@"%@, 가맹신청알람접수처리", LOGTAG);
#endif
    
    int nClubID = 0;
    nClubID = (int)[[senderInfo objectForKey:@"clubID"] integerValue];

#ifdef DEMO_MODE
    [FileManager WriteErrorData:[NSString stringWithFormat:@"%@, 구락부아이디 = %d\r\n", LOGTAG, nClubID]];
    NSLog(@"%@, 구락부아이디 = %d", LOGTAG, nClubID);
#endif

    if (nClubID == 0) {
        NSLog(@"GotoRegisterRequest:RemoteNotification is from unknown club");
        return;
    }
    
    if (![[ClubManager sharedInstance] checkAdminClub:nClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    JoiningBookController *vc = [[JoiningBookController alloc] initWithClubID:nClubID];
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

- (void) gotoSchedule
{
    int nClubID = 0;
    nClubID = (int)[[senderInfo objectForKey:@"clubID"] integerValue];
    
    if (nClubID == 0) {
        NSLog(@"GotoSchedule:RemoteNotification is from unknown club");
        return;
    }
    
    GameScheduleController *vc = [GameScheduleController sharedInstance];
    [vc selectMode:NO withClubID:nClubID];
    
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

- (void) gotoDeleteChallenge
{
    //    [appDelegate.ggaNav popToRootViewControllerAnimated:YES];
    [appDelegate.ggaNav popToViewController:appDelegate.ggaNav.childViewControllers[1] animated:YES];
    [appDelegate.tabBC setSelectedIndex:0];
    //[appDelegate.tabBC resignFirstResponder];
}

- (void) gotoSetGameResult
{
    [self gotoSchedule];
    
    //[appDelegate.tabBC setSelectedIndex:2];
    //[appDelegate.tabBC resignFirstResponder];
}

- (void) gotoDismissClub
{

    //[appDelegate.ggaNav popToRootViewControllerAnimated:YES];
    [appDelegate.ggaNav popToViewController:appDelegate.ggaNav.childViewControllers[1] animated:YES];
    [appDelegate.tabBC setSelectedIndex:2];
    //[appDelegate.tabBC resignFirstResponder];
}

- (void) gotoCreateChatRoom
{
    [appDelegate.tabBC setSelectedIndex:2];
    [appDelegate.tabBC resignFirstResponder];
}

-(void) gotoNewsAlarm
{
    [appDelegate.ggaNav pushViewController:[ConferenceController sharedInstance] animated:YES];
}

@end
