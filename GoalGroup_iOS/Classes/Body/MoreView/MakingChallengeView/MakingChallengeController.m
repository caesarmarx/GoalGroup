//
//  MakingChallengeController.m
//  GoalGroup
//
//  Created by KCHN on 2/8/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "MakingChallengeController.h"
#import "WeekSelectController.h"
#import "ZoneSelectController.h"
#import "StadiumSelectController.h"
#import "ExpenseSelectController.h"
#import "PlayerCountSelectController.h"
#import "RefereeSelectController.h"
#import "TeamSelectController.h"
#import "DiscussRoomManager.h"
#import "DistrictManager.h"
#import "DateManager.h"
#import "NSString+Utils.h"
#import "Common.h"
#import "ChatMessage.h"
#import "Chat.h"

@interface MakingChallengeController ()
{
    NSArray *titles;
    BOOL keyboardVisible;
    BOOL sendGame;
}
@end

@implementation MakingChallengeController

//도전창조
- (id)initWithChallengeTeam
{
    _creatingMode = CREATINGMODE_CREATING;
    _challengeMode = CHALLENGEMODE_DIRECT_CHALLEGNE;
    sendGame = YES;
    return [self init];
}

//포고창조
- (id)initWithNoticeTeam:(int)team name:(NSString *)name
{
    _creatingMode = CREATINGMODE_CREATING;
    _challengeMode = CHALLENGEMODE_DIRECT_NOTICE;

    _inviteTeamID = team;
    _inviteTeam = name;
    _inviteNameText.text = name;
    sendGame = YES;
    return [self init];
}

//전문가경기창조
- (id)initWithGameEditMode:(int)team
{
    _creatingMode = CREATINGMODE_CREATING;
    _challengeMode = CHALLENGEMODE_GAME_EDITING;
    
    _challengeTeamID = team;
    sendGame = YES;
    return [self init];
}

//경기편집
- (id)initWithGameEditModeInExisting:(ChallengeListRecord *)record withType:(int)type room:(int)roomID gameID:(int)gameID gameType:(int)gameType sendGame:(BOOL)sendgame
{
    _creatingMode = CREATINGMODE_EDITING;
    _challengeMode = type;
    _nRoomID = roomID;
    
    _gameID = gameID;
    _nGameType = gameType;
    sendGame = sendgame;
    
    return [self init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        titles = [NSArray arrayWithObjects:LANGUAGE(@"general_menu_first"), LANGUAGE(@"RESEARCH NOTICE"), LANGUAGE(@"club_custom_game"), nil];
        [self layoutComponents];
        
        if (_creatingMode == CREATINGMODE_EDITING)
        {
            [AlertManager WaitingWithMessage];
            [[HttpManager sharedInstance] getGameDetailWithDelegate:self data:[NSArray arrayWithObjects:[NSNumber numberWithInt:_gameID],
                                                                               [NSNumber numberWithInt:_nGameType], nil]];
            return self;
            
        }
        
        if (_challengeMode == CHALLENGEMODE_GAME_EDITING)
        {
            _challengeNameText.text = [[ClubManager sharedInstance] stringClubNameWithID:_challengeTeamID];
        }
        else
        {
            _challengeTeam = [[ADMINCLUBS objectAtIndex:0] valueForKey:@"club_name"];
            _challengeNameText.text = _challengeTeam;
            _challengeTeamID = [[[ADMINCLUBS objectAtIndex:0] valueForKey:@"club_id"] intValue];
        }
        
        _inviteNameText.text = _inviteTeam;

        _challengeDate = [DateManager StringDateWithFormat:@"YYYY-MM-dd" date:[NSDate date]];
        _dateText.text = _challengeDate;
        
        _challengeTime = [DateManager StringDateWithFormat:@"HH:mm" date:[NSDate date]];
        _timeText.text = _challengeTime;
        
        _refNeccText.text = LANGUAGE(@"no");
        
        _expenseText.text = LANGUAGE(@"MAIN TEAM GIVE");
        _expenseMode = 0;
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"STADIUM_ZONE"];
    }
    return self;
}

