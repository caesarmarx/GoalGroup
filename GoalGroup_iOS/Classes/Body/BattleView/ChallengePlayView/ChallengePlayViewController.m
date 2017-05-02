//
//  ChallengePlayViewController.m
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ChallengePlayViewController.h"
#import "ChallengePlayViewCell.h"
#import "ChallengeListRecord.h"
#import "ClubDetailController.h"
#import "ClubRoomViewController.h"
#import "ClubSelectController.h"
#import "DiscussRoomManager.h"
#import "DateManager.h"
#import "NSString+Utils.h"
#import "Common.h"

@interface ChallengePlayViewController ()

@end

@implementation ChallengePlayViewController

@synthesize swipedCell = _swipedCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
        [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
        
        [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
        [backButtonRegion addSubview:backButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
        
        self.title = LANGUAGE(@"challenge_list_title");

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    currPageNo = 0;
    moreAvailable = NO;
    [challengeplays removeAllObjects];
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
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    challengeplays = [[NSMutableArray alloc] init];
    
    moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 50)];
    [moreView startAnimating];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    challengeplays = [[NSMutableArray alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (challengeplays.count > 0) {
        return  moreAvailable? challengeplays.count + 1: challengeplays.count;
    } else
        return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH / 2 + 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == challengeplays.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"More"];
        [cell.contentView addSubview:moreView];
        
        if (!loading)
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:2.f];
        return cell;
    }
        
    if (challengeplays.count == 0){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.text = @"No data";
        return cell;
    }
    
    ChallengeListRecord *record;
    record = (ChallengeListRecord *)[challengeplays objectAtIndex:indexPath.row];
    NSString *CellIdentifier = @"CellChallenge"; //Modified By Boss.2015/06/05
    ChallengePlayViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    if(cell == nil){
        cell = [[ChallengePlayViewCell alloc] initMyChallengeWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell dataWithChallengeRecord:record];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return sourceIndexPath;
}

#pragma Events
- (void)refresh
{
    currPageNo = 0;
    moreAvailable = NO;
    [challengeplays removeAllObjects];
    [self loadMore];
    [self.refreshControl endRefreshing];
}

#pragma UserDefinded
- (void)loadMore
{
    loading = YES;
    currPageNo ++;
    NSString *strClubIDs = @"";
    for (NSDictionary *item in CLUBS) {
        if ([strClubIDs isEqual: @""])
            strClubIDs = [item valueForKey:@"club_id"];
        else
            strClubIDs = [NSString stringWithFormat:@"%@:%@", strClubIDs, [item valueForKey:@"club_id"]];
    }
    NSMutableArray *array = [NSMutableArray arrayWithObjects:strClubIDs,
                             [NSNumber numberWithInt:0],
                             [NSNumber numberWithInt:currPageNo],
                             [NSNumber numberWithInt:0], nil];
    [[HttpManager newInstance] browseChallengeListWithDelegate:self data:array];
}


#pragma ChallengePlayViewCellDelegate
- (void)gotoClubDetail:(ChallengePlayViewCell *)cell clubID:(int)c_id
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubDetailController alloc] initWithClub:c_id fromClubCenter:NO] animated:YES];
}

#pragma ChallengePlayViewCellDelegate
- (void)gotoChallengeDiscuss:(ChallengePlayViewCell *)cell withArrowView:(ChallengeItemView *)arrowView
{
    if (ADMINCLUBCOUNT == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    agreeMode = NO;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int nSendClub = [[challengeplays objectAtIndex:indexPath.row] intWithSendClubID];
    
    if ([[ClubManager sharedInstance] checkAdminClub:nSendClub])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"manager_club")];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:indexPath.row] forKey:@"DISCUSSINDEX"];
    
#ifdef DEMO_MODE
    NSLog(@"%@ 매니저구락부개수 %d", LOGTAG, ADMINCLUBCOUNT);
#endif
    
    if (ADMINCLUBCOUNT == 1)
    {
        [self clubSelectClick:[[[ADMINCLUBS objectAtIndex:0] objectForKey:@"club_id"] intValue]];
        [_swipedCell closeMenu];
        return;
    }
    
    [self showSelectAdminClub:arrowView];
}

#pragma ChallengePlayViewCellDelegate
- (void)recommandToClubRoom:(ChallengePlayViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int nSendClub = [[challengeplays objectAtIndex:indexPath.row] intWithSendClubID];
    
    if (CLUBCOUNT == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no club belongs to you")];
        return;
    }
    
    if ([[ClubManager sharedInstance] checkMyClub:nSendClub])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"manager_club")];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"CHALLENGEPLAYVC_CHALLENGERECORD"]; //Added By Boss.2015/06/06
    [[NSUserDefaults standardUserDefaults] setObject:[[challengeplays objectAtIndex:indexPath.row] stringWithSendClubName] forKey:@"CHALLENGEPLAYVC_SENDCLUB"];
    
    if (CLUBCOUNT == 1)
    {
        [self multiTeamSelected:[NSArray arrayWithObjects:[[CLUBS objectAtIndex:0] objectForKey:@"club_id"], nil]];
        return;
    }
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[TeamSelectController alloc] initNormalMultiSelectModeWithDelegate:self] animated:YES];
}

