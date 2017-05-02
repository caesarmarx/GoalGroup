//
//  SettingsViewController.m
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "SettingsViewController.h"
#import "PlayerDetailController.h"
#import "AppDetailController.h"
#import "ReportController.h"
#import "Common.h"
#import "Chat.h"

#import <ShareSDK/ShareSDK.h>
@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = LANGUAGE(@"general_menu_third");
        
        inviteClubAlarmSwitch= [[TTFadeSwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 0.7f, 10.f, 70.f, 24.f)];
        inviteClubAlarmSwitch.thumbImage = [UIImage imageNamed:@"switchToggle"];
        inviteClubAlarmSwitch.thumbHighlightImage = [UIImage imageNamed:@"switchToggleHigh"];
        inviteClubAlarmSwitch.trackMaskImage = [UIImage imageNamed:@"switchMask"];
        inviteClubAlarmSwitch.trackImageOn = [UIImage imageNamed:@"switchGreen"];
        inviteClubAlarmSwitch.trackImageOff = [UIImage imageNamed:@"switchRed"];
        inviteClubAlarmSwitch.onString = NSLocalizedString(@"ON", nil);
        inviteClubAlarmSwitch.offString = NSLocalizedString(@"OFF", nil);
        inviteClubAlarmSwitch.labelsEdgeInsets = (UIEdgeInsets){ 1.0, 10.0, 1.0, 10.0 };
        inviteClubAlarmSwitch.onLabel.textColor = [UIColor whiteColor];
        inviteClubAlarmSwitch.offLabel.textColor = [UIColor whiteColor];
        inviteClubAlarmSwitch.thumbInsetX = -3.0;
        inviteClubAlarmSwitch.thumbOffsetY = 0.0;
        [inviteClubAlarmSwitch addTarget:self action:@selector(inviteAlarmChanged) forControlEvents:UIControlEventValueChanged];
        
        adminPageAlarmSiwtch= [[TTFadeSwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 0.7f, 10.f, 70.f, 24.f)];
        adminPageAlarmSiwtch.thumbImage = [UIImage imageNamed:@"switchToggle"];
        adminPageAlarmSiwtch.thumbHighlightImage = [UIImage imageNamed:@"switchToggleHigh"];
        adminPageAlarmSiwtch.trackMaskImage = [UIImage imageNamed:@"switchMask"];
        adminPageAlarmSiwtch.trackImageOn = [UIImage imageNamed:@"switchGreen"];
        adminPageAlarmSiwtch.trackImageOff = [UIImage imageNamed:@"switchRed"];
        adminPageAlarmSiwtch.onString = NSLocalizedString(@"ON", nil);
        adminPageAlarmSiwtch.offString = NSLocalizedString(@"OFF", nil);
        adminPageAlarmSiwtch.labelsEdgeInsets = (UIEdgeInsets){ 1.0, 10.0, 1.0, 10.0 };
        adminPageAlarmSiwtch.onLabel.textColor = [UIColor whiteColor];
        adminPageAlarmSiwtch.offLabel.textColor = [UIColor whiteColor];
        adminPageAlarmSiwtch.thumbInsetX = -3.0;
        adminPageAlarmSiwtch.thumbOffsetY = 0.0;
        [adminPageAlarmSiwtch addTarget:self action:@selector(adminAlarmChanged) forControlEvents:UIControlEventValueChanged];
        
        switchs = [NSArray arrayWithObjects:inviteClubAlarmSwitch, adminPageAlarmSiwtch, nil];
        
        labels1 = [NSArray arrayWithObjects:LANGUAGE(@"PlayerDetailController Title"), nil];
        labels2 = [NSArray arrayWithObjects:LANGUAGE(@"ALLOW_CLUB_INVITATION"), LANGUAGE(@"ClubSettingController_title_6"), nil];
        labels3 = [NSArray arrayWithObjects:LANGUAGE(@"SETTING_VIEW_LABEL_1"), nil];
        labels4 = [NSArray arrayWithObjects:LANGUAGE(@"SETTING_VIEW_LABEL_2"), nil];
        labels5 = [NSArray arrayWithObjects:LANGUAGE(@"SUGGEST"), LANGUAGE(@"app_info"), nil];
        labels6 = [NSArray arrayWithObjects:LANGUAGE(@"logout"), nil];
        
        UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
        [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

        [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
        [backButtonRegion addSubview:backButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    }
    return self;
}

- (void)backToPage
{
    ggaAppDelegate *app = APP_DELEGATE;
    [app.ggaNav popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    inviteClubAlarmSwitch.on = ((OPTIONS >> 2) & 0x01) ? YES : NO;
    adminPageAlarmSiwtch.on = ((OPTIONS >> 4) & 0x01) ? YES : NO;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return 2;
    else if (section == 2)
        return 1;
    else if (section == 3)
        return 1;
    else if (section == 4)
        return 2;
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.f;
        
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];;
    cell.backgroundColor = [UIColor ggaThemeGrayColor];
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = [labels1 objectAtIndex:indexPath.row];
            break;
        case 1:
            [cell addSubview:[switchs objectAtIndex:indexPath.row]];
            cell.textLabel.text = [labels2 objectAtIndex:indexPath.row];
            break;
        case 2:
            cell.textLabel.text = [labels3 objectAtIndex:indexPath.row];
            break;
        case 3:
            cell.textLabel.text = [labels4 objectAtIndex:indexPath.row];
            break;
        case 4:
            cell.textLabel.text = [labels5 objectAtIndex:indexPath.row];
            break;
        case 5:
            cell.textLabel.text = [labels6 objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    switch (indexPath.section)
    {
        case 0:
            [appDelegate.ggaNav pushViewController:[[PlayerDetailController alloc] initWithPlayerID:UID showInviteButton:NO] animated:YES];
            break;
        case 1:
            break;
        case 2:
            [self shareSNSClicked];
            break;
        case 3:
            [AlertManager ConfirmWithDelegate:self message:LANGUAGE(@"Do you really want to remove cache?") cancelTitle:LANGUAGE(@"cancel") okTitle:LANGUAGE(@"ok") tag:101];
            break;
        case 4:
            if (indexPath.row == 0)
                [appDelegate.ggaNav pushViewController:[[ReportController alloc] initWithTitle:LANGUAGE(@"SUGGEST")] animated:YES];
            if (indexPath.row == 1)
                [appDelegate.ggaNav pushViewController:[AppDetailController sharedInstance] animated:YES];
            break;
        case 5:
            [self showAlertViewWithLogoutQuery];
            break;
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(0.f, 0.f)];
}


#pragma HttpManagerDelegate
- (void)userLogoutResultWithErroCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
    {
        self.navigationController.navigationBarHidden = YES;
        UID = NSNotFound;
        ggaAppDelegate *appDelegate = APP_DELEGATE;
        [appDelegate.ggaNav popToRootViewControllerAnimated:YES];

        [[ClubManager sharedInstance] clearClubs];
        
        NSString *filePath = [FileManager GetLoginFilePath];
        [FileManager DeleteFile:filePath];
        
        [[Chat sharedInstance] closeConnection];
    }
}

#pragma HttpManagerDelegate
- (void)setUserOptionResultWithErrorCode:(int)errorcode
{
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
}



#pragma UserDefined
- (void)shareSNSClicked
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK" ofType:@"jpg"];
    
    //1、构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:LANGUAGE(@"SETTING_VIEW_LABEL_11")
                                       defaultContent:LANGUAGE(@"SETTING_VIEW_LABEL_12")
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:LANGUAGE(@"FOOTBALL_CITY")
                                                  url:@"http://www.baidu.com"
                                          description:LANGUAGE(@"SETTING_VIEW_LABEL_13")
                                            mediaType:SSPublishContentMediaTypeNews];
    //2、弹出分享菜单
    id<ISSContainer> container = [ShareSDK container];
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                //可以根据回调提示用户。
                                if (state == SSResponseStateSuccess)
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LANGUAGE(@"REASON_STATE_SUCCESS")
                                                                                    message:nil
                                                                                   delegate:self
                                                                          cancelButtonTitle:LANGUAGE(@"ok")
                                                                          otherButtonTitles:nil, nil];
                                    [alert show];
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LANGUAGE(@"REASON_STATE_FAIL")
                                                                                    message:[NSString stringWithFormat:@"%@：%@",LANGUAGE(@"REASON_STATE_FAIL_DESCRIBE"),[error errorDescription]]
                                                                                   delegate:self
                                                                          cancelButtonTitle:LANGUAGE(@"ok")
                                                                          otherButtonTitles:nil, nil];
                                    [alert show];
                                }
                            }];
}

