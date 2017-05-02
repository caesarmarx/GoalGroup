//
//  PlayerMarketController.m
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "PlayerMarketController.h"
#import "PlayerMarkectItemView.h"
#import "PlayerDetailController.h"
#import "GameScheduleController.h"
#import "PlayerListRecord.h"
#import "NSPosition.h"
#import "NSWeek.h"
#import "DistrictManager.h"
#import "Common.h"
#import "ChatMessage.h"
#import "DateManager.h"
#import "NSString+Utils.h"
#import "Chat.h"

@interface PlayerMarketController ()
{
    NSArray *conditionArray;
}
@end

@implementation PlayerMarketController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LANGUAGE(@"PLAYER_MARKET_TITLE");
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif

    [self layoutComponents];
    
    
    _searchResult = [[NSMutableArray alloc] init];
    
    _moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 50)];
    [_moreView startAnimating];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
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

- (void)viewWillAppear:(BOOL)animated
{
    _currPageNo = 0;
    _moreAvailable = NO;
    [_searchResult removeAllObjects];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadMore];
}

- (void)viewWillDisappear:(BOOL)animated
{
    _loading = NO;
}

- (void)layoutComponents
{
    
    self.view.backgroundColor = [UIColor whiteColor];

    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];

    UIView *searchButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 26)];
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 28, 27)];
    [searchButton setImage: [UIImage imageNamed:@"search_ico"] forState:UIControlStateNormal];

    [searchButton addTarget:self action:@selector(showSearchView:) forControlEvents:UIControlEventTouchDown];
    [searchButtonRegion addSubview:searchButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButtonRegion];

}

- (void)showSearchView:(id)sender
{
    self.navigationController.navigationBarHidden = YES;
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    PlayerSearchConditionController *pscVC = [PlayerSearchConditionController sharedInstance];
    pscVC.delegate = self;
    [appDelegate.ggaNav pushViewController:pscVC animated:YES];
}

- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searchResult.count > 0)
        return _moreAvailable? [_searchResult count] + 1: [_searchResult count];
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _searchResult.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"More"];
        [cell.contentView addSubview:_moreView];
        
        if (!_loading)
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:2.f];
        return cell;
    }
    
    if (_searchResult.count == 0)
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    PlayerListRecord *record;
    record = (PlayerListRecord *)[_searchResult objectAtIndex:indexPath.row];
    
    NSString *CellIdentifier = @"PlayerMarketItemCell";
    PlayerMarkectItemView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
        cell = [[PlayerMarkectItemView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    [cell drawPlayerWithRecord:[_searchResult objectAtIndex:indexPath.row]];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideMenuOptionsAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

#pragma UserDefined
- (void)loadMore
{
    _loading = YES;
    _currPageNo ++;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_currPageNo] forKey:@"SEARCHPLAYER_PAGENO"];
    
    if (conditionArray == nil)
        conditionArray = [[NSArray alloc] init];
    
    [[HttpManager sharedInstance] searchPlayerWithDelegate:self withCondition:conditionArray];
}

- (void)refresh
{
    _currPageNo = 0;
    _moreAvailable = NO;
    [_searchResult removeAllObjects];
    [self loadMore];
    [self.refreshControl endRefreshing];
}

- (void)showPopoverMenu:(PlayerMarkectItemView *)cell withFromView:(UIView *)view
{
    ClubSelectController *controller = [[ClubSelectController alloc] initWithStyle:UITableViewStylePlain];
    controller.delegate = self;
    controller.title = nil;
    
    self.popover = [[FPPopoverController alloc] initWithViewController:controller];
    self.popover.tint = FPPopoverDefaultTint;
    self.popover.contentSize = CGSizeMake(200, ADMINCLUBCOUNT * 40 > SCREEN_WIDTH / 2? SCREEN_WIDTH / 2: ADMINCLUBCOUNT * 40);
    self.popover.arrowDirection = FPPopoverArrowDirectionAny;
    [self.popover presentPopoverFromPoint:CGPointMake(self.view.center.x, self.view.center.y - self.popover.contentSize.height / 2)];
    [self.popover presentPopoverFromView:view];
}

