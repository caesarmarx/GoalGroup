//
//  ClubSettingsController.m
//  GoalGroup
//
//  Created by KCHN on 2/12/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubSettingsController.h"
#import "ReportController.h"
#import "Common.h"
#import "Sqlite3Manager.h"

@interface ClubSettingsController ()
{
    int settingState;
}
@end

@implementation ClubSettingsController

+ (ClubSettingsController *) sharedInstance
{
    @synchronized(self)
    {
        if (gClubSettingsController == nil)
            gClubSettingsController = [[ClubSettingsController alloc] initWithStyle:UITableViewStyleGrouped];
    }
    return gClubSettingsController;
}

- (id)initWithRoomID:(int)roomID clubID:(int)clubID
{
    self = [super init];
    nRoomID = roomID;
    nClubID = clubID;
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        titles10 = [NSArray arrayWithObjects:LANGUAGE(@"ClubSettingController_title_1"), LANGUAGE(@"ClubSettingController_title_2"), LANGUAGE(@"ClubSettingController_title_3"), LANGUAGE(@"ClubSettingController_title_4"), LANGUAGE(@"ClubSettingController_title_5"), LANGUAGE(@"ClubSettingController_title_6"), LANGUAGE(@"ClubSettingController_title_7"), LANGUAGE(@"ClubSettingController_title_8"), LANGUAGE(@"lbl_setting_report_save"), nil];
        
        
        switch1 = [[TTFadeSwitch alloc] init];
        switch2 = [[TTFadeSwitch alloc] init];
        switch3 = [[TTFadeSwitch alloc] init];
        switch4 = [[TTFadeSwitch alloc] init];
        switch5 = [[TTFadeSwitch alloc] init];
        switch6 = [[TTFadeSwitch alloc] init];
        switch7 = [[TTFadeSwitch alloc] init];
        switch8 = [[TTFadeSwitch alloc] init];
        switches = [NSArray arrayWithObjects:switch1, switch2, switch3, switch4, switch5, switch6, switch7, switch8, nil];
        SWITCHTAG = 120;
        for (int i = 0; i < 8 ; i ++) {
            TTFadeSwitch *alarmSwitch = [switches objectAtIndex:i];
            alarmSwitch.frame = CGRectMake(SCREEN_WIDTH * 0.7f, 5.f, 70.f, 24.f);
            alarmSwitch.thumbImage = [UIImage imageNamed:@"switchToggle"];
            alarmSwitch.thumbHighlightImage = [UIImage imageNamed:@"switchToggleHigh"];
            alarmSwitch.trackMaskImage = [UIImage imageNamed:@"switchMask"];
            alarmSwitch.trackImageOn = [UIImage imageNamed:@"switchGreen"];
            alarmSwitch.trackImageOff = [UIImage imageNamed:@"switchRed"];
            alarmSwitch.onString = NSLocalizedString(@"ON", nil);
            alarmSwitch.offString = NSLocalizedString(@"OFF", nil);
            alarmSwitch.labelsEdgeInsets = (UIEdgeInsets){ 1.0, 10.0, 1.0, 10.0 };
            alarmSwitch.onLabel.textColor = [UIColor whiteColor];
            alarmSwitch.offLabel.textColor = [UIColor whiteColor];
            alarmSwitch.thumbInsetX = -3.0;
            alarmSwitch.thumbOffsetY = 0.0;
            alarmSwitch.on = YES;
            [alarmSwitch addTarget:self action:@selector(alarmSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            alarmSwitch.tag = SWITCHTAG + i;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    self.title = LANGUAGE(@"CLUB_ROOM_SETTING");
    
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    
    if (!ADMINOFCLUB(nClubID))
        switch8.userInteractionEnabled = NO;
    else
        switch8.userInteractionEnabled = YES;
}
- (void)viewWillAppear:(BOOL)animated
{
}
- (void)viewDidAppear:(BOOL)animated
{
    NSNumber *number = [NSNumber numberWithInt:nClubID];
    [[HttpManager sharedInstance] getClubSettingWithDelegate:self clubID:number];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return 5;
    else if (section == 2)
        return ADMINOFCLUB(nClubID)? 3 : 2;
    else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    int index = 0;
    switch (indexPath.section)
    {
        case 0:
            index = indexPath.row;
            break;
        case 1:
            index = indexPath.row + 1;
            break;
        case 2:
            index = indexPath.row + 6;
            break;
        default:
            break;
    }
    
    NSString *t = [titles10 objectAtIndex:index];
    
    if (index > 5 && !ADMINOFCLUB(nClubID))
    {
        int n = index + 1;
        t = [titles10 objectAtIndex:n];
    }
    cell.textLabel.text = t;
    

    if (index > 0 && index < 7)
    {
        index ++;
        TTFadeSwitch *alarmSwitch = [switches objectAtIndex:index];
        
        if (index < 7)
            [cell addSubview:alarmSwitch];
        else
        {
            if (ADMINOFCLUB(nClubID))
                [cell addSubview:alarmSwitch];
        }
    }
    
    if (index == 0)
    {
        TTFadeSwitch *alarmSwitch = [switches objectAtIndex:0];
        [cell addSubview:alarmSwitch];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            if (!ADMINOFCLUB(nClubID))
                [AlertManager ConfirmWithDelegate:self message:LANGUAGE(@"Do you really want to delete message history?")];
        }
        if (indexPath.row == 1)
        {
            if (!ADMINOFCLUB(nClubID))
            {
                ggaAppDelegate *appDelegate = APP_DELEGATE;
                [appDelegate.ggaNav pushViewController:[[ReportController alloc] initWithTitle:LANGUAGE(@"lbl_setting_report_save")] animated:YES];
            }
            else
            [AlertManager ConfirmWithDelegate:self message:LANGUAGE(@"Do you really want to delete message history?")];
        }
        else if (indexPath.row == 2)
        {
            ggaAppDelegate *appDelegate = APP_DELEGATE;
            [appDelegate.ggaNav pushViewController:[[ReportController alloc] initWithTitle:LANGUAGE(@"lbl_setting_report_save")] animated:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(0.f, 0.f)];
}

#pragma Events
- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

#pragma Events
- (void)alarmSwitchChanged:(TTFadeSwitch *)sender
{
    int tag = sender.tag - 120;
    
    if (tag == 0)
    {
        if (sender.isOn)
            settingState = (settingState | (int)pow(2, tag)) - (int)pow(2, tag);
        else
            settingState |= (int)pow(2, tag);
    }
    else
    {
        if (!sender.isOn)
            settingState = (settingState | (int)pow(2, tag)) - (int)pow(2, tag);
        else
            settingState |= (int)pow(2, tag);
    }
    
    [self savePressed:sender];
}

#pragma HttpManagerDelegate
- (void)getClubSettingResultWithErrorCode:(int)errorcode state:(int)state
{
    TTFadeSwitch *sw = [switches objectAtIndex:0];
    sw.on = (state & 0x01) ? NO : YES;
    for (int i = 1; i < 8; i++)
    {
        sw = [switches objectAtIndex:i];
        sw.on = ((state >> i) & 0x01) ? YES : NO;
    }
    settingState = state;
}



#pragma HttpManagerDelegate
- (void)setClubSettingResultWithErrorCode:(int)errorcode
{
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    //else
        //[AlertManager AlertWithMessage:LANGUAGE(@"success")];
}



#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[Sqlite3Manager sharedInstance] removeAllMessagesInRoom:nRoomID];
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
        [[NSUserDefaults standardUserDefaults] setObject:@"del_success" forKey:@"CHATLOG_DELETE"];
    }
}

#pragma UserDefinded
- (void)savePressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:settingState] forKey:@"CLUBSETTING_STATUS"];
    [[HttpManager sharedInstance] setClubSettingWithDelegate:self];
}

@end
