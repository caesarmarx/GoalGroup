                                            //
//  ChattingRoomViewController.m
//  GoalGroup
//
//  Created by KCHN on 2/3/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubRoomViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "ClubSettingsController.h"
#import "ClubDetailController.h"
#import "GameScheduleItemView.h"
#import "ClubMarksItemView.h"
#import "PersonalMarksItemView.h"
#import "PersonalMarksDetailController.h"
#import "ReportController.h"
#import "BattleResultInputController.h"
#import "ChallengeItemView.h"
#import "GameScheduleController.h"
#import "JoiningBookController.h"
#import "ClubMarksDetailController.h"
#import "ClubMemberController.h"
#import "ClubGameController.h"
#import "MakingChallengeController.h"
#import "PlayerDetailController.h"
#import "DiscussRoomManager.h"
#import "Sqlite3Manager.h"
#import "NSString+Utils.h"
#import "JSON.h"
#import "Chat.h"
#import "Utils.h"
#import "Common.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "HttpRequest.h"
#import "ASIFormDataRequest.h"
#import "DateManager.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import "KxMenu.h"
#define SENDGAME_ME YES;
#define SENDGAME_OPPOSITE NO;
typedef enum
{
    EXTENDED_VIEW_TYPE_NONE = 0,
    EXTENDED_VIEW_TYPE_VOICEMAIL = 1,
    EXTENDED_VIEW_TYPE_EMOTICON = 2,
    EXTENDED_VIEW_TYPE_EXTEND = 3,
}ExtendedViewType;

@interface ClubRoomViewController ()
{
    IBOutlet UIBubbleTableView  *bubbleTable;
    IBOutlet UIView             *textInputView;
    IBOutlet UITextField        *textField;
    UIButton                    *extendButton;
    UIButton                    *sayButton;
    UIView                      *voicemailView;
    UIView                      *emoticonView;
    UIView                      *extendView;
    
    NSMutableArray *bubbleData;
    
    int nGameType;
    int nChattingType;
    int nGameState;
    int nChallState;
    int nGameID;
    BOOL sendGame;
    
    BOOL isKeyboardShow;
    CGFloat keyboardHeight;
    
    ExtendedViewType            extendedViewType;
}
@end

@implementation ClubRoomViewController

@synthesize savedFilePath, thumbImageView;

+ (ClubRoomViewController *)sharedInstance
{
    @synchronized(self)
    {
        if (gClubRoomViewController == nil)
            gClubRoomViewController = [[ClubRoomViewController alloc] init];
    }
    return gClubRoomViewController;
}
- (id)initWithNibName:(NSString *)nibNameOrNil clubID:(int)c_id bundle:(NSBundle *)nibBundleOrNil
{
    nChattingType = CHATTING_TYPE_CLUBROOM;
    nMineClubID = c_id;
    nRoomID = [[ClubManager sharedInstance] intRoomIDWithClubID:nMineClubID];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nMineClubID] forKey:@"CLUBDETAIL_CLUBID"];
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil gameInfo:(ChallengeListRecord *)record type:(int)type clubID:(int)clubID roomID:(int)roomID
{
    nChattingType = CHATTING_TYPE_DISCUSS;
    
    gameInfo = record;
    
    //0:challengeDiscuss, 1:noticeDiscuss, 2:customDiscuss(from scheduleVC)
    nGameType = type;
    nGameID = [gameInfo intWithGameID];
    nGameState = [gameInfo intWithVSStatus];
    nMineClubID = clubID;
    nRoomID = roomID;
    
    int team1 = [record intWithSendClubID];
    int team2 = [record intWithRecvClubID];
    
    if (team2 != 0)
    {
        if ([[ClubManager sharedInstance] checkAdminClub:team1])
        {
            nMineClubID = team1;
            nOppositClubID = team2;
            sendGame = SENDGAME_ME;
        }
        else
        {
            nMineClubID = team2;
            nOppositClubID = team1;
            sendGame = SENDGAME_OPPOSITE;
        }
    }
    else
    {
        sendGame = SENDGAME_OPPOSITE;
        nOppositClubID = team1;
    }
    

    self = [self initWithNibName:nibNameOrNil bundle:nil];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil conference:(ConferenceListRecord *)record
{
    nChattingType = CHATTING_TYPE_DISCUSS;
    
    nGameType = [record intWithGameType];
    nGameState = [record intWithGameState];
    nChallState = [record intWithChallState];
    nGameID = [record intWithGameID];
    
    nRoomID = [record intWithRoomID];
    
    int team1 = [record intWithTeam1];
    int team2 = [record intWithTeam2];
    
    if ([[ClubManager sharedInstance] checkAdminClub:team1])
    {
        nMineClubID = team1;
        nOppositClubID = team2;
        sendGame = SENDGAME_ME;
    }
    else
    {
        nMineClubID = team2;
        nOppositClubID = team1;
        sendGame = SENDGAME_OPPOSITE;
    }

    self = [self initWithNibName:nibNameOrNil bundle:nil];

    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[Chat sharedInstance] setDelegate:self];
    }
    return self;
}

