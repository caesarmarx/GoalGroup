//
//  TempInvitionLetterController.m
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "TempInvitionLetterController.h"
#import "ChallengeListRecord.h"
#import "TempInvitionLetterItemView.h"
#import "ClubDetailController.h"
#import "Common.h"

@interface TempInvitionLetterController ()

@end

@implementation TempInvitionLetterController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

        self.title = LANGUAGE(@"RENT_LETTER");
        
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
    [moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, SCREEN_WIDTH / 3.4)];
    [moreView startAnimating];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    tmpletters = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadMore];
    nTempInvCount = 0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    loading = NO;
}
- (void)viewWillAppear:(BOOL)animated
{
    currPageNo = 0;
    moreAvailable = NO;
    [tmpletters removeAllObjects];
    [self.tableView reloadData];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tmpletters.count > 0)
        return moreAvailable ? tmpletters.count + 1 : tmpletters.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH / 1.7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == tmpletters.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"More"];
        [cell.contentView addSubview:moreView];
        if (!loading)
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:2.f];
        return cell;
    }
    
    if (tmpletters.count == 0)
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    ChallengeListRecord *record;
    record = (ChallengeListRecord *)[tmpletters objectAtIndex:indexPath.row];
    NSString *CellIdentifier = @"CellTempInvition";
    
    TempInvitionLetterItemView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[TempInvitionLetterItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell drawTempLetterWithRecord:record];
    
    return cell;
}

- (void)loadMore
{
    loading = YES;
    currPageNo ++;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currPageNo] forKey:@"TEMPINV_PAGENO"];
    [[HttpManager sharedInstance] browseTempInvitationWithDelegate:self];
}

- (void)refresh
{
    currPageNo = 0;
    moreAvailable = NO;
    [tmpletters removeAllObjects];
    [self loadMore];
    [self.refreshControl endRefreshing];
}

- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideMenuOptionsAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

#pragma TempInvitionLetterItemViewDelegate
- (void)doClickClubDetail:(TempInvitionLetterItemView *)cell clubID:(int)c_id
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubDetailController alloc] initWithClub:c_id fromClubCenter:NO] animated:YES];
}

#pragma TempInvitionLetterItemViewDelegate
- (void)menuDidShowInCell:(TempInvitionLetterItemView *)cell
{
    if (![self.swipedCell isEqual:cell])
        [self hideMenuOptionsAnimated:YES];
    
    self.swipedCell = cell;
}

#pragma TempInvitionLetterItemViewDelegate
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

- (void)doClickDisagress:(TempInvitionLetterItemView *)cell
{
    [AlertManager WaitingWithMessage];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:indexPath.row] forKey:@"TEMPINVLIST_ID"];
    int nClubID = [[tmpletters objectAtIndex:indexPath.row] intWithCallClubID];
    int nGameID = [[tmpletters objectAtIndex:indexPath.row] intWithGameID];
    NSArray *param = [NSArray arrayWithObjects:[NSNumber numberWithInt:nClubID],
                      [NSNumber numberWithInt:nGameID],
                      [NSNumber numberWithInt:2], nil];
    
    [[HttpManager sharedInstance] acceptTempInvReqWithDelegate:self data:param];
}

- (void)doClickAgree:(TempInvitionLetterItemView *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int nClubID = [[tmpletters objectAtIndex:indexPath.row] intWithCallClubID];
    int nGameID = [[tmpletters objectAtIndex:indexPath.row] intWithGameID];

    if ([[ClubManager sharedInstance] checkMyClub:nClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"failed")];
        return;
    }

    [AlertManager WaitingWithMessage];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:indexPath.row] forKey:@"TEMPINVLIST_ID"];
    NSArray *param = [NSArray arrayWithObjects:[NSNumber numberWithInt:nClubID],
                      [NSNumber numberWithInt:nGameID],
                      [NSNumber numberWithInt:1], nil];
    
    [[HttpManager sharedInstance] acceptTempInvReqWithDelegate:self data:param];
}

#pragma HttpManagerDelegate
- (void)browseTempInvitationResultErrorCode:(int)errorcode dataMore:(int)more data:(NSArray *)data
{
    if (loading == NO)
        return;
    loading = NO;
    moreAvailable = more == 1;
    [tmpletters addObjectsFromArray:data];
    [self processUnreadTempLetters];
    [self.tableView reloadData];
}

- (void)acceptTempInvReqResultErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    if (errorcode > 0){
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    }
    else
    {
        int index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TEMPINVLIST_ID"] intValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [tmpletters removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
    }
}

- (void)processUnreadTempLetters
{
    for (ChallengeListRecord *item in tmpletters) {
        if ([item booleanWithTempUnread] == YES)
        {
            nTempInvCount --;
            [item itemRead];
        }
    }
}
@end
