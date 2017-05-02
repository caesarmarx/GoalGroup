//
//  ClubGameController.m
//  GoalGroup
//
//  Created by KCHN on 2/26/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubGameController.h"
#import "ClubGameViewCell.h"
#import "ChallengeListRecord.h"
#import "ClubDetailController.h"
#import "DiscussRoomManager.h"
#import "ClubRoomViewController.h"
#import "AlertManager.h"
#import "NSString+Utils.h"
#import "DateManager.h"
#import "ChatMessage.h"
#import "Common.h"
#import "Chat.h"

@interface ClubGameController ()
{
    BOOL agreeMode;
}
@end

@implementation ClubGameController

- (id)initChallengeStyle:(int)c_id
{
    showTeam = NO;
    nClubID = c_id;
    return [self init];
}

- (id)initNoticeStyle:(int)c_id
{
    showTeam = YES;
    nClubID = c_id;
    return [self init];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSString *noticeTitle = [NSString stringWithFormat:@"%@%@", [[ClubManager sharedInstance] stringClubNameWithID:nClubID], LANGUAGE(@"club-notice")];
        NSString *challTitle = [NSString stringWithFormat:@"%@%@", [[ClubManager sharedInstance] stringClubNameWithID:nClubID], LANGUAGE(@"club-challenge")];
        self.title = showTeam? noticeTitle: challTitle;
        // Custom initialization
        UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
        [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
        
        [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
        [backButtonRegion addSubview:backButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    currPageNo = 0;
    moreAvailable = NO;
    [games removeAllObjects];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadMore];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif

    moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 50)];
    [moreView startAnimating];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    games = [[NSMutableArray alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated
{
    loading = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    if (currentOffset.x == 0.f && currentOffset.y <= 0.0f) {
        [scrollView setContentOffset:CGPointMake(0.f, 0.f)];
    }
    
    [self hideMenuOptionsAnimated:YES];
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (games.count > 0)
        return moreAvailable? games.count + 1: games.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH / 2 + 17;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == games.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"More"];
        [cell.contentView addSubview:moreView];
        
        if (!loading)
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:2.f];
        return cell;
    }
    
    if (games.count == 0)
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    ChallengeListRecord *record;
    record = (ChallengeListRecord *)[games objectAtIndex:indexPath.section];
    NSString *CellIdentifier = [NSString stringWithFormat:@"CellClubGame"];
    ClubGameViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        if (showTeam)
            cell = [[ClubGameViewCell alloc] initMyNoticeWithStyle:UITableViewCellStyleDefault resueIdentifier:CellIdentifier];
        else
            cell = [[ClubGameViewCell alloc] initMyChallengeWithStyle:UITableViewCellStyleDefault resueIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    cell.nclub = nClubID;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell dataWithChallengeRecord:record];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma Events
- (void)refresh
{
    currPageNo = 0;
    moreAvailable = NO;
    [games removeAllObjects];
    [self loadMore];
    [self.refreshControl endRefreshing];
}

#pragma UserDefinded
- (void)loadMore
{
    int type = showTeam? 1: 2;
    
    loading = YES;
    currPageNo ++;
    
    NSString *strClubIDs = [NSString stringWithFormat:@"%d", nClubID];
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:strClubIDs,
                             [NSNumber numberWithInt:type],
                             [NSNumber numberWithInt:currPageNo],
                             [NSNumber numberWithInt:0], nil];
    [[HttpManager newInstance] browseChallengeListWithDelegate:self data:array];
    
}

#pragma UserDefined
- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

#pragma HttpManagerDelegate
- (void)browseChallengeResultWithErrorCode:(int)errorCode dataMore:(int)more data:(NSArray *)data
{
    if (loading == NO)
        return;
    loading = NO;
    moreAvailable = more == 1;
#ifdef DEMO_MODE
    NSLog(@"browseChallengeResultWithErrorCode: errorCode=%i, moreAvailable=%i, data=%lu", errorCode, moreAvailable, (unsigned long)data.count);
#endif	
    [games addObjectsFromArray:data];
    [self.tableView reloadData];
}