- (void)getGameDetailResultWithErrorCode:(int)errorcode data:(ChallengeListRecord *)record
{
    if (errorcode == 0)
    {
        [AlertManager HideWaiting];
        
        _challengeTeam = [record stringWithSendClubName];
        _inviteTeam = [record stringWithRecvClubName];
        _challengeDate = [record stringWithPlayDate];
        _challengeTime = [record stringWithPlayTime];
        _stadiumAddr = [record stringWithPlayStadiumAddress];
        _members = [[record stringWithPlayers] intValue];
        _gameID = [record intWithGameID];
        _challengeTeamID = [record intWithSendClubID];
        _inviteTeamID = [record intWithRecvClubID];

        if (_challengeMode == CHALLENGEMODE_GAME_EDITING)
        {
            _challengeNameText.text = [[ClubManager sharedInstance] stringClubNameWithID:_challengeTeamID];
        }
        
        _inviteNameText.text = _inviteTeam;
        _challengeNameText.text = _challengeTeam;
        _dateText.text = _challengeDate;
        _timeText.text = _challengeTime;
        _refNeccText.text = LANGUAGE(@"no");
        _expenseText.text = LANGUAGE(@"MAIN TEAM GIVE");
        _expenseMode = 0;
        _membersText.text = [NSString stringWithFormat:@"%d人制", _members];
        _stadiumArea = [record stringWithPlayStadiumArea];
        _stadiumAreaText.text = _stadiumArea;
        _stadiumAddrText.text = [record stringWithPlayStadiumAddress];
        
        [[NSUserDefaults standardUserDefaults] setObject:_stadiumArea forKey:@"STADIUM_ZONE"];
        
        [self refreshHeight:_stadiumAddrText];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor ggaGrayBackColor];
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    _stadiumArea = [[NSUserDefaults standardUserDefaults] objectForKey:@"STADIUM_ZONE"];
    _stadiumAreaText.text = _stadiumArea;
    
    if ([_stadiumArea compare:@""] == NSOrderedSame ||
        _stadiumArea == nil ||
        [_stadiumArea compare:LANGUAGE(@"none")] == NSOrderedSame)
        _stadiumAreaText.text = LANGUAGE(@"none");
    
    keyboardVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) layoutComponents
{
    if (_creatingMode == CREATINGMODE_CREATING)
        self.title = [titles objectAtIndex:_challengeMode];
    else
        self.title = LANGUAGE(@"MakingChallengeController title");
    
    self.view.backgroundColor = [UIColor ggaGrayBackColor];
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    UIImageView *arrowImage;
    UITapGestureRecognizer *singleFinterTap;
    
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage:) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    
    UIView *faqiButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 35)];
    UIButton *faqiButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 25, 20)]; //Added By KYR.2015/05/08
    [faqiButton setImage:[UIImage imageNamed:@"btn_new_chall"] forState:UIControlStateNormal];
    [faqiButton addTarget:self action:@selector(challengeButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    UIButton *lblButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 25, 15)];
    [lblButton setTitle:LANGUAGE(@"lbl_make_challenge_save") forState:UIControlStateNormal];
    lblButton.titleLabel.textColor = [UIColor whiteColor];
    lblButton.titleLabel.font = FONT(12.f);
    [lblButton addTarget:self action:@selector(challengeButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    [faqiButtonRegion addSubview:faqiButton];
    [faqiButtonRegion addSubview:lblButton];
    self.navigationItem.rightBarButtonItem = sendGame? [[UIBarButtonItem alloc] initWithCustomView:faqiButtonRegion] : nil;
    
    if (IOS_VERSION >= 7.0)
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height - 70)];
    else
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height)];
    
    scrollView.backgroundColor = [UIColor ggaGrayBackColor];
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 450);
    [self.view addSubview:scrollView];
    
    NSUInteger gapHeight = 10;
    NSUInteger conHeight = 30;
    NSUInteger height = gapHeight * 2;
    NSUInteger labelWidth = 80;
    NSUInteger gapWidth = 10;
    NSUInteger secondStart = 10 + labelWidth + gapWidth;
    NSUInteger iconSize = conHeight;
    NSUInteger secondWidth = SCREEN_WIDTH - secondStart - 30 - iconSize;
    NSUInteger padding = 15;
    NSUInteger iconHeight = conHeight * 2 / 3;
    //Club name

    UIView *itemView = [[UIImageView alloc] init];
    itemView.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight) * 2);
    itemView.backgroundColor = [UIColor ggaThemeGrayColor];
    itemView.layer.cornerRadius = 8;
    itemView.layer.masksToBounds = YES;
    [scrollView addSubview:itemView];
    NSUInteger itemHeight = (conHeight + gapHeight) * 2;
    LBorderView *dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2, itemView.frame.size.width - 30, 0.3f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [itemView addSubview:dotView];

    height += 5;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH - 20, conHeight)];
    [scrollView addSubview:backView];

    _challengeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, height, labelWidth, conHeight)];
    [_challengeNameLabel setFont:FONT(14.f)];
    [_challengeNameLabel setTextAlignment:NSTextAlignmentRight];
    _challengeNameLabel.text = [NSString stringWithFormat:@"%@ :",LANGUAGE(@"sendteam")];
    [scrollView addSubview:_challengeNameLabel];
    
    _challengeNameText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart + 10, height, secondWidth, conHeight)];
    [_challengeNameText setFont:FONT(14.f)];
    [_challengeNameText setTextAlignment:NSTextAlignmentLeft];
    _challengeNameText.text = _challengeTeam;
    [scrollView addSubview:_challengeNameText];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(challengeTeamClick:)];
    [backView addGestureRecognizer:singleFinterTap];
    arrowImage = [[UIImageView alloc] initWithImage: IMAGE(@"new_chall_master")];
    
    arrowImage.frame = CGRectMake(secondStart + secondWidth + 10, gapHeight / 2, iconHeight, iconHeight);
    [backView addSubview:arrowImage];

    //Invite name
    height = height + conHeight + gapHeight;
    