- (void) layoutComponents
{
    self.view.backgroundColor = [UIColor ggaThemeGrayColor];
    
    NSString *clubRoomTitle = [NSString stringWithFormat:@"%@-%@", [[ClubManager sharedInstance] stringClubNameWithID:nMineClubID], LANGUAGE(@"CLUB_BIG_ROOM")];
    NSString *discussRoomTitle = LANGUAGE(@"METTING_ROOM");
    self.title = nChattingType == CHATTING_TYPE_CLUBROOM? clubRoomTitle : discussRoomTitle;
    textInputView.backgroundColor = [UIColor ggaGrayBackColor];
    
    [RecorderManager sharedManager].delegate = self;
    
    //link with xib
    extendButton = (UIButton *)[self.view viewWithTag:131];
    
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.delegate = self;
    
    sayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sayButton.frame = CGRectMake(278, 6, 36, 28);
    sayButton.layer.backgroundColor = [UIColor ggaThemeColor].CGColor;
    sayButton.layer.borderColor = [UIColor ggaThemeColor].CGColor;
    [sayButton setTitle:LANGUAGE(@"SEND") forState:UIControlStateNormal];
    sayButton.layer.borderWidth = 1;
    sayButton.layer.cornerRadius = 8;
    sayButton.hidden = YES;
    [sayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sayButton addTarget:self action:@selector(sayPressed:) forControlEvents:UIControlEventTouchUpInside];
    [textInputView addSubview:sayButton];
    
    voicemailView = (UIView *)[self.view viewWithTag:109];
    emoticonView = (UIView *)[self.view viewWithTag:110];
    
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    
    //메뉴
    subMenuArray = [NSArray arrayWithObjects:
                    [KxMenuItem menuItem:LANGUAGE(@"club_menu_first")
                                   image:IMAGE(@"move_next")
                                  target:self
                                  action:@selector(clubMemberClicked:)],
                    [KxMenuItem menuItem:LANGUAGE(@"club_menu_second")
                                   image:IMAGE(@"move_next")
                                  target:self
                                  action:@selector(clubDetailClicked:)],
                    [KxMenuItem menuItem:LANGUAGE(@"club_menu_third")
                                   image:IMAGE(@"move_next")
                                  target:self
                                  action:@selector(creatingGameClicked:)],
                    [KxMenuItem menuItem:LANGUAGE(@"club_menu_fourth")
                                   image:IMAGE(@"move_next")
                                  target:self
                                  action:@selector(clubSettingsClicked:)],
                    [KxMenuItem menuItem:LANGUAGE(@"club_menu_fifth")
                                   image:IMAGE(@"move_next")
                                  target:self
                                  action:@selector(breakDownClubClicked:)],
                    nil];
    
    for (KxMenuItem *item in subMenuArray)
        item.alignment = NSTextAlignmentCenter;
    
    [self getMessageHistoryWithAll:YES];
    
    //extendedView
    extendedViewType = EXTENDED_VIEW_TYPE_NONE;
    if (nChattingType == CHATTING_TYPE_CLUBROOM)
    {
        UIView *plusClubButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 24)];
        UIButton *plusClubViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 22)];
        [plusClubViewButton setImage:IMAGE(@"list_more") forState:UIControlStateNormal];
        [plusClubViewButton addTarget:self action:@selector(moreView:) forControlEvents:UIControlEventTouchDown];
        [plusClubButtonView addSubview:plusClubViewButton];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:plusClubButtonView];
    }
    
    UIView *padView = (UIView *)[self.view viewWithTag:nChattingType == CHATTING_TYPE_CLUBROOM? 140:130];
    padView.hidden = YES;
    
    //voicemailView
    //레벨메터
    levelMeter = [[UIProgressView alloc] initWithFrame:CGRectMake(0, voicemailView.frame.size.height - 8, SCREEN_WIDTH, 8)];
    levelMeter.progress = 0;
    [voicemailView addSubview:levelMeter];
    
    //록음버튼
    CGFloat x = (voicemailView.frame.size.width - 176) / 2;
    CGFloat y = (voicemailView.frame.size.height - 64) / 2 - 8;
    recordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [recordButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [recordButton setTitleColor:[UIColor ggaWhiteColor] forState:UIControlStateNormal];
    [recordButton setFrame:CGRectMake(x, y, 176, 64)];
    [recordButton setImage:IMAGE(@"mic") forState:UIControlStateNormal];
    [recordButton setBackgroundColor:[UIColor ggaThemeColor]];
    [recordButton addTarget:self action:@selector(recordStart) forControlEvents:UIControlEventTouchDown];
    [recordButton addTarget:self action:@selector(recordEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [recordButton addTarget:self action:@selector(removeEffect:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    recordButton.layer.cornerRadius = 32;
    recordButton.layer.masksToBounds = YES;
    recordButton.titleLabel.font = FONT(40.f);
    [voicemailView addSubview:recordButton];
    
    removeButton = [[UIButton alloc] initWithFrame:CGRectMake(recordButton.frame.origin.x + recordButton.frame.size.width + 10, 10, 45, 45)];
    [removeButton setImage:IMAGE(@"trash") forState:UIControlStateNormal];
    
    removeButton.hidden = true;
    isRemoveRecord = NO;
    
    [voicemailView addSubview:removeButton];
    
    //emoticonView
    emoticonView.backgroundColor = [UIColor ggaWhiteColor];
    
    CGFloat spaceX = (SCREEN_WIDTH - (EMOTICON_WIDTH * EMOTICON_COL_COUNT)) / (EMOTICON_COL_COUNT + 1);
    CGFloat spaceY = (emoticonView.frame.size.height - (EMOTICON_WIDTH * EMOTICON_ROW_COUNT)) / (EMOTICON_ROW_COUNT + 1);
    for (int i=0; i<=[ARR_EMOJI count]; i++)
    {
        CGFloat x = spaceX + (EMOTICON_WIDTH + spaceX) * (int)(i % EMOTICON_COL_COUNT);
        CGFloat y = spaceY + (EMOTICON_WIDTH + spaceY) * (int)(i / EMOTICON_COL_COUNT);
        UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        emojiButton.frame = CGRectMake(x, y, EMOTICON_WIDTH, EMOTICON_WIDTH);
        if (i < [ARR_EMOJI count])
        {
            emojiButton.tag = i;
            [emojiButton addTarget:self action:@selector(emojiPressed:) forControlEvents:UIControlEventTouchUpInside];
            [emojiButton.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:32.0]];
            [emojiButton setTitle:[[ARR_EMOJI objectAtIndex:i] objectAtIndex:0] forState:UIControlStateNormal];
            [emojiButton setShowsTouchWhenHighlighted:YES];
            [emoticonView addSubview:emojiButton];
        }
        else
        {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(backspaceLongPressed:)];
            [emojiButton setBackgroundImage:[UIImage imageNamed:@"emoji_del"] forState:UIControlStateNormal];
            [emojiButton addTarget:self action:@selector(backspacePressed) forControlEvents:UIControlEventTouchUpInside];
            [emojiButton setShowsTouchWhenHighlighted:YES];
            [emojiButton addGestureRecognizer:longPress];
            [emoticonView addSubview:emojiButton];
        }
    }
    
    recording = NO;
    recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(chattingRoomTimerProcess:) userInfo:nil repeats:YES];
    isKeyboardShow = NO;
}

#pragma Events
- (void)backToPage
{
    bIsChatting = NO;
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}


- (void)moreView:(id)sender
{
    int h = IOS_VERSION >= 7? 60:0;
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(SCREEN_WIDTH - 48, h - 5, 10, 10)
                 menuItems:subMenuArray];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//#ifdef IOS_VERSION_7
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//#endif
    
    textInputView.frame = CGRectMake(textInputView.frame.origin.x, SCREEN_HEIGHT - 40 , textInputView.frame.size.width, textInputView.frame.size.height);
    
    bubbleData = [[NSMutableArray alloc] init];
    bubbleTable.bubbleDataSource = self;
    bubbleTable.snapInterval = 10;
    bubbleTable.showAvatars = YES;
    bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    [bubbleTable reloadData];
    
    [self layoutComponents];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    NSString *result = [[NSUserDefaults standardUserDefaults] objectForKey:@"CHATLOG_DELETE"];
    if ([result isEqualToString:@"del_success"])
    {
        [messageList removeAllObjects];
        [bubbleData removeAllObjects];
        [bubbleTable reloadData];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CHATLOG_DELETE"];
    }
    else
        [self getMessageHistoryWithAll:NO];

    [self scrollToBottomAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    nCurChattingRoom = nRoomID;
    bIsChatting = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    bIsChatting = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
#ifdef DEMO_MODE
    NSLog(@"%@ 건반열기 %@", LOGTAG, aNotification);
#endif
    NSDictionary* info = [aNotification userInfo];

    CGSize kbSizeBefore = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    keyboardHeight = kbSizeBefore.height;
    
    CGSize kbSizeAfter = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    int keyHeightAfter = kbSizeAfter.height;

    if (isKeyboardShow && (keyHeightAfter != keyboardHeight))
    {
        keyboardHeight = keyHeightAfter - keyboardHeight;
        [UIView animateWithDuration:0.2f animations:^
         {
             CGRect frame = textInputView.frame;
             frame.origin.y -= keyboardHeight;
             textInputView.frame = frame;
             
             frame = bubbleTable.frame;
             frame.size.height -= keyboardHeight;
             bubbleTable.frame = frame;
         }];
        [self scrollToBottomAnimated:YES];
        isKeyboardShow = YES;
        return;
    };
    
    
    if (isKeyboardShow == YES) {
        return;
    }

    [UIView animateWithDuration:0.2f animations:^
    {
        CGRect frame = textInputView.frame;
        frame.origin.y -= kbSizeBefore.height;
        textInputView.frame = frame;
    
        frame = bubbleTable.frame;
        frame.size.height -= kbSizeBefore.height;
        bubbleTable.frame = frame;
    }];
    [self scrollToBottomAnimated:YES];
    isKeyboardShow = YES;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{    
    if (isKeyboardShow == NO) {
        return;
    }
    
#ifdef DEMO_MODE
    NSLog(@"%@ 건반닫기 %@", LOGTAG, aNotification);
#endif
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.2f animations:^
    {
        CGRect frame = textInputView.frame;
        frame.origin.y += kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height += kbSize.height;
        bubbleTable.frame = frame;
    }];
    [self scrollToBottomAnimated:YES];
    isKeyboardShow = NO;
}



#pragma ClubRoomSubMenuItemClick

- (IBAction)gameScheduleInvestClick:(id)sender
{
    [self gameScheduleDetailPressed];
}

- (IBAction)clubMarksInvestClick:(id)sender
{
    [self clubMarksDetailClick];

}

- (IBAction)psersonMarksInvestClick:(id)sender
{
    [self personalMarksDetailClick];
}

- (IBAction)leaveClubClick:(id)sender
{
    if ([[ClubManager sharedInstance] checkAdminClub:nMineClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"select another admin 2")];
        return;
    }
    
    [AlertManager ConfirmWithDelegate:self message:LANGUAGE(@"would do you like leave this club?") cancelTitle:LANGUAGE(@"cancel") okTitle:LANGUAGE(@"ok") tag:1005];
}