- (void)delChallengeResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
    {
        int index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CLUBGAME_CANCELINDEX"] intValue];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        
        [games removeObjectAtIndex:index];
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationLeft];
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
    }
}

#pragma ClubGameViewCellDelegate
- (void)cancelButtonClick:(ClubGameViewCell *)cell
{
    if (![[ClubManager sharedInstance] checkAdminClub:nClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)indexPath.section] forKey:@"CLUBGAME_CANCELINDEX"];
    
    [AlertManager ConfirmWithDelegate:self message:LANGUAGE(@"would you like to cancel game") cancelTitle:LANGUAGE(@"cancel") okTitle:LANGUAGE(@"ok") tag:1001];
}

- (void)gotoClubDetail:(ClubGameViewCell *)cell clubID:(int)c_id
{
    if (c_id < 1) return;
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubDetailController alloc] initWithClub:c_id fromClubCenter:NO] animated:YES];
}

- (void)recommandToClubRoom:(ClubGameViewCell *)cell
{
    [self hideMenuOptionsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int nSendClub = [[games objectAtIndex:indexPath.section] intWithSendClubID];
    
    if ([[ClubManager sharedInstance] checkAdminClub:nSendClub])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"manager_club")];
        return;
    }
    
    int room = [[ClubManager sharedInstance] intRoomIDWithClubID:nClubID];
    NSString *sendClub = [[games objectAtIndex:indexPath.section] stringWithSendClubName];
    NSString *recvClub = [[games objectAtIndex:indexPath.section] stringWithRecvClubName];
    
    NSString *msg = [NSString stringWithFormat:@"%@%@\r\n%@:%@\r\n%@ VS %@",
                     LANGUAGE(@"myrecommend"),
                     LANGUAGE(@"notice"),
                     LANGUAGE(@"sendteam"),
                     sendClub,
                     sendClub,
                     recvClub
                     ];
    
    ChatMessage *message = [[ChatMessage alloc] init];
    
    message.type = 1;     //text
    message.senderId = UID;
    message.roomId   = room;
    message.userPhoto = USERPHOTO;
    message.msg = msg;
    message.senderName = USERNAME;
    message.sendTime   = curSystemTimeStr;
    message.sendState = CHATENABLE? 1 : 0;
    message.readState = 0;
    
    [[Chat sharedInstance] sendChatMessage: message withDelegate:nil];
    [ChatMessage addChatMessage:message];
    
    if (CHATENABLE)
        [AlertManager AlertWithMessage:LANGUAGE(@"recommend_success")];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"recommend_failed")];

}