//    backView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH - 20, conHeight)];
//    [scrollView addSubview:backView];
//    backView.backgroundColor = [UIColor redColor];
    
    UIView *inviteView = [[UIView alloc] initWithFrame:CGRectMake(20, height, SCREEN_WIDTH - 20, conHeight)];
    _inviteNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_inviteNameLabel setFont:FONT(14.f)];
    [_inviteNameLabel setTextAlignment:NSTextAlignmentRight];
    _inviteNameLabel.text =[NSString stringWithFormat:@"%@ :",LANGUAGE(@"OTHER")];
    [inviteView addSubview:_inviteNameLabel];
    
    _inviteNameText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart -10, 0, secondWidth, conHeight)];
    [_inviteNameText setFont:FONT(14.f)];
    [_inviteNameText setTextAlignment:NSTextAlignmentLeft];
    _inviteNameText.text = _inviteTeam;
    _inviteNameText.hidden = YES;
    [inviteView addSubview:_inviteNameText];
    
    _inviteNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(secondStart - 10, 0, secondWidth, conHeight)];
    _inviteNameTextField.delegate = self;
    _inviteNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _inviteNameTextField.keyboardType = UIKeyboardTypeDefault;
    _inviteNameTextField.font = FONT(14.f);
    _inviteNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    _inviteNameTextField.returnKeyType = UIReturnKeyDone;
    _inviteNameTextField.hidden = YES;
    if ([self.title compare:titles[2]] == NSOrderedSame && sendGame) {
        _inviteNameTextField.enabled = YES;
    } else {
        _inviteNameTextField.enabled = NO;
    }
    
    [inviteView addSubview:_inviteNameTextField];
    
    if (_challengeMode == CHALLENGEMODE_GAME_EDITING)
        _inviteNameTextField.hidden = NO;
    else
        _inviteNameText.hidden = NO;
    
    arrowImage = [[UIImageView alloc] initWithImage:IMAGE(@"new_chall_opp")];
    arrowImage.frame = CGRectMake(secondStart + secondWidth, gapHeight / 2, iconHeight, iconHeight);
    [inviteView addSubview:arrowImage];

    
    [scrollView addSubview:inviteView];
    
    
    height = height + conHeight + gapHeight + padding;
    
    itemView = [[UIImageView alloc] init];
    itemView.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight) * 2);
    itemView.backgroundColor = [UIColor ggaThemeGrayColor];
    itemView.layer.cornerRadius = 8;
    itemView.layer.masksToBounds = YES;
    [scrollView addSubview:itemView];
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2, itemView.frame.size.width - 30, 0.3f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [itemView addSubview:dotView];
    
    //Game Date
    height += 5;
    
    UIView *dateView = [[UIView alloc] initWithFrame:CGRectMake(20, height, SCREEN_WIDTH - 40, conHeight)];
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_dateLabel setFont:FONT(14.f)];
    [_dateLabel setTextAlignment:NSTextAlignmentRight];
    _dateLabel.text =[NSString stringWithFormat:@"%@ :",LANGUAGE(@"GAME WEATHER")];
    [dateView addSubview:_dateLabel];
    
    _dateText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart - 10, 0, secondWidth, conHeight)];
    [_dateText setFont:FONT(14.f)];
    [_dateText setTextAlignment:NSTextAlignmentLeft];
    _dateText.text  = _challengeDate;
    [dateView addSubview:_dateText];
    
    arrowImage = [[UIImageView alloc] initWithImage:IMAGE(@"new_chall_date")];
    arrowImage.frame = CGRectMake(secondStart + secondWidth, gapHeight / 2, iconHeight, iconHeight);
    [dateView addSubview:arrowImage];
    
    [scrollView addSubview:dateView];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(establishDayClicked:)];
    [dateView addGestureRecognizer:singleFinterTap];
    
    height = height + conHeight + gapHeight;
    
    //Game time
    UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(20, height, SCREEN_WIDTH - 40, conHeight)];
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_timeLabel setFont:FONT(14.f)];
    [_timeLabel setTextAlignment:NSTextAlignmentRight];
    _timeLabel.text =[NSString stringWithFormat:@"%@ :",LANGUAGE(@"GAME TIME")];
    [timeView addSubview:_timeLabel];
    
    _timeText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart - 10, 0, secondWidth, conHeight)];
    [_timeText setFont:FONT(14.f)];
    [_timeText setTextAlignment:NSTextAlignmentLeft];
    _timeText.text = _challengeTime;
    [timeView addSubview:_timeText];
    
    arrowImage = [[UIImageView alloc] initWithImage:IMAGE(@"new_chall_time")];
    arrowImage.frame = CGRectMake(secondStart + secondWidth, gapHeight / 2, iconHeight, iconHeight);
    [timeView addSubview:arrowImage];
    [scrollView addSubview:timeView];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(establishTimeClicked:)];
    [timeView addGestureRecognizer:singleFinterTap];
    
    height = height + conHeight + gapHeight + padding;
    
    itemView = [[UIImageView alloc] init];
    itemView.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight));
    itemView.backgroundColor = [UIColor ggaThemeGrayColor];
    itemView.layer.cornerRadius = 8;
    itemView.layer.masksToBounds = YES;
    [scrollView addSubview:itemView];

    //Game players
    height += 5;
    
    UIView *memberView = [[UIView alloc] initWithFrame:CGRectMake(20, height, SCREEN_WIDTH - 40, conHeight)];
    _membersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_membersLabel setFont:FONT(14.f)];
    [_membersLabel setTextAlignment:NSTextAlignmentRight];
    _membersLabel.text =[NSString stringWithFormat:@"%@ :",LANGUAGE(@"GAME NUMBER")];
    [memberView addSubview:_membersLabel];
    
    _membersText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart - 10, 0, secondWidth, conHeight)];
    [_membersText setFont:FONT(14.f)];
    [_membersText setTextAlignment:NSTextAlignmentLeft];
    _membersText.text= LANGUAGE(@"none");
    [memberView addSubview:_membersText];

    arrowImage = [[UIImageView alloc] initWithImage:IMAGE(@"new_chall_player_num")];
    arrowImage.frame = CGRectMake(secondStart + secondWidth, gapHeight / 2, iconHeight, iconHeight);
    [memberView addSubview:arrowImage];
    [scrollView addSubview:memberView];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(memberPress:)];
    [memberView addGestureRecognizer:singleFinterTap];

    height = height + conHeight + gapHeight + padding;
    
    itemView = [[UIImageView alloc] init];
    itemView.tag = 1010;
    itemView.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight) * 2);
    itemView.backgroundColor = [UIColor ggaThemeGrayColor];
    itemView.layer.cornerRadius = 8;
    itemView.layer.masksToBounds = YES;
    [scrollView addSubview:itemView];
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, conHeight + gapHeight, itemView.frame.size.width - 30, 0.3f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [itemView addSubview:dotView];

    //Game position
    height += 5;
    UIView *stadiumAreaView = [[UIView alloc] initWithFrame:CGRectMake(20, height, SCREEN_WIDTH - 40, conHeight)];
    
    _stadiumAreaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight )];
    [_stadiumAreaLabel setFont:FONT(14.f)];
    [_stadiumAreaLabel setTextAlignment:NSTextAlignmentRight];
    _stadiumAreaLabel.text = LANGUAGE(@"home zone");
    [stadiumAreaView addSubview:_stadiumAreaLabel];
    
    _stadiumAreaText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart -10, 0, secondWidth, conHeight )];
    [_stadiumAreaText setFont:FONT(14.f)];
    [_stadiumAreaText setTextAlignment:NSTextAlignmentLeft];
    _stadiumAreaText.text = LANGUAGE(@"none");
    [stadiumAreaView addSubview:_stadiumAreaText];

    arrowImage = [[UIImageView alloc] initWithImage:IMAGE(@"new_chall_stadium")];
    arrowImage.frame = CGRectMake(secondStart + secondWidth, gapHeight / 2, iconHeight, iconHeight);
    [stadiumAreaView addSubview:arrowImage];
    [scrollView addSubview:stadiumAreaView];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stadiumAreaPress:)];
    [stadiumAreaView addGestureRecognizer:singleFinterTap];
    
    height = height + conHeight + gapHeight;
    
    UIView *stadiumAddrView = [[UIView alloc] initWithFrame:CGRectMake(20, height, SCREEN_WIDTH - 40, conHeight)];
    stadiumAddrView.tag = 1011;
    
    _stadiumAddrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight )];
    [_stadiumAddrLabel setFont:FONT(14.f)];
    [_stadiumAddrLabel setTextAlignment:NSTextAlignmentRight];
    _stadiumAddrLabel.text = LANGUAGE(@"stadiumAddr");
    [stadiumAddrView addSubview:_stadiumAddrLabel];
    
    _stadiumAddrText = [[UITextView alloc] initWithFrame:CGRectMake(secondStart - 10, 0, secondWidth, conHeight)];
    _stadiumAddrText.tag = 1012;
    _stadiumAddrText.delegate = self;
    _stadiumAddrText.font = FONT(14.f);
    _stadiumAddrText.returnKeyType = UIReturnKeyDone;
    _stadiumAddrText.keyboardType = UIKeyboardTypeDefault;
    _stadiumAddrText.editable = sendGame;
    [stadiumAddrView addSubview:_stadiumAddrText];
    [scrollView addSubview:stadiumAddrView];

    //Refereering
    height += 5;
    UIView *refView = [[UIView alloc] initWithFrame:CGRectMake(20, height, SCREEN_WIDTH - 40, conHeight)];
    
    height = height + conHeight + gapHeight + padding;
    
    itemView = [[UIImageView alloc] init];
    itemView.tag = 1014;
    itemView.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight) );
    itemView.backgroundColor = [UIColor ggaThemeGrayColor];
    itemView.layer.cornerRadius = 8;
    itemView.layer.masksToBounds = YES;
    [scrollView addSubview:itemView];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refnecPress:)];
    [refView addGestureRecognizer:singleFinterTap];
    
    //Expense
    height += 5;
    UIView *expView = [[UIView alloc] initWithFrame:CGRectMake(20, height, SCREEN_WIDTH - 40, conHeight)];
    _expenseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_expenseLabel setFont:FONT(14.f)];
    [_expenseLabel setTextAlignment:NSTextAlignmentRight];
    expView.tag = 1015;
    _expenseLabel.text =[NSString stringWithFormat:@"%@ :",LANGUAGE(@"GROUND COST")];;
    [expView addSubview:_expenseLabel];
    
    _expenseText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart - 10, 0, secondWidth, conHeight)];
    [_expenseText setFont:FONT(14.f)];
    [_expenseText setTextAlignment:NSTextAlignmentLeft];
    
    [expView addSubview:_expenseText];
    
    arrowImage = [[UIImageView alloc] initWithImage:IMAGE(@"new_chall_money_split")];
    arrowImage.frame = CGRectMake(secondStart + secondWidth, gapHeight / 2, iconHeight, iconHeight);
    [expView addSubview:arrowImage];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expPress:)];
    [expView addGestureRecognizer:singleFinterTap];
    
    [scrollView addSubview:expView];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(padPress:)];
    [scrollView addGestureRecognizer:singleFinterTap];
    
    
    if (_challengeMode == CHALLENGEMODE_GAME_EDITING)
    {
        itemView.hidden = YES;
        expView.hidden = YES;
    }
    
    height = height + conHeight * 2 + gapHeight;
    
    _expenseMode = 0;
    sheetMode = 0;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma Events