- (IBAction)joiningClubClick:(id)sender
{
    if (![[ClubManager sharedInstance] checkAdminClub:nMineClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    UIViewController *vc = [[JoiningBookController alloc] initWithClubID:nMineClubID];
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

- (IBAction)noticeInvestClick:(id)sender
{
    [self noticeDetailPressed];
}
- (IBAction)challengeInvestClick:(id)sender
{
    [self challengeDetailPressed];
}

#pragma DiscussSubMenuItemClick
- (IBAction)gameEditClick:(id)sender
{
//    if (!sendGame)
//    {
//        [AlertManager AlertWithMessage:LANGUAGE(@"game is unable to edit")];
//        return;
//    }
    
    switch (nGameState) {
        case GAME_STATUS_DELAY:
        case GAME_STATUS_JOINFINISHED:
            [self goToGameEdit];
            break;
        case GAME_STATUS_RUNNING:
            [AlertManager AlertWithMessage:LANGUAGE(@"game is running")];
            break;
        case GAME_STATUS_CANCELLED:
            [AlertManager AlertWithMessage:LANGUAGE(@"game is cancelled")];
            break;
        case GAME_STATUS_FINISHED:
            [AlertManager AlertWithMessage:LANGUAGE(@"game is finished")];
            break;
        default:
            break;
    }
}

- (IBAction)inputMarksClick:(id)sender
{
    if (nGameState != GAME_STATUS_RUNNING && nGameState != GAME_STATUS_FINISHED)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"cannot input marks")];
        return;
    }
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    BattleResultInputController *vc = [BattleResultInputController sharedInstance];
    [vc setClubID: nMineClubID gameID:nGameID];
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

- (IBAction)discardGameClick:(id)sender
{
    if (nGameType != GAME_TYPE_CUSTOM)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"game is not be accepted")];
        return;
    }
    
    if (nGameState != GAME_STATUS_DELAY && nGameState != GAME_STATUS_JOINFINISHED)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"cannot discard game")];
        return;
    }
    
    
    UIActionSheet *querySheet = [[UIActionSheet alloc] initWithTitle:LANGUAGE(@"discard game?") delegate:self cancelButtonTitle:LANGUAGE(@"cancel") destructiveButtonTitle:nil otherButtonTitles:LANGUAGE(@"consult_discard"), LANGUAGE(@"force_discard"), nil];
    [querySheet showInView:self.view];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"CLUBROOM_ACTIONSHEET"];
}

- (IBAction)receiveGameClick:(id)sender
{
    if (sendGame)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"manager_club")];
        return;
    }
        
    if (nGameState == GAME_STATUS_CANCELLED)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"game is cancelled")];
        return;
    }
    
    if (nGameType == GAME_TYPE_CUSTOM)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"already received")];
        return;
    }
    
    if (nChallState == CHALLENGE_GAME_STATE_CLOSE)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"game recevied by other team")];
        return;
    }
    
    [AlertManager WaitingWithMessage];
    NSArray *data = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", nGameID],
                     [NSString stringWithFormat:@"%d", nMineClubID],
                     [NSString stringWithFormat:@"%d", nGameType],nil];
    
    [[HttpManager sharedInstance] agreeGameWithDelegate:self data:data];
}

- (IBAction)oppositeDetailClick:(id)sender
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubDetailController alloc] initWithClub:nOppositClubID fromClubCenter:NO] animated:YES];
}

- (IBAction)reportClick:(id)sender
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ReportController alloc] initWithTitle:LANGUAGE(@"lbl_setting_report_save")] animated:YES];
}

- (void) personalMarksDetailClick
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[PersonalMarksDetailController alloc] initWithClub:nMineClubID] animated:YES];
}

- (void) clubMarksDetailClick
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubMarksDetailController alloc] initWithClubID:nMineClubID] animated:YES];
}

- (void)gameScheduleDetailPressed
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    GameScheduleController *vc = [GameScheduleController sharedInstance];
    [vc selectMode:NO withClubID:nMineClubID];
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

