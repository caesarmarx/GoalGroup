//
//  ClubMarketController.m
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubMarketController.h"
#import "ClubDetailController.h"
#import "MakingChallengeController.h"

@interface ClubMarketController ()
{
    NSArray *condition;
}

@end

@implementation ClubMarketController
{
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
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif

    self.title = LANGUAGE(@"club center");
    [self layoutComponents];
    
    _searchResult = [[NSMutableArray alloc] init];
    
    _moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 50)];
    [_moreView startAnimating];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    if (currentOffset.x == 0.f && currentOffset.y <= 0.0f) {
        [scrollView setContentOffset:CGPointMake(0.f, 0.f)];
    }
    
    [self hideMenuOptionsAnimated:YES];
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
    
    UIView *searchButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 27)];
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
    ClubSearchConditionController *cscVC = [ClubSearchConditionController sharedInstance];
    cscVC.delegate = self;
    [appDelegate.ggaNav pushViewController:cscVC animated:YES];
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
        return _moreAvailable? _searchResult.count + 1: _searchResult.count;
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
    
    ClubListRecord *record;
    record = (ClubListRecord *)[_searchResult objectAtIndex:indexPath.row];
    
    NSString *CellIdentifier = @"ClubMarketItemCell";
    ClubMarketItemView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[ClubMarketItemView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell drawClubWithRecord:[_searchResult objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)loadMore
{
    _currPageNo ++;
    _loading = YES;
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:(int)_currPageNo] forKey:@"SEARCHCLUB_PAGENO"];
    [[HttpManager sharedInstance] searchClubWithDelegate:self withCondition:condition];
}

- (void)refresh
{
    _currPageNo = 0;
    _loading = NO;
    [_searchResult removeAllObjects];
    [self loadMore];
    [self.refreshControl endRefreshing];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideMenuOptionsAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

#pragma ClubMarketItemViewDelegate
-(void)doClickJoin:(ClubMarketItemView *)cell
{
    [self hideMenuOptionsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    int nClubID = [[_searchResult objectAtIndex:indexPath.row] intWithClubID];
    if ([[ClubManager sharedInstance] checkMyClub:nClubID]) {
        [AlertManager AlertWithMessage:LANGUAGE(@"user exist in club")];
        return;
    }
    
    [AlertManager WaitingWithMessage];
    NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:UID],
                     [NSNumber numberWithInt:nClubID], nil];
    [[HttpManager sharedInstance] registerUserToClubWithDelegate:self data:data];
}

#pragma ClubMarketItemViewDelegate
-(void)doClickNotie:(ClubMarketItemView *)cell fromView:(UIView *)view
{
    [self hideMenuOptionsAnimated:YES];
    
    if (ADMINCLUBCOUNT == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int nClubID = [[_searchResult objectAtIndex:indexPath.row] intWithClubID];

    if ([[ClubManager sharedInstance] checkAdminClub:nClubID]) {
        [AlertManager AlertWithMessage:LANGUAGE(@"manager_club")];
        return;
    }

    NSString *strClubName = [[_searchResult objectAtIndex:indexPath.row] stringWithClubName];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[MakingChallengeController alloc] initWithNoticeTeam:nClubID name:strClubName] animated:YES];
    [_swipedCell closeMenu];
}

#pragma Event
- (void)doClickClubDetail:(ClubMarketItemView *)cell
{
    [self hideMenuOptionsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ClubListRecord *record = [_searchResult objectAtIndex:indexPath.row];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubDetailController alloc] initWithClub:[record intWithClubID] fromClubCenter:YES] animated:YES];
}

#pragma HttpManagerDelegate
- (void)searchClubResultWithErrorCode:(int)errorCode dataMore:(int)more data:(NSArray *)data
{
    if (!_loading)
        return;
    _loading = NO;
    _moreAvailable = more == 1;
    [_searchResult addObjectsFromArray:data];
    [self.tableView reloadData];
}

#pragma HttpManagerDelegate
- (void)registerUserToClubResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode == 0)
        [AlertManager AlertWithMessage:LANGUAGE(@"register UserToClub success")];
    else
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    [_swipedCell closeMenu];
}

#pragma ClubMarketItemViewDelegate
- (void)menuDidShowInCell:(ClubMarketItemView *)cell
{
    if (![self.swipedCell isEqual:cell])
        [self hideMenuOptionsAnimated:YES];
    
    self.swipedCell = cell;
}

#pragma ClubMarketItemViewDelegate
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

- (void)clubSearchWithCondition:(NSArray *)cond
{
    condition = [NSArray arrayWithArray:cond];
    _currPageNo = 0;
    _moreAvailable = NO;
    [_searchResult removeAllObjects];
    [self.tableView reloadData];
    
    _loading = YES;
}

@end