- (void)backToPage:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"EXPENSE_MODE"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PLAYER_MODE"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"REFEREE_MODE"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STADIUM_ZONE"];

    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

#pragma Events
- (void)challengeButtonPressed
{
    [self.view endEditing:YES];
    [self cancelPressed];
    _stadiumAddr = _stadiumAddrText.text;
    
    if (_challengeNameText.text == nil || [_challengeNameText.text  isEqualToString: @""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"challenge_team_empty")];
        return;
    }
    
    if (_dateText.text == nil || [_dateText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"challenge_date_empty")];
        return;
    }
    
    if (_timeText.text == nil || [_timeText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"challenge_time_empty")];
        return;
    }
    
    NSString *toDateString = [[[_challengeDate stringByAppendingString:@" "] stringByAppendingString:_challengeTime] stringByAppendingString:@":00"];
    NSDate *toDate = [DateManager DateFromString:toDateString];
    NSDate *fromDate = [NSDate date];
    int diff = (int)[DateManager hoursDiffFromDate:fromDate toDate:toDate];
    if (diff < 4)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"timeselect invalid")];
        return;
    }


    if (_membersText.text == nil || [_membersText.text isEqualToString:LANGUAGE(@"none")])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"challenge_member_empty")];
        return;
    }

    if (_stadiumAreaText.text == nil || [_stadiumAreaText.text isEqualToString:@""] || [_stadiumAreaText.text compare:LANGUAGE(@"none")] == NSOrderedSame)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"challenge_stadium_empty")];
        return;
    }

    if (_stadiumAddr == nil || [_stadiumAddr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"challenge_stadiumaddr_empty")];
        return;
    }

    if (_challengeMode == CHALLENGEMODE_GAME_EDITING)
    {
        if (_inviteNameTextField.text == nil || [_inviteNameTextField.text isEqualToString:@""])
        {
            [AlertManager AlertWithMessage:LANGUAGE(@"challenge_invite_team_empty")];
            return;
        }
    }
    
    [AlertManager WaitingWithMessage];
    
    if (_challengeMode < CHALLENGEMODE_GAME_EDITING)
    {
        NSArray *data = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", _challengeTeamID],
                         [NSString stringWithFormat:@"%@", _challengeDate],
                         [NSString stringWithFormat:@"%@:%@", _challengeTime, @"00"],
                         [NSString stringWithFormat:@"%d", _members],
                         [NSString stringWithFormat:@"%d", [[DistrictManager sharedInstance] districtIntWithString:_stadiumArea ]],
                         [NSString stringWithFormat:@"%@", _stadiumAddr],
                         [NSString stringWithFormat:@"%d", _expenseMode],
                         [NSString stringWithFormat:@"%d", _inviteTeamID],
                         [NSString stringWithFormat:@"%d", _challengeMode],
                         [NSString stringWithFormat:@"%d", _creatingMode],
                         [NSString stringWithFormat:@"%d", _gameID],
                         nil];
        [[HttpManager sharedInstance] sendChallengeWithDelegate:self data:data];
    }
    else
    {
        //CreatingGame
        NSArray *data = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", _challengeTeamID],
                         [NSString stringWithFormat:@"%@", _challengeDate],
                         [NSString stringWithFormat:@"%@", _challengeTime],
                         [NSString stringWithFormat:@"%d", _members],
                         [NSString stringWithFormat:@"%d", [[DistrictManager sharedInstance] districtIntWithString:_stadiumArea ]],
                         [NSString stringWithFormat:@"%@", _stadiumAddr],
                         [NSString stringWithFormat:@"%d", _expenseMode],
                         [NSString stringWithFormat:@"%@", _inviteNameTextField.text],
                         nil];
        [[HttpManager sharedInstance] gameCreateWithDelegate:self data:data];
    }
}