-(void)challengeDetailPressed
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubGameController alloc] initChallengeStyle:nMineClubID] animated:YES];
}

-(void)noticeDetailPressed
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubGameController alloc] initNoticeStyle:nMineClubID] animated:YES];
}

- (void)clubMemberClicked:(id)sender
{
    [self clubMenuClicked:0];
}

- (void)clubDetailClicked:(id)sender
{
    [self clubMenuClicked:1];
}

- (void)creatingGameClicked:(id)sender
{
    [self clubMenuClicked:2];
}

- (void)clubSettingsClicked:(id)sender
{
    [self clubMenuClicked:3];
}

- (void)breakDownClubClicked:(id)sender
{
    if (![[ClubManager sharedInstance] checkAdminClub:nMineClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    [AlertManager ConfirmWithDelegate:self message:LANGUAGE(@"would you like to break this club down") cancelTitle:LANGUAGE(@"cancel") okTitle:LANGUAGE(@"ok") tag:1006];

}

- (void)clubMenuClicked:(int)rowNum
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    UIViewController *vc;
    
    switch (rowNum) {
        case 0:
            vc = [[ClubMemberController alloc] initWithClubID:nMineClubID];
            break;
        case 1:
            vc = [[ClubDetailController alloc] initWithClub:nMineClubID fromClubCenter:NO];
            break;
        case 2:
            if (ADMINOFCLUB(nMineClubID))
                vc = [[MakingChallengeController alloc] initWithGameEditMode:nMineClubID];
            else
                [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
            break;
        case 3:
            vc = [[ClubSettingsController alloc] initWithRoomID:nRoomID clubID:nMineClubID];
            break;
        default:
            break;
    }
    
    if (vc)
        [appDelegate.ggaNav pushViewController:vc animated:YES];
}

- (void)goToGameEdit
{
    if (nGameType == 2)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"game is unable to edit")];
        return;
    }
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[MakingChallengeController alloc] initWithGameEditModeInExisting:gameInfo withType:nGameType room:nRoomID gameID:nGameID gameType:nGameType sendGame:sendGame] animated:YES];
}

#pragma HttpManagerDelegate
- (void)dismissClubResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"leave from club successfully") tag:1002 delegate:self];
}

#pragma HttpManagerDelegate
- (void)breakDownClubResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
        [[ClubManager sharedInstance] removeAdminClub:nMineClubID];
        [[ClubManager sharedInstance] removeClub:nMineClubID];
        [[DiscussRoomManager sharedInstance] removeChatRoomsWithClubID:nMineClubID];
        
        bIsChatting = NO;
        [Common BackToPage];
    }
}

#pragma HttpManagerDelegate
- (void)gameResignResultWithErrorCode:(int)errorcode
{
    [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode + 123])];
    
    if (errorcode == 1 || errorcode == 6)
    {
        NSString *cause = [[NSUserDefaults standardUserDefaults] objectForKey:@"GAMERESIGN_CAUSE"];
        NSString *msg = [NSString stringWithFormat:@"%@\r\n%@", LANGUAGE(@"resigncause is belowing"), cause];
        
        ChatMessage *message = [[ChatMessage alloc] init];
        
        message.type = 1;
        message.senderId = UID;
        message.roomId   = nRoomID;
        message.userPhoto = USERPHOTO;
        message.msg = msg;
        message.senderName = USERNAME;
        message.sendTime   = curSystemTimeStr;
        message.readState = 1;
        message.sendState = CHATENABLE? 1 : 0;
        
        [[Chat sharedInstance] sendChatMessage: message withDelegate:nil];
        [ChatMessage addChatMessage:message];
        
        bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
        NSBubbleData *sayBubble = [NSBubbleData dataWithText:message.msg
                                                        date:[DateManager DateFromString:message.sendTime]
                                                        type:BubbleTypeMine];
        sayBubble.delegate = self;
        sayBubble.avatarUrl = message.userPhoto;
        sayBubble.nSenderID = (int)message.senderId;
        sayBubble.avatarName = message.senderName;
        sayBubble.sendMsg = CHATENABLE? 1 : 0;
        sayBubble.audioUploading = NO;
        
        [bubbleData addObject:sayBubble];
        [bubbleTable reloadData];
        
        [self scrollToBottomAnimated:YES];

    }
}

#pragma HtpManagerDelegate
- (void)agreeGameWithErrorCode:(int)errorCode withRoomID:(int)nRoom withRoomName:(NSString *)roomStr
{
    [AlertManager HideWaiting];
    
    if (errorCode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorCode])];
    else{
        [AlertManager AlertWithMessage:LANGUAGE(@"agree_game_success")];
        //[self sendMsgToUpdateDiscussRoom:nRoom msg:roomStr];
    }
    
}

#pragma HttpManagerDelegate
- (void)downloadVoiceMailResultWithErrorCode:(int)errorCode filePath:(NSString *)filePath recordIdx:(int)recordIdx
{
    if (errorCode > 0)
        [AlertManager AlertWithMessage:LANGUAGE(@"failed")];
    else
    {
        for (NSBubbleData *data in bubbleData)
            if (data.priKeyIndex == recordIdx && data.audioDownloading == YES)
                data.audioDownloading = NO;
        [bubbleTable reloadData];
    }
}

- (void)getUserIDResultWithErrorCode:(int)errorcode uid:(int)uid
{
    [AlertManager HideWaiting];
    if (errorcode == 0 && uid != 0)
    {
        ggaAppDelegate *appDelegate = APP_DELEGATE;
        PlayerDetailController *pdVC = [[PlayerDetailController alloc] initWithPlayerID:uid showInviteButton:YES];
        [appDelegate.ggaNav pushViewController:pdVC animated:YES];
    }else
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no player exists")];
    }
    
}

#pragma ChatDelegate
//recordIdx는 보이스메일을 다운할때에만 리용된다.
- (void)addChattingMessageToVCWithMessage:(ChatMessage *)chMsg recordIdx:(int)recordIdx
{
    if (chMsg.roomId != nRoomID)
        return;
    
    bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    
    NSBubbleData *sayBubble;
    if (chMsg.type == MESSAGE_TYPE_TEXT)
        sayBubble = [NSBubbleData dataWithText:chMsg.msg
                                          date:[DateManager DateFromString:chMsg.sendTime]
                                          type:chMsg.senderId == UID ? BubbleTypeMine: BubbleTypeSomeoneElse
                     ];
    else if (chMsg.type == MESSAGE_TYPE_IMAGE)
        sayBubble = [NSBubbleData dataWithImageUrl:chMsg.msg
                                              date:[DateManager DateFromString:chMsg.sendTime]
                                              type:chMsg.senderId == UID ? BubbleTypeMine:BubbleTypeSomeoneElse
                                    viewController:self
                     ];
    else if (chMsg.type == MESSAGE_TYPE_AUDIO)
    {
        sayBubble = [NSBubbleData dataWithAudioUrl:chMsg.msg
                                              date:[DateManager DateFromString:chMsg.sendTime]
                                              type:chMsg.senderId == UID ? BubbleTypeMine: BubbleTypeSomeoneElse
                     ];
        sayBubble.priKeyIndex = recordIdx;
        sayBubble.audioDownloading = YES;
    }
    sayBubble.delegate = self;
    sayBubble.avatarUrl = chMsg.userPhoto;
    sayBubble.nSenderID = (int)chMsg.senderId;
    sayBubble.avatarName = chMsg.senderName;
    sayBubble.sendMsg = 1;
    sayBubble.audioUploading = NO;
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    [self scrollToBottomAnimated:YES];
    
}