- (void)gotoChallengeDiscuss:(ClubGameViewCell *)cell withArrowView:(ChallengeItemView *)arrowView
{
    [self hideMenuOptionsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ChallengeListRecord *gameInfo = [games objectAtIndex:indexPath.section];
    
    int nSendClub = [gameInfo intWithSendClubID];
    int nRecvClub = [gameInfo intWithRecvClubID];
    int nGameID = [gameInfo intWithGameID];
    
    if ([[ClubManager sharedInstance] checkAdminClub:nClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    if (![[ClubManager sharedInstance] checkAdminClub:nClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    int nRoomID = [[DiscussRoomManager sharedInstance] discussRoomIDWithSendID:nSendClub recvID:nRecvClub gameID:nGameID gametype:GAME_TYPE_NOTIFY];
    
    if (nRoomID != -1)
    {
        ggaAppDelegate *appDelegate = APP_DELEGATE;
        [appDelegate.ggaNav pushViewController:[[ClubRoomViewController alloc] initWithNibName:@"ClubRoomViewController" gameInfo:gameInfo type:GAME_TYPE_NOTIFY clubID:nClubID roomID:nRoomID] animated:YES];
    }
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"chatting room does not exist")];
    
}

- (void)agreeGame:(ClubGameViewCell *)cell withArrowView:(ChallengeItemView *)arrowView
{
    [self hideMenuOptionsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    int nRecvClub = [[games objectAtIndex:indexPath.section] intWithRecvClubID];
    int nSendClub = [[games objectAtIndex:indexPath.section] intWithSendClubID];
    
    if (![[ClubManager sharedInstance] checkAdminClub:nClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    if (nSendClub == nClubID)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"manager_club")];
        return;
    }
    
    if (![[ClubManager sharedInstance] checkAdminClub:nRecvClub])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    
    if ([[ClubManager sharedInstance] checkAdminClub:nSendClub])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"manager_club")];
        return;
    }
    
    
    
    int gameID = [[games objectAtIndex:indexPath.section] intWithGameID];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:gameID] forKey:@"AGREEGAMEID"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:indexPath.section] forKey:@"AGREEINDEX"];

    NSArray *data = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", gameID],
                     [NSString stringWithFormat:@"%d", nClubID],
                     [NSString stringWithFormat:@"%d", 1],
                     nil];
    
    [AlertManager WaitingWithMessage];
    [[HttpManager newInstance] agreeGameWithDelegate:self data:data];
}

- (void)menuDidShowInCell:(ClubGameViewCell *)cell
{
    if (![self.swipedCell isEqual:cell])
        [self hideMenuOptionsAnimated:YES];
    
    self.swipedCell = cell;

}

- (void)menuDidHideInCell
{
    self.swipedCell = nil;
}

- (void)agreeGameWithErrorCode:(int)errorCode withRoomID:(int)roomID withRoomName:(NSString *)roomStr
{
    [AlertManager HideWaiting];
    
    if (errorCode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorCode])];
    else{
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
        
        int index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AGREEINDEX"] intValue];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        
        [games removeObjectAtIndex:index];
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationLeft];
        
        //[self sendMsgToUpdateDiscussRoom:roomID msg:roomStr];
    }
}

#pragma mark * DAOverlayView delegate
- (UIView *)overlayView:(DAOverlayView *)view didHitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL shouldIterceptTouches = CGRectContainsPoint([self.view convertRect:self.swipedCell.frame toView:self.view],
                                                     [self.view convertPoint:point fromView:view]);
    if (!shouldIterceptTouches) {
        [self hideMenuOptionsAnimated:YES];
    }
    return (shouldIterceptTouches) ? [self.swipedCell hitTest:point withEvent:event] : view;
}

#pragma mark * UITableView delegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView cellForRowAtIndexPath:indexPath] == self.swipedCell) {
        [self hideMenuOptionsAnimated:YES];
        return NO;
    }
    return YES;
}

- (void)hideMenuOptionsAnimated:(BOOL)animated
{
    if (self.swipedCell != nil)
        [self.swipedCell closeMenu];
    
    self.swipedCell = nil;
}

/*
 기능: 상대구락부매니저에게 상의마당정보갱신을 알린다.
 파람: nRoomID - 상의마당아이디
      msg - 상의마당정보
 */
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
    message.readState = 1;
    [[Chat sharedInstance] sendChatMessage: message withDelegate:nil];
}

#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CLUBGAME_CANCELINDEX"] intValue];
    
    int nGameID;
    int nGameType;
    
    if (alertView.tag == 1001)
    {
        switch (buttonIndex)
        {
            case 0:
                break;
            case 1:
            {
                nGameID = [[games objectAtIndex:index] intWithGameID];
                nGameType = showTeam? 1: 0;
            
                NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:nGameID],
                                 [NSNumber numberWithInt:nGameType], nil];
            
                [AlertManager WaitingWithMessage];
                [[HttpManager sharedInstance] delChallengeWithDelegate:self data:data];
                break;
            }
            default:
                break;
        }
    }
}

@end