- (void)challengeTeamClick:(UITapGestureRecognizer *)recognizer
{
    if (!sendGame)
        return;
    
    [self.view endEditing:YES];
    [self cancelPressed];
    
    if (_challengeMode < CHALLENGEMODE_GAME_EDITING && _creatingMode == CREATINGMODE_CREATING)
    {
        ggaAppDelegate *appDelegate = APP_DELEGATE;
        [appDelegate.ggaNav pushViewController:[[TeamSelectController alloc] initAdminMonoSelModeWithDelegate:self] animated:YES];
    }
}

#pragma Events
NSString *originalStr;
- (void)establishDayClicked:(UITapGestureRecognizer *)recognizer
{
    if (!sendGame)
        return;
    
    [self.view endEditing:YES];
    
    if (_datepicker != nil && _datepicker.datePickerMode == UIDatePickerModeDate) {
        _datepicker.datePickerMode = UIDatePickerModeTime;
        return;
    } else if (_datepicker != nil) {
        return;
    }
    
    _datepicker= [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 250)];
    _datepicker.datePickerMode = UIDatePickerModeDate;
    _datepicker.backgroundColor = [UIColor whiteColor];
    
    if (_challengeDate != nil && [_challengeDate compare:@""] != NSOrderedSame) {
        NSDateFormatter *outformat = [[NSDateFormatter alloc] init];
        [outformat setDateFormat:@"YYYY-MM-dd"];
        NSDate *date = [outformat dateFromString:_challengeDate];
        [_datepicker setDate:date];
    }
    
    _datepicker.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_datepicker];
    
    _toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35)];
    _toolbar.backgroundColor = [UIColor blackColor];
    _toolbar.barStyle = UIBarStyleBlackOpaque;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: LANGUAGE(@"DONE") style: UIBarButtonItemStyleBordered target: self action: @selector(HideDatePicker:)];
    [doneButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:@"kiloji---B" size:14.0f],UITextAttributeFont,nil] forState:UIControlStateNormal];
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: LANGUAGE(@"cancel") style: UIBarButtonItemStyleBordered target: self action: @selector(cancelPressed)];
    [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:@"kiloji---B" size:14.0f],UITextAttributeFont,nil] forState:UIControlStateNormal];
    _toolbar.items = [NSArray arrayWithObjects:cancelButton,flexibleSpace, doneButton, nil];
    [self.view addSubview: _toolbar];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _datepicker.frame = CGRectMake(0, SCREEN_HEIGHT - 250, SCREEN_WIDTH, 250);
                         _toolbar.frame = CGRectMake(0, SCREEN_HEIGHT - 255, SCREEN_WIDTH, 35);
                     } completion:^(BOOL finished) {
                     }];
}

