//
//  GameScheduleController.m
//  GoalGroup
//
//  Created by KCHN on 2/13/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "GameScheduleController.h"
#import "GameScheduleViewCell.h"
#import "ClubRoomViewController.h"
#import "ClubMemberListController.h"
#import "ChallengeListRecord.h"
#import "GameDetailController.h"
#import "ClubDetailController.h"
#import "DiscussRoomManager.h"
#import "Common.h"

@interface GameScheduleController ()
@end

@implementation GameScheduleController

+ (GameScheduleController *)sharedInstance
{
    @synchronized(self)
    {
        if (gGameScheduleController == nil)
            gGameScheduleController = [[GameScheduleController alloc] init];
        
    }
    return gGameScheduleController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    currPageNo = 0;
    moreAvailable = NO;
    [schedules removeAllObjects];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 15.0f)];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView reloadData];
    [self hideMenuOptionsAnimated:YES]; //Added By Boss.2015/05/15
    
    self.title = _selectModeBeforeJoin? LANGUAGE(@"GAME REPORT"): [NSString stringWithFormat:@"%@-%@", [[ClubManager sharedInstance] stringClubNameWithID:nClubID], LANGUAGE(@"GAME REPORT")];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadmore];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif

    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    
    schedules = [[NSMutableArray alloc] init];
    
    moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 50)];
    [moreView startAnimating];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillDisappear:(BOOL)animated
{
    loading = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    if (currentOffset.x == 0.f && currentOffset.y <= 0.0f) {
        [scrollView setContentOffset:CGPointMake(0.f, 0.f)];
    }
    
    [self hideMenuOptionsAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (schedules.count > 0)
        return moreAvailable? schedules.count + 1:schedules.count;
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == schedules.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"More"];
        [cell.contentView addSubview:moreView];
        
        if(!loading)
            [self performSelector:@selector(loadmore) withObject:nil afterDelay:2.f];
        return cell;
    }
    
    if (schedules.count == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.text = @"No data";
        return cell;
    }
    
    NSString *CellIdentifier = @"CellGameSchedule";
    GameScheduleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    GameScheduleRecord *record = [schedules objectAtIndex:indexPath.section];
    if(cell == nil)
        cell = [[GameScheduleViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    cell.mode  =_selectModeBeforeJoin;
    cell.nMineClub = nClubID;
    [cell drawWithGameScheduleRecord:record];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
                
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
        return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH / 2.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hideMenuOptionsAnimated:YES];
    
    if (_selectModeBeforeJoin)
    {
        GameScheduleRecord *record = [schedules objectAtIndex:indexPath.section];
        [self.delegate gameScheduleItemClick:record];
        [Common BackToPage];
    }
    else
    {
        GameScheduleRecord *schd = [schedules objectAtIndex:indexPath.section];
        
        NSString *time = [schd intWithVsStatus] >= 3? [schd stringWithGameResult] : [schd stringWithGameTime];
        ChallengeListRecord *gameInfo = [[ChallengeListRecord alloc] initWithSendClubName:[schd stringWithHomeName]
                                                                             sendImageUrl:[schd stringWithHomeUrl]
                                                                             recvClubName:[schd stringWithAwayName]
                                                                             recvImageUrl:[schd stringWithAwayUrl]
                                                                             playerNumber:[schd intwithPlayerMode]
                                                                                 playDate:[schd stringWithGameDate]
                                                                                  playDay:[schd intWithGameDay]
                                                                                 playTime:time
                                                                          playStadiumArea:[schd stringWithStadiumArea]
                                                                       playStadiumAddress:[schd stringWithStadiumAddress]
                                                                               sendClubID:[schd intWithHomeID]
                                                                               recvClubID:[schd intWithAwayID]
                                                                                   gameID:[schd intWithGameListID]
                                                                             tempInvState:0
                                                                                 vcStatus:[schd intWithVsStatus]
                                                                                tempUnread:NO];

        ggaAppDelegate *appDelegate = APP_DELEGATE;
        [appDelegate.ggaNav pushViewController:[GameDetailController sharedInstance:gameInfo club:nClubID] animated:YES];
    }
}

#pragma UserDefined
- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