#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int n = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CLUBROOM_ACTIONSHEET"] intValue];
    if (n == 1)
    {
        if (buttonIndex == 2)
            return;
        [AlertManager InputAlertWithDelegate:self placeholder:@""];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)buttonIndex] forKey:@"GAMERESIGN_CASE"];
    }
    else
    {
        switch (buttonIndex)
        {
            case 0:
                [self takeFromCamera];
                break;
            case 1:
                [self chooseFromLibrary];
                break;
            default:
                break;
        }
    }
    
}

#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1002) //leaveClub
    {
        [[ClubManager sharedInstance] removeClub:nMineClubID];
        [[ClubManager sharedInstance] removeAdminClub:nMineClubID];
        [Common BackToPage];
        
        bIsChatting = NO;
        return;
    }

    if (alertView.tag == 1005) //askLeaveClub
    {
        NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:nMineClubID], @"0", nil];
        
        switch (buttonIndex) {
            case 1:
                
                [AlertManager WaitingWithMessage];
                [[HttpManager sharedInstance] dismissClubWithDelegate:self data:data];
                
                break;
            default:
                break;
        }
        return;
    }
    if (alertView.tag == 1006) //breakdown club
    {
        switch (buttonIndex) {
            case 1:
            {
                NSArray *data = [NSArray arrayWithObjects:
                                 [NSNumber numberWithInt:UID],
                                 [NSNumber numberWithInt:nMineClubID],
                                 nil];
                
                [AlertManager WaitingWithMessage];
                [[HttpManager sharedInstance] breakDownClubWithDelegate:self data:data];
            }
                break;
                
            default:
                break;
        }
        return;
    }

    switch(buttonIndex)
    {
        case 1:
        {
            int nCase = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GAMERESIGN_CASE"] intValue];
            NSString *causeStr = [alertView textFieldAtIndex:0].text;
            
            [[NSUserDefaults standardUserDefaults] setObject:causeStr forKey:@"GAMERESIGN_CAUSE"];
            NSArray *data = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", nGameID],
                             [NSString stringWithFormat:@"%d", nMineClubID],
                             causeStr,
                             [NSNumber numberWithInt:nCase],
                             nil];
            [[HttpManager sharedInstance] gameResignWithDelegate:self data:data];
            break;
        }
        default:
            break;
    }
    
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma choosePhoto
- (void) takeFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"cannot use camera")];
        return;
    }
    
    @try {
        UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
        cameraController.delegate = self;
        cameraController.allowsEditing = NO;
        cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraController.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];
        [self.navigationController presentViewController:cameraController animated:YES completion:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"exception = %@", exception);
    }
}

- (void) chooseFromLibrary
{
    UIImagePickerController *libraryController = [[UIImagePickerController alloc] init];
    libraryController.delegate = self;
    libraryController.allowsEditing = NO;
    libraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    libraryController.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];
    
    [self presentViewController:libraryController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *photoImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        if(photoImage == nil)
            return;
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:photoImage forKey:@"image"];
        [param setObject:picker forKey:@"picker"];
        [self sendChosenPhotoWithParam:param];
    }
}

- (void)dismissImagePickerView:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)saveChosenPhoto:(UIImage *)image
{
    NSString *fileName = [Utils uuid];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *filePath = [FileManager GetImageFilePath:fileName];
    savedFilePath = filePath;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    if([imageData writeToFile:filePath atomically:YES] == NO)
        return NO;
    
    return YES;
}