- (void)establishTimeClicked:(UITapGestureRecognizer *)recognizer
{
    if (!sendGame)
        return;
    
    [self.view endEditing:YES];
    if (_datepicker != nil && _datepicker.datePickerMode == UIDatePickerModeTime) {
        _datepicker.datePickerMode = UIDatePickerModeDate;
        return;
    } else if (_datepicker != nil) {
        return;
    }
    
    _datepicker= [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 250)];
    _datepicker.datePickerMode = UIDatePickerModeTime;
    _datepicker.backgroundColor = [UIColor whiteColor];
    
    if (_challengeTime != nil && [_challengeTime compare:@""] != NSOrderedSame) {
        NSDateFormatter *outformat = [[NSDateFormatter alloc] init];
        [outformat setDateFormat:@"HH:mm"];
        NSDate *dateTime = [outformat dateFromString:_challengeTime];
        [_datepicker setDate:dateTime];
    }
    
    _datepicker.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_datepicker];
    
    _toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35)];
    _toolbar.backgroundColor = [UIColor blackColor];
    _toolbar.barStyle = UIBarStyleBlackOpaque;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:LANGUAGE(@"DONE") style: UIBarButtonItemStyleBordered target: self action: @selector(HideTimePicker:)];
    [doneButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:@"kiloji---B" size:14.0f],UITextAttributeFont,nil] forState:UIControlStateNormal];
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: LANGUAGE(@"cancel") style: UIBarButtonItemStyleBordered target: self action: @selector(cancelPressed)];
    [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:@"kiloji---B" size:14.0f],UITextAttributeFont,nil] forState:UIControlStateNormal];
    _toolbar.items = [NSArray arrayWithObjects:cancelButton,flexibleSpace, doneButton, nil];
    [self.view addSubview: _toolbar];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _datepicker.frame = CGRectMake(0, SCREEN_HEIGHT - 250, SCREEN_WIDTH, 250);
                         _toolbar.frame = CGRectMake(0, SCREEN_HEIGHT - 255, SCREEN_WIDTH, 35);
                     } completion:^(BOOL finished) {
                     }];
}

- (void)memberPress:(UITapGestureRecognizer *)recognizer
{
    if (!sendGame)
        return;
    
    [self closeAllInputPad];
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[PlayerCountSelectController alloc] initWithDelegate:self] animated:YES];
}

- (void)stadiumAreaPress:(UITapGestureRecognizer *)recognizer
{
    if (!sendGame)
        return;
    
    [self closeAllInputPad];
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [[NSUserDefaults standardUserDefaults] setObject:@"STADIUM_ZONE" forKey:@"ZONE_SELECT_FOR_WHAT"];
    [appDelegate.ggaNav pushViewController:[[ZoneSelectController alloc] initWithAllArea] animated:YES];
}

- (void)refnecPress:(UITapGestureRecognizer *)recognizer
{
    if (!sendGame)
        return;
    
    [self closeAllInputPad];
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[RefereeSelectController alloc] initWithDelegate:self] animated:YES];
}

- (void)expPress:(UITapGestureRecognizer *)recognizer
{
    if (!sendGame)
        return;
    
    [self closeAllInputPad];
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ExpenseSelectController alloc] initWithDelegate:self] animated:YES];
}

- (void)padPress:(UITapGestureRecognizer *)recognizer
{
    [self closeAllInputPad];
}

- (void)closeAllInputPad
{
    [self.view endEditing:YES];
    [self cancelPressed];
}

- (void)stepperClicked:(UIStepper *)stepper
{
    NSInteger value = (NSInteger)[stepper value];
    _membersText.text = [NSString stringWithFormat:@"%d", value];
}

#pragma ExpenseSelectControllerDelegate
- (void)expenseSelected:(int)mode
{
    NSString *temp = @"";
    switch (mode) {
        case 0:
            temp = LANGUAGE(@"MAIN TEAM GIVE");
            break;
        case 1:
            temp = LANGUAGE(@"OTHER TEAM GIVE");
            break;
        case 2:
            temp =[NSString stringWithFormat:@"AA%@",LANGUAGE(@"SYSTEM")];
            break;
        default:
            break;
    }
    _expenseText.text = temp;
    _expenseMode = mode;

}

#pragma PlayerCountSelectControllerDelegate
- (void)playerCountSelected:(int)count
{
    _membersText.text = [NSString stringWithFormat:@"%d%@", count + 5,LANGUAGE(@"player number")];
    _members = count + 5;
}

#pragma RefereeSelectControllerDelegate
- (void)refereeOptionSelected:(int)mode
{
    _refNeccText.text = mode?LANGUAGE(@"ok"):LANGUAGE(@"no");
    _refNecc = mode;
}