#pragma Events
- (void)refresh
{
    currPageNo = 0;
    moreAvailable = NO;
    [schedules removeAllObjects];
    [self loadmore];
    [self.refreshControl endRefreshing];
}

#pragma UserDefined
- (void)loadmore
{
    loading = YES;
    currPageNo ++;

    NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:nClubID],
                     [NSNumber numberWithInt:currPageNo],
                     [NSNumber numberWithInt:_selectModeBeforeJoin? 1: 0],
                     nil];
    [[HttpManager sharedInstance] browseScheduleWithDelegate:self data:data];
}

#pragma UserDefined
- (void)selectMode:(BOOL)mode withClubID:(int)c_id
{
    _selectModeBeforeJoin = mode;
    nClubID = c_id;
}

#pragma HttpManagerDelegate
- (void)browseScheduleResultwithErrorCode:(int)errorcode dataMore:(int)more data:(NSArray *)data
{
    if (loading == NO)
        return;
    loading = NO;
    moreAvailable = more == 1;
    
    if (_selectModeBeforeJoin)
    {
        for (GameScheduleRecord *record in data) {
            if ([record intWithVsStatus] == GAME_STATUS_DELAY && [record intWithGameType] != GAME_TYPE_CUSTOM)
                [schedules addObject:record];
        }
    }
    else
        [schedules addObjectsFromArray:data];
    
    [self.tableView reloadData];

}

#pragma HttpManagerDelegate
- (void)applyGameResultWithErrorCode:(int)errorcode{
    [AlertManager HideWaiting];
    
    int index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GAMESCHEDULE_APPLYINDEX"] intValue];
    GameScheduleRecord *record = [schedules objectAtIndex:index];

    if (errorcode == 0)
        [AlertManager AlertWithMessage:LANGUAGE(@"apply game failed")];
    else if (errorcode == 3)
        [AlertManager AlertWithMessage:LANGUAGE(@"game is cancelled")];
    else if (errorcode == 4)
    {
        //다른 구락부성원으로 응모됨.
        
        NSString *otherName = @"";
        int nSendClub = [record intWithHomeID];
        int nRecvClub = [record intWithAwayID];
        
        if (nSendClub == nClubID)
            otherName = [[ClubManager sharedInstance] stringClubNameWithID:nRecvClub];
        else
            otherName = [[ClubManager sharedInstance] stringClubNameWithID:nSendClub];
        
        NSString *msg = [NSString stringWithFormat:@"%@%@%@", LANGUAGE(@"joined in other team already prefix"), otherName, LANGUAGE(@"joined in other team already suffix")];
        [AlertManager AlertWithMessage:msg];
    }
    else
    {
        //응모 및 응모취소 성공.
        if (errorcode == 1)
            [AlertManager AlertWithMessage:LANGUAGE(@"apply game success")];
        else
            [AlertManager AlertWithMessage:LANGUAGE(@"reject game success")];

        if ([record intWithAwayID] == nClubID) [record increaseAwayPlayer:errorcode];
        else [record increaseHomePlayer:errorcode];
        
        [self.tableView reloadData];
    }
}

