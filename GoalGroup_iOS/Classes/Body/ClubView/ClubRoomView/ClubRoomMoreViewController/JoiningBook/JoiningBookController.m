//
//  JoiningBookController.m
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "JoiningBookController.h"
#import "PlayerDetailController.h"
#import "PlayerListRecord.h"
#import "Common.h"

@interface JoiningBookController ()

@end

@implementation JoiningBookController

- (id)initWithClubID:(int)club
{
    nClubID = club;
    return [self init];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = [NSString stringWithFormat:@"%@-%@", [[ClubManager sharedInstance] stringClubNameWithID:nClubID], LANGUAGE(@"REGISTER_USER_TO_CLUB")];
        
        UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
        [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

        [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
        [backButtonRegion addSubview:backButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
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
    
    moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 50)];
    [moreView startAnimating];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    joinings = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadMore];
}

- (void)viewWillDisappear:(BOOL)animated
{
    loading = NO;
}
- (void)viewWillAppear:(BOOL)animated
{
    currPageNo = 0;
    moreAvailable = NO;
    [joinings removeAllObjects];
    [self.tableView reloadData];
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (joinings.count > 0)
        return moreAvailable ? joinings.count + 1 : joinings.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == joinings.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"More"];
        [cell.contentView addSubview:moreView];
        if (!loading)
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:2.f];
        return cell;
    }
    
    if (joinings.count == 0)
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    PlayerListRecord *record;
    record = (PlayerListRecord *)[joinings objectAtIndex:indexPath.row];
    NSString *CellIdentifier = @"CellJoiningBook";
    
    JoiningBookViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[JoiningBookViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell drawJoiningBookWithRecord:record];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

#pragma UserDefined
- (void)loadMore
{
    loading = YES;
    currPageNo ++;
    
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:nClubID],
                      [NSNumber numberWithInt:currPageNo],
                      nil];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currPageNo] forKey:@"REQMEMBER_PAGENO"];
    [[HttpManager newInstance] browseReqMemberListWithDelegate:self data:array];
}

- (void)refresh
{
    currPageNo = 0;
    moreAvailable = NO;
    [joinings removeAllObjects];
    [self loadMore];
    [self.refreshControl endRefreshing];
}

- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

#pragma JoiningBookViewCellDelegate
- (void)doClickDisagress:(JoiningBookViewCell *)cell
{
    if (![[ClubManager sharedInstance] checkAdminClub:nClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:indexPath.row] forKey:@"JOINLIST_ID"];
    int nPlayerID = [[joinings objectAtIndex:indexPath.row] intWithPlayerID];
    NSArray *param = [NSArray arrayWithObjects:[NSNumber numberWithInt:nPlayerID],
                      [NSNumber numberWithInt:2],
                      [NSNumber numberWithInt:nClubID],
                      nil];
    
    [AlertManager WaitingWithMessage];
    [[HttpManager sharedInstance] acceptReqestWithDelegate:self data:param];
}

- (void)doClickAgree:(JoiningBookViewCell *)cell
{
    if (![[ClubManager sharedInstance] checkAdminClub:nClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:indexPath.row] forKey:@"JOINLIST_ID"];
    int nPlayerID = [[joinings objectAtIndex:indexPath.row] intWithPlayerID];
    NSArray *param = [NSArray arrayWithObjects:[NSNumber numberWithInt:nPlayerID],
                      [NSNumber numberWithInt:1],
                      [NSNumber numberWithInt:nClubID],
                      nil];
    
    [AlertManager WaitingWithMessage];
    [[HttpManager sharedInstance] acceptReqestWithDelegate:self data:param];
}

- (void)doClickPlayerDetail:(JoiningBookViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int nPlayerID = [[joinings objectAtIndex:indexPath.row] intWithPlayerID];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[PlayerDetailController alloc] initWithPlayerID:nPlayerID showInviteButton:NO] animated:YES];
}

#pragma HttpManagerDelegate
- (void)browseReqMemberResultWithErrorCode:(int)errorcode dataMore:(int)more data:(NSArray *)data
{
    if (errorcode > 0)
        return;

    if (loading == NO)
            return;
        loading = NO;
        moreAvailable = more == 1;
        [joinings addObjectsFromArray:data];
        [self.tableView reloadData];
}

- (void)acceptRequestResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    if (errorcode > 0){
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    }
    else
    {
        int index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"JOINLIST_ID"] intValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [joinings removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
    }
}

#pragma JoiningBookViewCellDelegate
- (void)menuDidShowInCell:(JoiningBookViewCell *)cell
{
    if (![self.swipedCell isEqual:cell])
        [self hideMenuOptionsAnimated:YES];
    
    self.swipedCell = cell;
}

#pragma JoiningBookViewCellDelegate
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

@end