#pragma TeamSelectControllerDelegate
- (void)teamSelected:(int)teamid
{
    if (_challengeMode < CHALLENGEMODE_GAME_EDITING && _creatingMode == CREATINGMODE_CREATING)
    {
        _challengeNameText.text = [[ClubManager sharedInstance] stringClubNameWithID:teamid];
        _challengeTeamID = teamid;
    }
    
    if (_challengeMode == CHALLENGEMODE_GAME_EDITING)
    {
        _inviteTeam = [[ClubManager sharedInstance] stringClubNameWithID:teamid];
        _inviteTeamID = teamid;
    }
}

#pragma StadiumSelectControllerDelegate
- (void)selectedStadiumWithIndex:(int)index
{
    [Common BackToPage];
    _stadiumArea = [[STADIUMS objectAtIndex:index] objectForKey:@"stadium_name"];
    _stadium_id = [[[STADIUMS objectAtIndex:index] valueForKey:@"stadium_id"] intValue];
    _stadiumAreaText.text = _stadiumArea;
}

#pragma HttpManagerDelegate
- (void)sendChallengeResultWithErrorCode:(int)errorcode room:(int)roomID title:(NSString *)roomTitles
{
    [AlertManager HideWaiting];
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
    {
        NSString *subMsg = @"";
        
        if (_creatingMode == CREATINGMODE_CREATING)
        {
            switch (_challengeMode) {
                case CHALLENGEMODE_DIRECT_CHALLEGNE:
                    subMsg = LANGUAGE(@"challenge is created successfully");
                    break;
                case CHALLENGEMODE_DIRECT_NOTICE:
                    subMsg = LANGUAGE(@"notice is created successfully");
                    break;
                default:
                    subMsg = LANGUAGE(@"game is created successfully");
                    break;
            }
        }
        else
            subMsg = LANGUAGE(@"game is edited successfully");

        [AlertManager AlertWithMessage:subMsg tag:1001 delegate:self];
        
        if (_creatingMode == CREATINGMODE_EDITING)
        {
            DiscussRoomItem *room = [[DiscussRoomManager sharedInstance] discussRoomWithID:_nRoomID];
            [room setGameDate:[NSString stringWithFormat:@"%@ %@", _challengeDate, _challengeTime]];
            [room setGamePlayer:_members];
            
            NSString *msg = [NSString stringWithFormat:@"%d::%@::%d::%@::%d::%d::%@::%d::%@::%@::%d::%d", [room intWithSendClubID],
                             [room stringWithSendName],
                             [room intWithRecvClubID],
                             [room stringWithRecvName],
                             [room intWithGameType],
                             [room intWithGameID],
                             [NSString stringWithFormat:@"%@ %@", _challengeDate, _challengeTime],
                             _members,
                             [room stringWithSendImageUrl],
                             [room stringWithRecvImageUrl],
                             [room intWithChallState],
                             [room intWithGameState]];
            //[self sendMsgToUpdateDiscussRoom:_nRoomID msg:msg];
            
            return;
            
        }
        //if challenge
        if ([roomTitles isEqualToString:@""])
            return;
        [[DiscussRoomManager sharedInstance] addDiscussChatRoom:roomID roomTitles:roomTitles];
        
        //if notice, Send message "create new discuss room"
        //[self sendMsgToCreateNewDiscussRoom:roomID msg:roomTitles];

    }
}

#pragma HttpManagerDelegate
- (void)gameCreateResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"game is created successfully")];
}

- (NSString *)expenseStringWithInt:(int)n
{
    NSString *temp = @"";
    switch (n) {
        case 0:
            temp = LANGUAGE(@"MAIN TEAM GIVE");
            break;
        case 1:
            temp = LANGUAGE(@"OTHER TEAM GIVE");
            break;
        case 2:
            temp = [NSString stringWithFormat:@"AA%@",LANGUAGE(@"SYSTEM")];
            break;
        default:
            break;
    }
    return temp;
}

/*
#pragma textField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self cancelPressed];
    if (textField == _stadiumAddrText) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        CGRect viewFrame = scrollView.frame;
        viewFrame.size.height -=200;
        scrollView.frame = viewFrame;
        [UIView commitAnimations];
    } else if (textField == _inviteNameTextField) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        CGRect viewFrame = scrollView.frame;
        viewFrame.size.height -=200;
        [scrollView setContentOffset:CGPointMake(0.0f, _inviteNameTextField.frame.origin.y - 200 + 40)];
        scrollView.frame = viewFrame;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == _stadiumAddrText || textField == _inviteNameTextField) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        CGRect viewFrame = scrollView.frame;
        viewFrame.size.height +=200;
        scrollView.frame = viewFrame;
        [UIView commitAnimations];
    }
}
 */


-(IBAction)HideDatePicker:(id)sender
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    [outputFormatter setDateFormat:@"YYYY-MM-dd"];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _datepicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 20);
                         _toolbar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35);
                     } completion:^(BOOL finished) {
                         //NSLOG
                         _dateText.text = [outputFormatter stringFromDate:self.datepicker.date];
                         _challengeDate = _dateText.text;
                         [_datepicker removeFromSuperview];
                         [_toolbar removeFromSuperview];
                         _datepicker = nil;
                         _toolbar = nil;
                     }];
}

-(IBAction)HideTimePicker:(id)sender
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    [outputFormatter setDateFormat:@"HH:mm"];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _datepicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 20);
                         _toolbar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35);
                     } completion:^(BOOL finished) {
                         //NSLOG
                          _timeText.text = [outputFormatter stringFromDate:self.datepicker.date];
                         _challengeTime = _timeText.text;
                         [_datepicker removeFromSuperview];
                         [_toolbar removeFromSuperview];
                         _datepicker = nil;
                         _toolbar = nil;
                     }];
}