- (void)showGameScheduleController
{
    int club = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PLAYERMARKET_TEMPINVITECLUB"] intValue];
    GameScheduleController *vc = [GameScheduleController sharedInstance];
    [vc selectMode:YES withClubID:club];
    vc.delegate = self;
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

- (void)getCheckMemberAndClubSchedulecount:(int)club
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:club] forKey:@"PLAYERMARKET_TEMPINVITECLUB"];
    int nPlayer = [[[NSUserDefaults standardUserDefaults] objectForKey:@"INVITE_PLAYERID"] intValue];
    
    NSArray *array = [NSArray arrayWithObjects:
                      [NSNumber numberWithInt:nPlayer],
                      [NSNumber numberWithInt:club],
                      nil];
    [AlertManager WaitingWithMessage];
    [[HttpManager sharedInstance] getCheckMemberAndClubScheduleCountWithDelegate:self data:array];
}

#pragma PlayerMarketItemViewDelegate
-(void)doClickRecommend:(PlayerMarkectItemView *)cell{
    [self hideMenuOptionsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *playerName = [[_searchResult objectAtIndex:indexPath.row] stringWithPlayerName];
    
    int playerId = [[_searchResult objectAtIndex:indexPath.row] intWithPlayerID];
    int uid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LOGIN_DATA_UID"] intValue];
    if (playerId == uid)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"you can't recommend yourself")];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"RECOMMEND_MODE" forKey:@"TEAMSELECTMODE"];
    [[NSUserDefaults standardUserDefaults] setObject:playerName forKey:@"RECOMMAND_PLAYERNAME"];
	
    if (CLUBCOUNT == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no club belongs to you")];
        return;
    }
	if (CLUBCOUNT == 1)
    {
        [self multiTeamSelected:[NSArray arrayWithObjects:[[CLUBS objectAtIndex:0] objectForKey:@"club_id"], nil]];
        return;
    }
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[TeamSelectController alloc] initNormalMultiSelectModeWithDelegate:self] animated:YES];
}

#pragma PlayerMarketItemViewDelegate
-(void)doClickTempInvite:(PlayerMarkectItemView *)cell withFromView:(UIView *)view
{
    [self hideMenuOptionsAnimated:YES];
    
    if (ADMINCLUBCOUNT == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int nPlayerID = [[_searchResult objectAtIndex:indexPath.row] intWithPlayerID];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nPlayerID] forKey:@"INVITE_PLAYERID"];
    
    if (nPlayerID == UID)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"sorry, cannot operate on you")];
        return;
    }
    
    if (ADMINCLUBCOUNT == 1)
    {
        int club = [[[ADMINCLUBS objectAtIndex:0] valueForKey:@"club_id"] intValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:club] forKey:@"CLUBDETAIL_CLUBID"];
        [self getCheckMemberAndClubSchedulecount:club];
        return;
    }
    
    [self showPopoverMenu:cell withFromView:view];
}

#pragma PlayerMarketItemViewDelegate
-(void)doClickInvite:(PlayerMarkectItemView *)cell withFromView:(UIView *)view
{
    [self hideMenuOptionsAnimated:YES];

    if (ADMINCLUBCOUNT == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int nPlayerID = [[_searchResult objectAtIndex:indexPath.row] intWithPlayerID];
    
    if (nPlayerID == UID) {
        [AlertManager AlertWithMessage:LANGUAGE(@"sorry, cannot operate on you")];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nPlayerID] forKey:@"INVITE_PLAYERID"];
    [[NSUserDefaults standardUserDefaults] setObject:@"INVITE_MODE" forKey:@"TEAMSELECTMODE"];
    
    if (ADMINCLUBCOUNT == 1)
    {
        [AlertManager WaitingWithMessage];
        
        int club = [[[ADMINCLUBS objectAtIndex:0] valueForKey:@"club_id"] intValue];
        
        NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:nPlayerID],
                         [NSNumber numberWithInt:club],
                         nil];
        [[HttpManager sharedInstance] sendInvRequestWithDelegate:self data:data];
        return;
    }
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[TeamSelectController alloc] initAdminMutliSelectModeWithDelegate:self] animated:YES];
    
}

#pragma PlayerMarketItemViewDelegate
- (void)doClickPlayerDetail:(PlayerMarkectItemView *)cell
{
    [self hideMenuOptionsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int nPlayID = [[_searchResult objectAtIndex:indexPath.row] intWithPlayerID];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[PlayerDetailController alloc] initWithPlayerID:nPlayID showInviteButton:YES] animated:YES];
}

#pragma HttpManagerDelegate
- (void)searchPlayerResultWithErrorCode:(int)errorCode dataMore:(int)more data:(NSArray *)data
{
    if (!_loading)
        return;
    _loading = NO;
    _moreAvailable = more == 1;
    
    [_searchResult addObjectsFromArray:data];
    [self.tableView reloadData];
}

#pragma HttpManagerDelegate
- (void)sendInvRequestResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
    
    [self.swipedCell closeMenu];
}