- (void)inviteAlarmChanged
{
    OPTIONS = OPTIONS & 0xF3;
    OPTIONS = inviteClubAlarmSwitch.isOn? (OPTIONS | 0x04): (OPTIONS | 0x08);
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:OPTIONS] forKey:@"USER_OPTION"];
    [[HttpManager sharedInstance] setUserOptionWithDelegate:self];
}

- (void)adminAlarmChanged
{
    OPTIONS = OPTIONS & 0xCF;
    OPTIONS = adminPageAlarmSiwtch.isOn? (OPTIONS | 0x10): (OPTIONS | 0x20);
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:OPTIONS] forKey:@"USER_OPTION"];
    [[HttpManager sharedInstance] setUserOptionWithDelegate:self];
}

- (void)showAlertViewWithLogoutQuery
{
    [AlertManager ConfirmWithDelegate:self message:LANGUAGE(@"logout_verify")];
}



#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101)
    {
        if (buttonIndex == 1)
        {
            [FileManager RemoveAllProgramData];
            [AlertManager AlertWithMessage:LANGUAGE(@"success")];
        }
    }
    else
    {
        if (buttonIndex == 1)
        {
            [AlertManager WaitingWithMessage];
            [[HttpManager sharedInstance] userLogoutWithDelegate:self];
        }
    }
}
@end