-(IBAction)cancelPressed
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         _datepicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 20);
                         _toolbar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35);
                     } completion:^(BOOL finished) {
                         [_datepicker removeFromSuperview];
                         [_toolbar removeFromSuperview];
                         _datepicker = nil;
                         _toolbar = nil;
                     }];
}

-(void)pickerChanged:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    _establishDayText.text = [dateFormatter stringFromDate:[(UIDatePicker*)sender date]];
}

/*
 상대구락부매니저에게 상의마당창조를 알린다.
 */
- (void)sendMsgToCreateNewDiscussRoom:(int)nRoomID msg:(NSString *)msg
{
    ChatMessage *message = [[ChatMessage alloc] init];
    message.type = MESSAGE_TYPE_TEXT;
    message.senderId = UID;
    message.roomId   = nRoomID;
    message.userPhoto = USERPHOTO;
    message.msg = [NSString stringWithFormat:@"create new discuss room,room_id=%d,room_title=%@", nRoomID, msg];
    message.senderName = USERNAME;
    message.sendTime   = curSystemTimeStr;
    message.sendState = CHATENABLE? 1 : 0;
    message.readState = 1;
    [[Chat sharedInstance] sendChatMessage: message withDelegate:nil];
    
    message.msg = LANGUAGE(@"challenge_talk");
    [[Chat sharedInstance] sendChatMessage: message withDelegate:nil];
    [ChatMessage addChatMessage:message];
}

- (void)sendMsgToUpdateDiscussRoom:(int)nRoomID msg:(NSString *)msg
{
    ChatMessage *message = [[ChatMessage alloc] init];
    message.type = MESSAGE_TYPE_TEXT;
    message.senderId = UID;
    message.roomId   = nRoomID;
    message.userPhoto = USERPHOTO;
    message.msg = [NSString stringWithFormat:@"update discuss room,room_id=%d,room_title=%@", nRoomID, msg];
    message.senderName = USERNAME;
    message.sendTime   = curSystemTimeStr;
    [[Chat sharedInstance] sendChatMessage: message withDelegate:nil];
}

- (void) keyboardDidShow: (NSNotification *)notif {
    
    // 이전에 키보드가 안보이는 상태였는지 확인합니다.
    if (keyboardVisible) {
        return;
    }
    
    // 키보드의 크기를 읽어옵니다.
    // NSNotification 객체는 userInfo 필드에 자세한 이벤트 정보를 담고 있습니다.
    NSDictionary* info = [notif userInfo];
    // 딕셔너리에서 키보드 크기를 얻어옵니다.
    //NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey]; // deprecated
    NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // 키보드의 크기만큼 스크롤 뷰의 크기를 줄입니다.
    CGRect viewFrame = scrollView.frame;
    viewFrame.size.height -= keyboardSize.height;
    
    scrollView.frame = viewFrame;
    keyboardVisible = YES;
}

- (void) keyboardDidHide: (NSNotification *)notif {
    
    // 이전에 키보드가 보이는 상태였는지 확인합니다.
    if (!keyboardVisible) {
        return;
    }
    
    // 키보드의 크기를 읽어옵니다.
    NSDictionary* info = [notif userInfo];
    //NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // 키보드의 크기만큼 스크롤 뷰의 높이를 늘여서 원래의 크기로 만듭니다.
    CGRect viewFrame = scrollView.frame;
    viewFrame.size.height += keyboardSize.height;
    
    scrollView.frame = viewFrame;
    keyboardVisible = NO;
}

#pragma Events:TextView
- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshHeight:textView];
}

- (void)refreshHeight:(UITextView*)textView
{
    NSInteger newSizeH = [self measureHeight:textView];
    CGRect frame;
    
    if (newSizeH != textView.frame.size.height) {
        NSInteger itemDiff = newSizeH - textView.frame.size.height;
        
        if (textView == _stadiumAddrText) {
            for (int i = 1010; i < 1016; i ++) {
                if ( i <= 1012 )
                {
                    UIView *viewTag = [scrollView viewWithTag:i];
                    frame = viewTag.frame;
                    frame.size.height = frame.size.height + itemDiff;
                    viewTag.frame = frame;
                    continue;
                }

                UIView *viewTag = [scrollView viewWithTag:i];
                frame = viewTag.frame;
                frame.origin.y = frame.origin.y + itemDiff;
                viewTag.frame = frame;
            }
        }
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + itemDiff);
    }
    textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, newSizeH);
}

// Code from apple developer forum - @Steve Krulewitz, @Mark Marszal, @Eric Silverberg
- (CGFloat)measureHeight:(id)sender
{
    UITextView *textView = (UITextView*)sender;
    
    UIFont *font = textView.font;
    NSString *str = textView.text;
    
    UIEdgeInsets insets = textView.textContainerInset;
    
    int w = textView.frame.size.width;
    
    CGSize size = [str sizeWithFont:font constrainedToSize:CGSizeMake(w, 500)];
    return size.height + insets.bottom + insets.top;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        if (_creatingMode == CREATINGMODE_CREATING && _challengeMode == CHALLENGEMODE_DIRECT_CHALLEGNE)
        {
            ggaAppDelegate *appDelegate = APP_DELEGATE;
            [appDelegate selectedIndex:0];
            [Common BackToPage];
        }
        
    }
}

@end