- (void)sendChosenPhotoWithParam:(NSMutableDictionary *)param
{
    if(param == nil)
        return;
    
    UIImage *image = [param objectForKey:@"image"];
    UIImagePickerController *picker = [param objectForKey:@"picker"];
    if(image == nil || picker == nil)
        return;
    image = [Utils rotateImage:image];
    if([self saveChosenPhoto:image] == NO)
        return;
    [self performSelectorOnMainThread:@selector(dismissImagePickerView:) withObject:picker waitUntilDone:YES];
    NSString *strUrl = [NSString stringWithFormat:FILE_UPLOAD_URL,SERVER_IP_ADDRESS, _PORT];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSLog(@"imageUpload_URL: %@", url);
    
    ggaAppDelegate *appDelegate = (ggaAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.httpClientForUpload.delegate = self;
    HttpRequest *httpRequest = [[HttpRequest alloc] init];
    httpRequest.type = 1;
    httpRequest.addImg = savedFilePath;
    [httpRequest requestUploadContent:0];
}

/*
 기능: 파일이 앞로드된 다음 채팅서버에 보내는 함수
      - 음성파일은 앞로드전에 자료기지에 등록하고 대화방에 현시한다. 앞로드된 다음 자료기지에서 파일경로를 변경한다.
      - 화상파일은 앞로드된 다음에 자료기지에 등록하고 대화방에 현시한다.
 파람: data - 화상정보
 */
- (void)requestSucceeded:(NSString *)data //receive the result of upload photo
{
#ifdef DEMO_MODE
    NSLog(@"requestSucceeded: %@", data);
#endif
    
    NSDictionary *jsonValues = [data JSONValue];
    NSInteger success = [[jsonValues objectForKey:PARAM_KEY_SUCCESS] integerValue];
    NSString *fileName = [jsonValues objectForKey:PARAM_KEY_FILE_NAME];
    NSString *filePath = [jsonValues objectForKey:PARAM_KEY_SERVER_FILE_PATH];
    int priKeyForAudio = [[jsonValues objectForKey:@"server_idx"] intValue];
    
    if(success == 0)
    {
        [Utils showAlertMessage:@"failed"];
        return;
    }
    
    int messageType = MESSAGE_TYPE_IMAGE;
    if ([[fileName substringToIndex:5] isEqualToString:@"audio"])
    {
        messageType = MESSAGE_TYPE_AUDIO;
        [FileManager RenameFile:voicemailFilePath toFilePath:[FileManager GetVoiceFilePath:[filePath MD5]]];
    }

    ChatMessage *message = [[ChatMessage alloc] init];
    message.type = messageType;
    message.senderId = UID;
    message.roomId   = nRoomID;
    message.userPhoto = USERPHOTO;
    message.msg = filePath;
    message.senderName = USERNAME;
    message.sendTime   = curSystemTimeStr;
    message.readState = 1;
    message.sendState = CHATENABLE? 1 : 0;

    [[Chat sharedInstance] sendChatMessage: message withDelegate:self];
    
    bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    
    NSBubbleData *sayBubble;
    if (messageType == MESSAGE_TYPE_IMAGE)
    {
        sayBubble = [NSBubbleData dataWithImageUrl:message.msg
                                              date:[DateManager DateFromString:message.sendTime]
                                              type:BubbleTypeMine
                                    viewController:self
                     ];
        sayBubble.audioUploading = NO;
    }
    else
    {
        sayBubble = [NSBubbleData dataWithAudioUrl:message.msg
                                              date:[DateManager DateFromString:message.sendTime]
                                              type:BubbleTypeMine
                     ];
        sayBubble.audioUploading = NO;
    }
    sayBubble.delegate = self;
    sayBubble.avatarUrl = message.userPhoto;
    sayBubble.nSenderID = (int)message.senderId;
    sayBubble.avatarName = message.senderName;
    sayBubble.sendMsg= CHATENABLE? 1 : 0;
    
    if (messageType == MESSAGE_TYPE_IMAGE)
    {
        [bubbleData addObject:sayBubble];
        [ChatMessage addChatMessage:message];
    }
    else
    {
        [[Sqlite3Manager sharedInstance] updateAudioMessagePath:filePath atIndex:priKeyForAudio];
        
        for (NSBubbleData *data in bubbleData) {
            if (data.priKeyIndex == priKeyForAudio && data.audioUploading == YES)
            {
                [data setVoicemailUrl: message.msg];
                data.audioUploading = NO;
            }
        }
    }
    [bubbleTable reloadData];
    
    [self scrollToBottomAnimated:YES];

    bIsChatting = YES;
}

- (void)requestFailed:(NSError*)error {
    
}



#pragma voicemail
- (void)recordStart
{
    levelMeter.progress = 0;
    [[RecorderManager sharedManager] startRecording];
    
    removeButton.hidden = false;
    
    recordCnt = 0;
    recording = YES;
    [recordButton setImage:nil forState:UIControlStateNormal];
}

- (void)chattingRoomTimerProcess:(NSTimer *)t
{
    [self recordTimeCount];
    
    if (sentAllUnsendMsg)
    {
        for (NSBubbleData *nsbData in bubbleData) {
            nsbData.sendMsg = 1;
        }
        
        sentAllUnsendMsg = NO;
        [bubbleTable reloadData];
    }
}

- (void)recordTimeCount
{
    if (!recording) return;
    recordCnt ++;
    
    int s = recordCnt % 60;
    int m = (recordCnt / 60) % 60;
    
    NSLog(@"%02d:%02d", m, s);
    [recordButton setTitle:[NSString stringWithFormat:@"%02d:%02d", m, s] forState:UIControlStateHighlighted];
}

- (void)recordEnd:(UIButton*)control withEvent:(UIEvent *)event
{
    levelMeter.progress = 0;
    [[RecorderManager sharedManager] stopRecording];
    
    removeButton.hidden = true; //Added By Boss.
    [self removeRecord:event];
    
    recordCnt = 0;
    recording = NO;
    [recordButton setImage:IMAGE(@"mic") forState:UIControlStateNormal];
    [recordButton setTitle:nil forState:UIControlStateNormal];
    
    removeButton.layer.cornerRadius = 0;
    removeButton.layer.borderWidth = 0.f;
    removeButton.layer.masksToBounds = NO;
    
    recordTimer = nil;
}

- (void)removeEffect:(UIButton*)control withEvent:(UIEvent *)event
{
    NSArray *theTouches = [[event allTouches] allObjects];
    
    if(YES == [removeButton pointInside:[[theTouches objectAtIndex:0] locationInView:removeButton] withEvent:event])
    {
        removeButton.layer.cornerRadius = removeButton.frame.size.width / 2;
        removeButton.layer.borderWidth = 1.f;
        removeButton.layer.borderColor = [UIColor ggaGrayBorderColor].CGColor;
        removeButton.layer.masksToBounds = YES;
    }else{
        removeButton.layer.cornerRadius = 0;
        removeButton.layer.borderWidth = 0.f;
        removeButton.layer.masksToBounds = NO;
    }
}
/**
 * Added By Boss.2015/06/02
 *
 */
- (void)removeRecord:(UIEvent *)event
{
    if (event == nil) {
        return;
    }
    
    NSArray *theTouches = [[event allTouches] allObjects];
    
    if(YES == [removeButton pointInside:[[theTouches objectAtIndex:0] locationInView:removeButton] withEvent:event])
    {
        isRemoveRecord = YES;
    }else{
        isRemoveRecord = NO;
    }
}

- (void)recordingFinishedWithFileName:(NSString *)fileName time:(NSTimeInterval)interval
{
    NSLog(@"recordingFinishedWithFileName: %@", [fileName substringFromIndex:[fileName rangeOfString:@"Documents"].location]);
    isRecording = NO;
    
    if (isRemoveRecord) { //Added By Boss.2015/06/02
        BOOL delResult = [FileManager DeleteFile:fileName]; //Delete recorded file
        if (delResult) {
            isRemoveRecord = NO;
        } else {
            NSLog(@"Error is occured in deleting recorded voice file");
        }
        voicemailFilePath = @"";
        return;
    }
    
    voicemailFilePath = fileName;
    [self performSelectorOnMainThread:@selector(sendVoiceMailWithFilePath:) withObject:voicemailFilePath waitUntilDone:YES];
}

- (void)recordingTimeout
{
    if (isRecording)
        [self recordEnd:nil withEvent:nil];
}

- (void)recordingStopped
{
    if (isRecording)
        [self recordEnd:nil withEvent:nil];
}

- (void)recordingFailed:(NSString *)failureInfoString
{
    if (isRecording)
        [self recordEnd:nil withEvent:nil];
}

- (void)levelMeterChanged:(float)levelMeterVal
{
    levelMeter.progress = levelMeterVal;
}

- (void)sendVoiceMailWithFilePath:(NSString *)filePath
{
    ChatMessage *message = [[ChatMessage alloc] init];
    message.type = MESSAGE_TYPE_AUDIO;
    message.senderId = UID;
    message.roomId   = nRoomID;
    message.userPhoto = USERPHOTO;
    message.msg = @"";
    message.senderName = USERNAME;
    message.sendTime   = curSystemTimeStr;
    message.readState = 1;
    message.sendState = CHATENABLE? 1 : 0;
    
    bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    
    NSBubbleData *sayBubble;
    sayBubble = [NSBubbleData dataWithAudioUrl:message.msg
                                              date:[DateManager DateFromString:message.sendTime]
                                              type:BubbleTypeMine
                     ];
    sayBubble.audioUploading = YES;
    sayBubble.delegate = self;
    sayBubble.avatarUrl = message.userPhoto;
    sayBubble.nSenderID = (int)message.senderId;
    sayBubble.avatarName = message.senderName;
    sayBubble.sendMsg= CHATENABLE? 1 : 0;
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    
    int recordIdx = [ChatMessage addChatMessage:message];
    
    sayBubble.priKeyIndex = recordIdx;
    
    ggaAppDelegate *appDelegate = (ggaAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.httpClientForUpload.delegate = self;
    HttpRequest *httpRequest = [[HttpRequest alloc] init];
    httpRequest.type = 2;
    httpRequest.addImg = filePath;
    [httpRequest requestUploadContent:recordIdx];

    [self scrollToBottomAnimated:YES];
    
    bIsChatting = YES;
}

#pragma emoticon
- (void)emojiPressed:(UIButton *)bt
{
    NSString *emoji = [[ARR_EMOJI objectAtIndex:bt.tag] objectAtIndex:0];
    NSString *str = [textField text];
    if (!str)
        str = @"";
    NSMutableString *text = [NSMutableString stringWithString:str];
    [text insertString:emoji atIndex:lastSelectedTextRange.location];
    lastSelectedTextRange.location += 2;
    [textField setText:text];
    [self textFieldValueChanged:textField];
}

- (void)backspacePressed
{
    NSString *str = [textField text];
    if (lastSelectedTextRange.location == 0)
        return;
    NSString *text = @"";
    NSArray *item;
    BOOL isContains = NO;
    if (lastSelectedTextRange.location > 1)
    {
        for(int i=0; i<ARR_EMOJI.count; i ++)
        {
            item = [ARR_EMOJI objectAtIndex:i];
            if ([item containsObject:[str substringWithRange:NSMakeRange(lastSelectedTextRange.location - 2, 2)]])
            {
                isContains = YES;
                break;
            }
        }
    }
    if (isContains)
    {
        text = [NSString stringWithFormat:@"%@%@", [str substringToIndex:lastSelectedTextRange.location - 2], [str substringFromIndex:lastSelectedTextRange.location]];
        lastSelectedTextRange.location -= 2;
    }
    else
    {
        text = [NSString stringWithFormat:@"%@%@", [str substringToIndex:lastSelectedTextRange.location - 1], [str substringFromIndex:lastSelectedTextRange.location]];
        lastSelectedTextRange.location -= 1;
    }
    [textField setText:text];
    [self textFieldValueChanged:textField];
}

- (void)backspaceLongPressed:(UILongPressGestureRecognizer *)gesture
{
    NSString *str = [textField text];
    NSString *text = [str substringFromIndex:lastSelectedTextRange.location];
    lastSelectedTextRange.location = 0;
    [textField setText:text];
    [self textFieldValueChanged:textField];
}

- (NSRange)currentSelectedTextRange
{
    UITextRange *range = textField.selectedTextRange;
    UITextPosition *beginnin = textField.beginningOfDocument;
    NSInteger location = [textField offsetFromPosition:beginnin toPosition:range.start];
    NSInteger length = [textField offsetFromPosition:range.start toPosition:range.end];
    return NSMakeRange(location, length);
}



#pragma user-definded
- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [bubbleTable numberOfRowsInSection:bubbleTable.numberOfSections - 1];
    if(rows > 0)
    {
        [bubbleTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1
                                                               inSection:bubbleTable.numberOfSections - 1]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

/*
 기능: 채팅방히스토리를 얻는 함수
 파람: allmsg 메쎄지얻기동작정의 YES:모든 메쎄지 NO:읽지 않은 메쎄지
 */
- (void)getMessageHistoryWithAll:(BOOL)allmsg
{
    messageList = [[NSMutableArray alloc] init];
    
    if (allmsg)
        messageList = [ChatMessage getMessageByroomId:nRoomID];
    else
        messageList = [ChatMessage getUnreadMessageByroomId:nRoomID];
    
    for (ChatMessage *item in messageList)
    {
        NSBubbleData *sayData;
        if (item.type == 1)
            sayData = [NSBubbleData dataWithText:item.msg
                                            date:[DateManager DateFromString:item.sendTime]
                                            type:item.senderId == UID ? BubbleTypeMine: BubbleTypeSomeoneElse
                       ];
        else if (item.type == 2)
            sayData = [NSBubbleData dataWithImageUrl:item.msg
                                                date:[DateManager DateFromString:item.sendTime]
                                                type:item.senderId == UID ? BubbleTypeMine: BubbleTypeSomeoneElse
                                      viewController:self
                       ];
        else if (item.type == 3)
            sayData = [NSBubbleData dataWithAudioUrl:item.msg
                                                date:[DateManager DateFromString:item.sendTime]
                                                type:item.senderId == UID ? BubbleTypeMine: BubbleTypeSomeoneElse
                       ];
        sayData.delegate = self;
        sayData.avatarUrl = item.senderId == UID? USERPHOTO : item.userPhoto;
        sayData.nSenderID = (int)item.senderId;
        sayData.avatarName = item.senderName;
        sayData.sendMsg = item.sendState;
        sayData.audioUploading = NO;
        [bubbleData addObject:sayData];
    }
    
    [bubbleTable reloadData];
}

- (void)showHideExtendedView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if (extendedViewType != EXTENDED_VIEW_TYPE_NONE)
    {
        textInputView.frame = CGRectMake(textInputView.frame.origin.x, (textInputView.frame.origin.y - 180), textInputView.frame.size.width, textInputView.frame.size.height);
        UIButton *button = (UIButton *)[self.view viewWithTag:131];
        [button setTitle:@"+" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2f animations:^
        {
            CGRect frame = bubbleTable.frame;
            frame.size.height -= 140;//130
            bubbleTable.frame = frame;
        }];
    }
    else
    {
        textInputView.frame = CGRectMake(textInputView.frame.origin.x, (textInputView.frame.origin.y + 180), textInputView.frame.size.width, textInputView.frame.size.height);
        UIButton *button = (UIButton *)[self.view viewWithTag:131];
        [button setTitle:@"+" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2f animations:^
        {
            CGRect frame = bubbleTable.frame;
            frame.size.height += 140;//130
            bubbleTable.frame = frame;
        }];
    }
    [UIView commitAnimations];
}



#pragma IBActions
- (IBAction)sayPressed:(id)sender
{
    if (nChattingType == CHATTING_TYPE_CLUBROOM && ![[ClubManager sharedInstance] checkMyClub:nMineClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"club is breakup")];
        [Common BackToPage];
        return;
    }
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    text = [Common EmojiFilterFrom:text];
    if (text.length > 0)
    {
        ChatMessage *message = [[ChatMessage alloc] init];
        message.type = 1;     //text
        message.senderId = UID;
        message.roomId = nRoomID;
        message.userPhoto = USERPHOTO;
        message.msg = text;
        message.senderName = USERNAME;
        message.sendTime = curSystemTimeStr;
        message.readState = 1;
        message.sendState = CHATENABLE? 1 : 0;

        [[Chat sharedInstance] sendChatMessage: message withDelegate:self];
        
        message.msg = [Common EmojiFilterTo:message.msg];
        bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
        NSBubbleData *sayBubble = [NSBubbleData dataWithText:message.msg
                                                        date:[DateManager DateFromString:message.sendTime]
                                                        type:BubbleTypeMine];
        sayBubble.delegate = self;
        sayBubble.avatarUrl = message.userPhoto;
        sayBubble.nSenderID = (int)message.senderId;
        sayBubble.avatarName = message.senderName;
        sayBubble.sendMsg = CHATENABLE? 1 : 0;
        sayBubble.audioUploading = NO;
        
        [bubbleData addObject:sayBubble];
        [bubbleTable reloadData];
        
        [ChatMessage addChatMessage:message];
        [self scrollToBottomAnimated:YES];

    }
    
    textField.text = @"";
    [self textFieldValueChanged:textField];
    lastSelectedTextRange.location = 0;
}

- (IBAction)photoClicked:(id)sender
{
    UIActionSheet *mNewActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil
                                                        cancelButtonTitle:LANGUAGE(@"cancel")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:LANGUAGE(@"Take Photo or Video"),
                                      LANGUAGE(@"Choose From Library"), nil];
    
    mNewActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    mNewActionSheet.delegate = self;
    [mNewActionSheet showInView:self.view];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"CLUBROOM_ACTIONSHEET"];
}

