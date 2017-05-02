//
//  ClubMemberListController.m
//  GoalGroup
//
//  Created by KCHN on 3/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubMemberListController.h"
#import "PlayerListRecord.h"
#import "ClubMemberListViewCell.h"
#import "PlayerDetailController.h"
#import "Common.h"

@interface ClubMemberListController ()
{
    int nClubID;
    int nGameID;
}
@end

@implementation ClubMemberListController

+ (ClubMemberListController *)sharedInstance
{
    @synchronized(self)
    {
        if (gClubMemberListController == nil)
            gClubMemberListController = [[ClubMemberListController alloc] init];
    }
    return gClubMemberListController;
}

- (id)initWithMembers:(NSMutableArray *)members delegate:(id)delegate chooseCorch:(BOOL)chooseCorch
{
    self = [super init];
    self.delegate = delegate;
    self.chooseCorch = chooseCorch;
    corchSelectMode = YES;
    players = [[NSMutableArray alloc] init];
    for (PlayerListRecord *record in members) {
        if ([record intWithTempState] != 1)
            [players addObject:record];
    }
    
    return self;
}

- (id)initWithHttpMode:(int)club game:(int)game
{
    nClubID = club;
    nGameID = game;
    players = [[NSMutableArray alloc] init];
    corchSelectMode = NO;
    return [self init];
}
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
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    self.title = self.chooseCorch? LANGUAGE(@"CLUB_TRAINING"): LANGUAGE(@"CLUB_LEADING");
    
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    
    moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 20)];
    [moreView startAnimating];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadMore];
}

- (void)viewWillAppear:(BOOL)animated
{
    currPageNo = 0;
    moreAvailable = NO;
    if (!corchSelectMode)
        [players removeAllObjects];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    loading = NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    if (currentOffset.x == 0.f && currentOffset.y <= 0.0f) {
        [scrollView setContentOffset:CGPointMake(0.f, 0.f)];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (players.count > 0)
        return moreAvailable? players.count + 1: players.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == players.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"more"];
        [cell.contentView addSubview:moreView];
        
        if (!loading)
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:2.f];
        return cell;
    }
    
    if (players.count == 0)
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    PlayerListRecord *record;
    record = (PlayerListRecord *)[players objectAtIndex:indexPath.row];
    NSString *CellIdentifier = @"CellClubMember";
    
    ClubMemberListViewCell *cell = [[ClubMemberListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.delegate = self;
    cell.corchSelectMode = corchSelectMode;
    [cell drawListWithData:record];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (corchSelectMode)
    {
        [self.delegate didSelectedWithRecord:(PlayerListRecord *)[players objectAtIndex:indexPath.row] chooseCorch:self.chooseCorch];
        [self backToPage];
    }
}

#pragma Event
- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

#pragma UserDefined
- (void)loadMore
{
    if (corchSelectMode)
        return;
    
    loading = YES;
    currPageNo ++;
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currPageNo] forKey:@"APPLYGAME_PAGENO"];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nClubID] forKey:@"APPLYGAME_CLUBID"];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nGameID] forKey:@"APPLYGAME_GAMEID"];
    
    NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:nClubID],
                     [NSNumber numberWithInt:nGameID],
                     [NSNumber numberWithInt:currPageNo],
                     nil];
    
    [[HttpManager sharedInstance] browseApplyGameListWithDelegate:self data:data];
}

- (void)refresh
{
    currPageNo ++;
    moreAvailable = NO;
    [players removeAllObjects];
    [self loadMore];
    [self.refreshControl endRefreshing];
}

#pragma HttpmanagerDelegate
- (void)browseApplyGameListWithErrorCode:(int)errorcode dataMore:(int)more data:(NSArray *)data
{
    if (!loading)
        return;
    loading = NO;
    moreAvailable = more == 1;
    [players addObjectsFromArray:data];
    [self.tableView reloadData];
}

#pragma ClubMemberListViewCell
- (void)memberIconClick:(ClubMemberListViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int nPlayerID = [[players objectAtIndex:indexPath.row] intWithPlayerID];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[PlayerDetailController alloc] initWithPlayerID:nPlayerID showInviteButton:NO] animated:YES];
}
@end