#pragma ChallengePlayViewCellDelegate
- (void)agreeGame:(ChallengePlayViewCell *)cell withArrowView:(ChallengeItemView *)arrowView
{
    if (ADMINCLUBCOUNT == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    agreeMode = YES;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int nSendClub = [[challengeplays objectAtIndex:indexPath.row] intWithSendClubID];
    
    if ([[ClubManager sharedInstance] checkAdminClub:nSendClub])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"manager_club")];
        return;
    }
    
    
    int gameID = [[challengeplays objectAtIndex:indexPath.row] intWithGameID];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:gameID] forKey:@"AGREEGAMEID"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:indexPath.row] forKey:@"AGREEINDEX"];
    
    if (ADMINCLUBCOUNT == 1)
    {
        [self clubSelectClick:[[[ADMINCLUBS objectAtIndex:0] objectForKey:@"club_id"] intValue]];
        return;
    }
    
    [self showSelectAdminClub:arrowView];
}

#pragma ChallengePlayViewCellDelegate
- (void)menuDidShowInCell:(ChallengePlayViewCell *)cell
{
    if (![self.swipedCell isEqual:cell])
        [self hideMenuOptionsAnimated:YES];
    
    self.swipedCell = cell;
}

#pragma ChallengePlayViewDelegate
- (void)menuDidHideInCell
{
    self.swipedCell = nil;
}

- (void)showSelectAdminClub:(UIView *)fromView
{
    self.popover = nil;
    
    //the controller we want to present as a popover
    ClubSelectController *controller = [[ClubSelectController alloc] initWithStyle:UITableViewStylePlain];
    controller.delegate = self;
    controller.title = nil;
    
    self.popover = [[FPPopoverController alloc] initWithViewController:controller];
    self.popover.tint = FPPopoverDefaultTint;
    self.popover.contentSize = CGSizeMake(200, ADMINCLUBCOUNT * 40 > SCREEN_WIDTH / 2? SCREEN_WIDTH / 2: ADMINCLUBCOUNT * 40);
    
    self.popover.arrowDirection = FPPopoverArrowDirectionAny;
    [self.popover presentPopoverFromPoint: CGPointMake(self.view.center.x, self.view.center.y - self.popover.contentSize.height/2)];
    
    [self.popover presentPopoverFromView:fromView];

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
    [challengeplays addObjectsFromArray:data];
    [self.tableView reloadData];
}

- (void)agreeGameWithErrorCode:(int)errorCode withRoomID:(int)roomID withRoomName:(NSString *)roomStr
{
    [AlertManager HideWaiting];
    
    if (errorCode > 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorCode])];
    }
    else{
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];

        int index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AGREEINDEX"] intValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        [challengeplays removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [[DiscussRoomManager sharedInstance] addDiscussChatRoom:roomID roomTitles:roomStr];
        
        //상대구락부어디민에게 상의마당창조를 알린다
        //[self sendMsgToCreateNewDiscussRoom:roomID msg:roomStr];

    }
}