#pragma textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textFieldParam
{
    [textFieldParam resignFirstResponder];
    return YES;
}

- (IBAction)textFieldValueChanged:(id)sender
{
    sayButton.hidden = !(textField.text.length > 0);
    sayButton.enabled = ([textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0);
    extendButton.hidden = !sayButton.hidden;
}

- (IBAction)textFieldDidBeginEditing:(id)sender
{
    if (extendedViewType == EXTENDED_VIEW_TYPE_NONE)
        return;
    extendedViewType = EXTENDED_VIEW_TYPE_NONE;
    [self showHideExtendedView];
}

- (IBAction)voicemailClicked:(id)sender
{
    lastSelectedTextRange = [self currentSelectedTextRange];
    
    [textField resignFirstResponder];
    lastSelectedTextRange = [self currentSelectedTextRange];
    if (extendedViewType == EXTENDED_VIEW_TYPE_VOICEMAIL)
        extendedViewType = EXTENDED_VIEW_TYPE_NONE;
    else if (extendedViewType == EXTENDED_VIEW_TYPE_NONE)
    {
        extendedViewType = EXTENDED_VIEW_TYPE_VOICEMAIL;
        emoticonView.hidden = YES;
        voicemailView.hidden = NO;
    }
    else
    {
        extendedViewType = EXTENDED_VIEW_TYPE_VOICEMAIL;
        emoticonView.hidden = YES;
        voicemailView.hidden = NO;
        return;
    }
    [self showHideExtendedView];
}

- (IBAction)emoticonClicked:(id)sender
{
    lastSelectedTextRange = [self currentSelectedTextRange];
    
    [textField resignFirstResponder];
    if (extendedViewType == EXTENDED_VIEW_TYPE_EMOTICON)
        extendedViewType = EXTENDED_VIEW_TYPE_NONE;
    else if (extendedViewType == EXTENDED_VIEW_TYPE_NONE)
    {
        extendedViewType = EXTENDED_VIEW_TYPE_EMOTICON;
        emoticonView.hidden = NO;
        voicemailView.hidden = YES;
    }
    else
    {
        extendedViewType = EXTENDED_VIEW_TYPE_EMOTICON;
        emoticonView.hidden = NO;
        voicemailView.hidden = YES;
        return;
    }
    [self showHideExtendedView];
}

- (IBAction)extendClicked:(id)sender
{
    lastSelectedTextRange = [self currentSelectedTextRange];
    
    [textField resignFirstResponder];
    if (extendedViewType == EXTENDED_VIEW_TYPE_EXTEND)
        extendedViewType = EXTENDED_VIEW_TYPE_NONE;
    else if (extendedViewType == EXTENDED_VIEW_TYPE_NONE)
    {
        extendedViewType = EXTENDED_VIEW_TYPE_EXTEND;
        emoticonView.hidden = YES;
        voicemailView.hidden = YES;
    }
    else
    {
        extendedViewType = EXTENDED_VIEW_TYPE_EXTEND;
        emoticonView.hidden = YES;
        voicemailView.hidden = YES;
        return;
    }
    [self showHideExtendedView];
}

#pragma NSBubbleDataDelegate
- (void)playerDetailVCWithPlayerNick:(NSString *)nickName
{
    [AlertManager WaitingWithMessage];
    NSArray *array = [NSArray arrayWithObjects:nickName, nil];
    [[HttpManager sharedInstance] getUserIDWithDelegate:self data:array];
}

- (void)gameListVCWithGameType:(int)type
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    UIViewController *vc;
    switch (type) {
        case GAME_TYPE_CHALLENGE:
            vc = [[ChallengePlayViewController alloc] init];
            break;
        case GAME_TYPE_NOTIFY:
            vc = [[ClubGameController alloc] initNoticeStyle:nMineClubID];
            vc.title = LANGUAGE(@"DECLARATION_ROOM");
            break;
        default:
            break;
    }
    
    if (vc)
        [appDelegate.ggaNav pushViewController:vc animated:YES];

}

/*
 기능: 상대구락부매니저에게 상의마당정보갱신을 알린다.
 파람: nRoom - 상의마당아이디
 msg - 상의마당정보
 */
- (void)sendMsgToUpdateDiscussRoom:(int)nRoom msg:(NSString *)msg
{
    ChatMessage *message = [[ChatMessage alloc] init];
    message.type = MESSAGE_TYPE_TEXT;
    message.senderId = UID;
    message.roomId   = nRoom;
    message.userPhoto = USERPHOTO;
    message.msg = [NSString stringWithFormat:@"update discuss room,room_id=%d,room_title=%@", nRoom, msg];
    message.senderName = USERNAME;
    message.sendTime   = curSystemTimeStr;
    message.readState = 1;
    [[Chat sharedInstance] sendChatMessage: message withDelegate:nil];
}


@end