#pragma GameScheduleViewCellDelegate
- (void)joinGameClick:(GameScheduleViewCell *)cell
{
    [self hideMenuOptionsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ([[schedules objectAtIndex:indexPath.section] intWithGameType] == GAME_TYPE_CUSTOM)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"cannot join game")];
        return;
    }

    switch ([[schedules objectAtIndex:indexPath.section] intWithVsStatus]) {
        case GAME_STATUS_DELAY:
            [self applyGame:indexPath];
            break;
        case GAME_STATUS_JOINFINISHED:
            [AlertManager AlertWithMessage:LANGUAGE(@"cannot join game")];
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

- (void)gotoDiscussRoomClick:(GameScheduleViewCell *)cell
{
    [self hideMenuOptionsAnimated:YES];
    
    if (![[ClubManager sharedInstance] checkAdminClub:nClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ([[schedules objectAtIndex:indexPath.section] intWithGameType] == GAME_TYPE_CUSTOM)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"this is custom game")];
        return;
    }
    
    if ([[schedules objectAtIndex:indexPath.section] intWithVsStatus] == GAME_STATUS_CANCELLED)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"game is cancelled")];
        return;
    }

    GameScheduleRecord *schd = [schedules objectAtIndex:indexPath.section];
    ChallengeListRecord *gameInfo = [[ChallengeListRecord alloc] initWithSendClubName:[schd stringWithHomeName]
                                                                         sendImageUrl:[schd stringWithHomeUrl]
                                                                         recvClubName:[schd stringWithAwayName]
                                                                         recvImageUrl:[schd stringWithAwayUrl]
                                                                         playerNumber:[schd intwithPlayerMode]
                                                                             playDate:[schd stringWithGameDate]
                                                                              playDay:[schd intWithGameDay]
                                                                             playTime:[schd stringWithGameTime]
                                                                      playStadiumArea:[schd stringWithStadiumArea]
                                                                   playStadiumAddress:[schd stringWithStadiumAddress]
                                                                           sendClubID:[schd intWithHomeID]
                                                                           recvClubID:[schd intWithAwayID]
                                                                               gameID:[schd intWithGameListID]
                                                                         tempInvState:0
                                                                             vcStatus:[schd intWithVsStatus]
                                                                            tempUnread:NO];
    
    int nSendClub = [schd intWithHomeID];
    int nRecvClub = [schd intWithAwayID];
    int nGameID = [schd intWithGameListID];
    int nRoomID = [[DiscussRoomManager sharedInstance] discussRoomIDWithSendID:nSendClub recvID:nRecvClub gameID:nGameID gametype:2];

    if (nRoomID != -1)
    {
        ggaAppDelegate *appDelegate = APP_DELEGATE;
        [appDelegate.ggaNav pushViewController:[[ClubRoomViewController alloc] initWithNibName:@"ClubRoomViewController" gameInfo:gameInfo type:2 clubID:nClubID roomID:nRoomID] animated:YES];
    }
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"failed")];
    
    [_swipedCell closeMenu];
}

- (void)sendClubPlayerClick:(GameScheduleViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ([[schedules objectAtIndex:indexPath.section] intWithGameType] == GAME_TYPE_CUSTOM)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"this is custom game")];
        return;
    }

    int nSelClubID = [[schedules objectAtIndex:indexPath.section] intWithHomeID];
    int nGameID = [[schedules objectAtIndex:indexPath.section] intWithGameListID];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubMemberListController alloc] initWithHttpMode:nSelClubID game:nGameID] animated:YES];
}

- (void)recvClubPlayerClick:(GameScheduleViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ([[schedules objectAtIndex:indexPath.section] intWithGameType] == GAME_TYPE_CUSTOM)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"this is custom game")];
        return;
    }

    int nSelClubID = [[schedules objectAtIndex:indexPath.section] intWithAwayID];
    int nGameID = [[schedules objectAtIndex:indexPath.section] intWithGameListID];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubMemberListController alloc] initWithHttpMode:nSelClubID game:nGameID] animated:YES];
}

- (void)applyGame:(NSIndexPath *)indexPath
{
    int nGameID = [[schedules objectAtIndex:indexPath.section] intWithGameListID];
    NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:nClubID], [NSNumber numberWithInt: nGameID], nil];
    
    [AlertManager WaitingWithMessage];
    [[HttpManager sharedInstance] applyGameWithDelegate:self data:data];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:indexPath.section] forKey:@"GAMESCHEDULE_APPLYINDEX"];
}

- (void)clubDetailClick:(GameScheduleViewCell *)cell send:(BOOL)sendClub
{
    [self hideMenuOptionsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    GameScheduleRecord *record = [schedules objectAtIndex:indexPath.section];
    
    int club = sendClub? [record intWithHomeID]: [record intWithAwayID];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubDetailController alloc] initWithClub:club fromClubCenter:NO] animated:YES];
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

#pragma GameScheduleViewCellDelegate
- (void)menuDidShowInCell:(GameScheduleViewCell *)cell
{
    if (![self.swipedCell isEqual:cell])
        [self hideMenuOptionsAnimated:YES];
    
    self.swipedCell = cell;
}

#pragma GameScheduleViewCellDelegate
- (void)menuDidHideInCell
{
    self.swipedCell = nil;
}

@end