/* 기능: 상의마당창조를 통지하는 함수
   파람: nRoomID - 상의마당아이디
        msg - 상의마당정보문자렬
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
    message.readState = 1;
    message.sendState = CHATENABLE? 1 : 0;
    [[Chat sharedInstance] sendChatMessage: message withDelegate:nil];
    
    message.msg = LANGUAGE(@"challenge_talk");
    [[Chat sharedInstance] sendChatMessage: message withDelegate:nil];
    [ChatMessage addChatMessage:message];
}

#pragma HttpManagerDelegate
- (void)createDiscussChatRoomWithErrorCode:(int)errorcode withRoom:(int)r_id withRoomName:(NSString *)roomName
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no chatting room")];
        [Common BackToPage];
    }
    else{
        int row = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DISCUSSINDEX"] intValue];
        ChallengeListRecord *gameInfo = [challengeplays objectAtIndex:row];

        int nRoomID = r_id;
        NSArray *array = [roomName componentsSeparatedByString:@"::"];
        int team1 = [[array objectAtIndex:0] intValue];
        int team2 = [[array objectAtIndex:2] intValue];
        int nMineClub = [[ClubManager sharedInstance] checkAdminClub:team1]? team1: team2;
        
        [[DiscussRoomManager sharedInstance] addDiscussChatRoom:r_id roomTitles:roomName];
        
        ggaAppDelegate *appDelegate = APP_DELEGATE;
        [appDelegate.ggaNav pushViewController:[[ClubRoomViewController alloc] initWithNibName:@"ClubRoomViewController" gameInfo:gameInfo type:GAME_TYPE_CHALLENGE clubID:nMineClub roomID:nRoomID] animated:YES];
        
        //Send message "create new discuss room"
        //[self sendMsgToCreateNewDiscussRoom:nRoomID msg:roomName];
    }
}


#pragma ClubSelectControllerDelegate
- (void)clubSelectClick:(int)club
{
    [self.popover dismissPopoverAnimated:YES];
    [_swipedCell closeMenu];
    
    if (agreeMode) //AgreeGame
    {
        [AlertManager WaitingWithMessage];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:club] forKey:@"AGREECLUBID"];
        
        int nGameId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AGREEGAMEID"] intValue];
        NSArray *data = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", nGameId],
                         [NSString stringWithFormat:@"%d", club],
                         [NSString stringWithFormat:@"%d", 0], nil];
        
        [[HttpManager newInstance] agreeGameWithDelegate:self data:data];
    }
    else //ChallengeDiscussRoom
    {
        int row = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DISCUSSINDEX"] intValue];

        ChallengeListRecord *gameInfo = [challengeplays objectAtIndex:row];
        
        int nSendClub = [gameInfo intWithSendClubID];
        int nRecvClub = club;
        int nGameID = [gameInfo intWithGameID];
        NSString *players = [NSString stringWithFormat:@"%d", [gameInfo intWithPlayers]];
        
        //if DiscussChattingRoom exists, enter the room
        int nRoomID = [[DiscussRoomManager sharedInstance] discussRoomIDWithSendID:nSendClub recvID:nRecvClub gameID:nGameID gametype:GAME_TYPE_CHALLENGE];
        if (nRoomID != -1)
        {
            int row = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DISCUSSINDEX"] intValue];
            ChallengeListRecord *gameInfo = [challengeplays objectAtIndex:row];
            ggaAppDelegate *appDelegate = APP_DELEGATE;
            [appDelegate.ggaNav pushViewController:[[ClubRoomViewController alloc] initWithNibName:@"ClubRoomViewController" gameInfo:gameInfo type:GAME_TYPE_CHALLENGE clubID:club roomID:nRoomID] animated:YES];

            return;
        }

        [AlertManager WaitingWithMessage];
        
        //if not exits, create chattingroom
        NSArray *data = [NSArray arrayWithObjects:
                        [NSNumber numberWithInt:nSendClub],
                        [NSNumber numberWithInt:club],
                        [NSNumber numberWithInt:nGameID],
                         players,
                        nil];
            
        [[HttpManager sharedInstance] createDiscussChatRoomWithDelegate:self data:data];
        
    }
}

#pragma TeamSelectControllerDelegate
- (void)multiTeamSelected:(NSArray *)teams
{
    NSString *sendClub = [[NSUserDefaults standardUserDefaults] valueForKey:@"CHALLENGEPLAYVC_SENDCLUB"];
    NSInteger nsIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"CHALLENGEPLAYVC_CHALLENGERECORD"];
    
    ChallengeListRecord *challengeRecord = (ChallengeListRecord *)[challengeplays objectAtIndex:nsIndex];
    
    for (int i=0; i<teams.count; i++)
    {
        NSNumber *item = [teams objectAtIndex:i];
        int room = [[ClubManager sharedInstance] intRoomIDWithClubID:[item intValue]];
        
        NSString *msg = @"";
        @try {
            msg = [NSString stringWithFormat:@"%@%@\r\n%@:%@\r\n%@ %@",
                         LANGUAGE(@"myrecommend"),
                         LANGUAGE(@"challenge"),
                         LANGUAGE(@"sendteam"),
                         sendClub,
                         [challengeRecord stringWithPlayDate],
                         [challengeRecord stringWithPlayTime]
                         ];
        } @catch (NSException *exception) {
            NSLog(@"Recommend Error:%@", exception);
            break;
        }
        
        ChatMessage *message = [[ChatMessage alloc] init];
        
        message.type = 1;     //text
        message.senderId = UID;
        message.roomId   = room;
        message.userPhoto = USERPHOTO;
        message.msg = msg;
        message.senderName = USERNAME;
        message.sendTime   = curSystemTimeStr;
        message.readState = 1;
        message.sendState = CHATENABLE? 1 : 0;
        
        [[Chat sharedInstance] sendChatMessage: message withDelegate:nil];
        [ChatMessage addChatMessage:message];
    }
    
    if (CHATENABLE)
        [AlertManager AlertWithMessage:LANGUAGE(@"recommend_success")];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"recommend_failed")];

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

- (void)backToPage
{
    [Common BackToPage];
}
@end
