//
//  DiscussListViewController.m
//  GoalGroup
//
//  Created by KCHN on 1/30/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DiscussListViewController.h"
#import "DiscussListRecord.h"
#import "DiscussListViewCell.h"
#import "DiscussDetailController.h"
#import "Common.h"

@interface DiscussListViewController ()

@end

@implementation DiscussListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
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
    
    arrangeDiscuss = [[NSMutableArray alloc] init];
    sectionArray = [[NSMutableArray alloc] init];
    
    moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 50)];
    [moreView startAnimating];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    moreAvailable = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    currPageNo = 0;
    moreAvailable = NO;
    [arrangeDiscuss removeAllObjects];
    [sectionArray removeAllObjects];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    if (currentOffset.x == 0.f && currentOffset.y <= 0.0f) {
        [scrollView setContentOffset:CGPointMake(0.f, 0.f)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (sectionArray.count > 0)
        return moreAvailable? sectionArray.count + 1: sectionArray.count;
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == sectionArray.count)
        return 1;
    else
        return ((NSArray *)[arrangeDiscuss objectAtIndex:section]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (sectionArray.count == section)
        return 0.f;
    else
        return 20.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];

    if (sectionArray.count == section)
        return view;
    
    if (sectionArray.count == 0)
        return view;

    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 100, 0, 200, 20)];
    [dateLabel setTextAlignment:NSTextAlignmentCenter];
    dateLabel.text = [NSString stringWithFormat:@"%@", [sectionArray objectAtIndex:section]];
    dateLabel.font = FONT(12.f);
    [view addSubview:dateLabel];
    return view;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= sectionArray.count) //Modified By Boss.2015/05/14: Scroll Error
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"More"];
        [cell.contentView addSubview:moreView];
        if (!loading)
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:2.f];
        return cell;
    }
    
    DiscussListRecord *record;
    NSArray *tmpArray = [arrangeDiscuss objectAtIndex:indexPath.section];
    record = (DiscussListRecord *)[tmpArray objectAtIndex:indexPath.row];
    NSString *CellIdentifier = @"CellDiscussList";
    
    DiscussListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
        cell = [[DiscussListViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    [cell dataWithDiscussRecord:record];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *tmpArray = [arrangeDiscuss objectAtIndex:indexPath.section];
    DiscussListRecord *record = (DiscussListRecord *)[tmpArray objectAtIndex:indexPath.row];
    
    int nBBSID = [record intWithDiscussID];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[DiscussDetailController alloc] initWithMainID:nBBSID] animated:YES];
}

- (void)loadMore
{
    loading = YES;
    currPageNo ++;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currPageNo] forKey:@"DISCUSSLIST_PAGENO"];
    [[HttpManager newInstance] browseDiscussListWithDelegate:self];
}

- (void)refresh
{
    currPageNo = 0;
    moreAvailable = NO;
    [arrangeDiscuss removeAllObjects];
    [sectionArray removeAllObjects];
    [self loadMore];
    [self.refreshControl endRefreshing];
}

#pragma HttpManagerDelegate
- (void)browseDiscussResultWithErrorCode:(int)errorCode dataMore:(int)more data:(NSArray *)data
{
    if (errorCode > 0)
    {
        
    }
    else
    {
        if (loading == NO)
            return;
        loading = NO;
        moreAvailable = more == 1;

#ifdef DEMO_MODE
        NSLog(@"browseDiscussResultWithErrorCode: errorCode=%i, moreAvailable=%i, data=%lu", errorCode, moreAvailable, (unsigned long)data.count);
#endif

        for (DiscussListRecord *item in data) {
            NSUInteger n = [sectionArray indexOfObject:[item stringWithTime]];
            
            if (n == NSNotFound){
                [sectionArray addObject:[item stringWithTime]];
                n = sectionArray.count - 1;
                
                NSMutableArray *rowDiscuss = [[NSMutableArray alloc] init];
                [arrangeDiscuss addObject:rowDiscuss];
            }
            
            [((NSMutableArray *)[arrangeDiscuss objectAtIndex:n]) addObject:item];
        }

        [self.tableView reloadData];
    }
}
@end