#pragma HttpManagerDelegate
- (void)sendTempInvRequestResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
    
    [self.swipedCell closeMenu];
}

- (void)getCheckMemberAndClubScheduleCountResultWithErrorCode:(int)errorcode count:(int)count check:(int)checked
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:[Language stringWithInteger:errorcode]];
    else
    {
        if (checked == 1)
        {
            [AlertManager AlertWithMessage:LANGUAGE(@"HeIsClubMember")];
            return;
        }
        
        if (count == 0)
        {
            [AlertManager AlertWithMessage:LANGUAGE(@"the club has no schedules")];
            return;
        }
        
        [self showGameScheduleController];
    }
}

#pragma ClubSelectControllerDelegate
- (void)clubSelectClick:(int)club
{
    [self.popover dismissPopoverAnimated:YES];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:club] forKey:@"CLUBDETAIL_CLUBID"];
    [self getCheckMemberAndClubSchedulecount:club];
}

#pragma GameScheduleControllerDelegate
- (void)gameScheduleItemClick:(GameScheduleRecord *)record
{
    [_swipedCell closeMenu];
    [AlertManager WaitingWithMessage];
    
    int nPlayerID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"INVITE_PLAYERID"] intValue];
    int nClubID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CLUBDETAIL_CLUBID"] intValue];
    int nGameID = [record intWithGameListID];

    NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:nPlayerID],
                     [NSNumber numberWithInt:nClubID],
                     [NSNumber numberWithInt:nGameID],
                     @"",
                     nil];
    [[HttpManager sharedInstance] sendTempInvRequestWithDelegate:self data:data];
}

#pragma TeamSelectControllerDelegate
- (void)multiTeamSelected:(NSArray *)teams
{
    [_swipedCell closeMenu];
    NSString *mode = [[NSUserDefaults standardUserDefaults] objectForKey:@"TEAMSELECTMODE"];
    
    if ([mode isEqualToString:@"INVITE_MODE"])
    {
        [AlertManager WaitingWithMessage];
        int nPlayerID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"INVITE_PLAYERID"] intValue];
        
        NSString *tmp = @"";
        for (int i = 0; i < teams.count; i ++) {
            if ([tmp isEqualToString:@""])
                tmp = [NSString stringWithFormat:@"%@", [teams objectAtIndex:i]];
            else
                tmp = [NSString stringWithFormat:@"%@,%@", tmp, [teams objectAtIndex:i]];
        }
        
        NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:nPlayerID],
                         tmp,
                         nil];
        [[HttpManager sharedInstance] sendInvRequestWithDelegate:self data:data];
    }
    else
    {
        //add chatting code
        NSString *playerName = [[NSUserDefaults standardUserDefaults] objectForKey:@"RECOMMAND_PLAYERNAME"];
        
        for (NSNumber *item in teams) {
            int room = [[ClubManager sharedInstance] intRoomIDWithClubID:[item intValue]];
            
            NSString *msg = [NSString stringWithFormat:@"%@%@。\r\n%@",
                             LANGUAGE(@"myrecommend"),
                             LANGUAGE(@"member"),
                             playerName
                             ];
            
            ChatMessage *message = [[ChatMessage alloc] init];
            
            message.type = 1;     //text
            message.senderId = UID;
            message.roomId   = room;
            message.userPhoto = USERPHOTO;
            message.msg = msg;
            message.senderName = USERNAME;
            message.readState = 1;
            message.sendState = CHATENABLE? 1 : 0;
            message.sendTime   = curSystemTimeStr;
            
            [[Chat sharedInstance] sendChatMessage: message withDelegate:nil];
            [ChatMessage addChatMessage:message];
        }
        
        if (CHATENABLE)
            [AlertManager AlertWithMessage:LANGUAGE(@"recommend_success")];
        else
            [AlertManager AlertWithMessage:LANGUAGE(@"recommend_failed")];


    }
}

#pragma PlayerMarketItemViewDelegate
- (void)menuDidShowInCell:(PlayerMarkectItemView *)cell
{
    if (![self.swipedCell isEqual:cell])
        [self hideMenuOptionsAnimated:YES];
    
    self.swipedCell = cell;
}

#pragma PlayerMarketItemViewDelegate
- (void)menuDidHideInCell
{
    self.swipedCell = nil;
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

- (void)playerSearchWithCondition:(NSArray *)array
{
    conditionArray = [NSArray arrayWithArray:array];
    _currPageNo = 0;
    _moreAvailable = NO;
    [_searchResult removeAllObjects];
    [self.tableView reloadData];

    _loading = YES;
}
@end
