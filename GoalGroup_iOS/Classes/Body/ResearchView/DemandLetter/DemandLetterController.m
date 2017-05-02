//
//  DemandLetterController.m
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DemandLetterController.h"
#import "DemandListRecord.h"
#import "DemandLetterItemView.h"
#import "ClubDetailController.h"
#import "Common.h"

@interface DemandLetterController ()

@end

@implementation DemandLetterController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = LANGUAGE(@"INVITATION LETTER");
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

    letters = [[NSMutableArray alloc]init];
    
    moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 50)];
    [moreView startAnimating];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];

}
- (void)viewDidAppear:(BOOL)animated
{
    [self loadMore];
    nInvCount = 0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    loading = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    currPageNo = 0;
    moreAvailable = NO;
    [letters removeAllObjects];
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (letters.count > 0)
        return moreAvailable ? letters.count + 1 : letters.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == letters.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"More"];
        [cell.contentView addSubview:moreView];
        if (!loading)
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:2.f];
        return cell;
    }
    
    if (letters.count == 0)
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    DemandListRecord *record;
    record = (DemandListRecord *)[letters objectAtIndex:indexPath.row];
    NSString *CellIdentifier = @"CellDemandLetter";
    
    
    DemandLetterItemView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[DemandLetterItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell drawDemandLetterWithRecord:record];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideMenuOptionsAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

- (void)loadMore
{
    loading = YES;
    currPageNo ++;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currPageNo] forKey:@"REQUESTLIST_PAGENO"];
    [[HttpManager sharedInstance] browseRequestWithDelegate:self];
}

- (void)refresh
{
    currPageNo = 0;
    moreAvailable = NO;
    [letters removeAllObjects];
    [self loadMore];
    [self.refreshControl endRefreshing];
}

#pragma Events
- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

#pragma HttpManagerDelegate
- (void)browseRequestResultWithErrorCode:(int)errorCode dataMore:(int)more data:(NSArray *)data
{
    if (errorCode > 0)
    {
        
    }
    else
    {
        if (!loading)
            return;
        loading = NO;
        moreAvailable = more == 1;
        [letters addObjectsFromArray:data];
        [self processUnreadLetters];
        [self.tableView reloadData];
    }
}

#pragma HttpManagerDelegate
- (void)acceptInvReqResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0){
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    }
    else
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
        
        int index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LETTERLIST_ID"] intValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [letters removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

#pragma DemandLetterItemViewDelegate
- (void)doClickAgree:(DemandLetterItemView *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)indexPath.row] forKey:@"LETTERLIST_ID"];
    int nClubID = [[letters objectAtIndex:indexPath.row] intWithClubID];
    NSArray *param = [NSArray arrayWithObjects:[NSNumber numberWithInt:nClubID],
                      [NSNumber numberWithInt:1], nil];
    
    [AlertManager WaitingWithMessage];
    [[HttpManager sharedInstance] acceptInvReqWithDelegate:self data:param];

}

- (void)doClickDisagress:(DemandLetterItemView *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)indexPath.row] forKey:@"LETTERLIST_ID"];
    int nClubID = [[letters objectAtIndex:indexPath.row] intWithClubID];
    NSArray *param = [NSArray arrayWithObjects:[NSNumber numberWithInt:nClubID],
                      [NSNumber numberWithInt:2], nil];
    
    [AlertManager WaitingWithMessage];
    [[HttpManager sharedInstance] acceptInvReqWithDelegate:self data:param];
}

- (void)doClickClubDetail:(DemandLetterItemView *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int nClubID = [[letters objectAtIndex:indexPath.row] intWithClubID];

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nClubID] forKey:@"CLUBDETAIL_CLUBID"];
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubDetailController alloc] initWithClub:nClubID fromClubCenter:NO] animated:YES];
}

#pragma DemandLetterItemViewDelegate
- (void)menuDidShowInCell:(DemandLetterItemView *)cell
{
    if (![self.swipedCell isEqual:cell])
        [self hideMenuOptionsAnimated:YES];
    
    self.swipedCell = cell;
}

#pragma DemandLetterItemViewDelegate
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

- (void)processUnreadLetters
{
    for (DemandListRecord *item in letters) {
        if ([item booleanWithUnread] == YES)
        {
            nInvCount --;
            [item itemRead];
        }
    }
}
@end
