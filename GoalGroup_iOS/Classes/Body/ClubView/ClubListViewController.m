//
//  ClubListViewController.m
//  GoalGroup
//
//  Created by KCHN on 1/30/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubListViewController.h"
#import "ClubRoomViewController.h"
#import "Common.h"
#import "ClubListRecord.h"
#import "ClubListViewCell.h"
#import "DiscussRoomManager.h"
#import "ClubDetailController.h"

@interface ClubListViewController ()

@end

@implementation ClubListViewController

+ (id)sharedInstance
{
    @synchronized(self)
    {
        if (gClubListViewController == nil)
            gClubListViewController = [[ClubListViewController alloc] init];
    }
    return gClubListViewController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
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
    
    clubs = [[NSMutableArray alloc] init];
    
    moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 50)];
    [moreView startAnimating];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    currPageNo = 0;
    moreAvailable = NO;
    [clubs removeAllObjects];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadMore];
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

#pragma mark - Scroll View

/**
 * Added By Boss. 2015/05/15
 * 스크롤을 우에서 아래로 못하게 한다.
 *
 */
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
    // Return the number of rows in the section.
    if (clubs.count > 0)
        return moreAvailable ? clubs.count + 1 : clubs.count;
    else
        return 0;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == clubs.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"More"];
        [cell.contentView addSubview:moreView];
        if (!loading)
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:2.f];
        return cell;
    }
    
    if (clubs.count == 0){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.text = LANGUAGE(@"No Data");
        return cell;
    }
    
    
    ClubListRecord *record = (ClubListRecord *)[clubs objectAtIndex:indexPath.row];
    NSString *CellIdentifier = @"Cell"; //Modified By Boss.2015/06/05
    
    ClubListViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[ClubListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    [cell dataWithClubRecord:record];
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int nClubID = [[clubs objectAtIndex:indexPath.row] intWithClubID];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubRoomViewController alloc] initWithNibName:@"ClubRoomViewController" clubID:nClubID bundle:nil] animated:YES];

}

#pragma UserDefinded
- (void)loadMore
{
    loading = YES;
    currPageNo ++;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currPageNo] forKey:@"CLUBLIST_PAGENO"];
    [[HttpManager newInstance] browseClublistWithDelegate:self];
}

- (void)refresh
{
    currPageNo = 0;
    moreAvailable = NO;
    [clubs removeAllObjects];
    [self loadMore];
    [self.refreshControl endRefreshing];
}

#pragma HttpManagerDelegate
- (void)browseMyClubResultWithErrorCode:(int)errorCode dataMore:(int)more data:(NSArray *)data
{
    if (loading == NO)
        return;
    loading = NO;
    moreAvailable = more == 1;
    
#ifdef DEMO_MODE
    NSLog(@"browseMyClubResultWithErrorCode: errorCode=%i, moreAvailable=%i, data=%lu", errorCode, moreAvailable, (unsigned long)data.count);
#endif
    
    [clubs addObjectsFromArray:data];
    [self.tableView reloadData];
    
}

/*
 기능: 5초에 한번씩 받는 변동자료에 따라 구락부목록에서 삭제된 구락부를 제거하고 재그리는 함수
 */
- (void)refreshTableView
{
    @try {
        int row = 0;
        
        do
        {
            ClubListRecord *club = [clubs objectAtIndex:row];
            
            if ([[ClubManager sharedInstance] checkMyClub:[club intWithClubID]])
            {
                row = row + 1;
            }
            else
            {
                [clubs removeObjectAtIndex:row];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            }
        } while (row < [clubs count]);
        
    }
    @catch (NSException *exception) {
        
#ifdef DEMO_MODE
        NSLog(@"%@ 구락부목록현시오유 %@", LOGTAG, exception);
#endif
    }
    
}

- (void)refreshUnreadCount
{
    [self.tableView reloadData];
}

#pragma ClubListViewCellDelegate
- (void)clubDetailClick:(ClubListViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int club = [[clubs objectAtIndex:indexPath.row] intWithClubID];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubDetailController alloc] initWithClub:club fromClubCenter:NO] animated:YES];
}
@end
