//
//  SystemConferenceController.m
//  GoalGroup
//
//  Created by MacMini on 4/20/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "SystemConferenceController.h"
#import "SystemConferenceListRecord.h"
#import "SystemConferenceItemView.h"
#import "Common.h"

@interface SystemConferenceController ()

@end

@implementation SystemConferenceController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        [self layoutComponents];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    currPageNo = 0;
    moreAvailable = NO;
    [conferences removeAllObjects];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadmore];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    conferences = [[NSMutableArray alloc] init];
    
    moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 30)];
    [moreView startAnimating];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)layoutComponents
{
    self.title = LANGUAGE(@"SYSTEM_NOTICE");
    self.tableView.backgroundColor = [UIColor ggaGrayBackColor];
    
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
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
    CGPoint curPoint = scrollView.contentOffset;
    if (curPoint.x == 0.f && curPoint.y <= 0.0f) {
        [scrollView setContentOffset:CGPointMake(0.f, 0.f)];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (conferences.count > 0)
        return moreAvailable? conferences.count + 1: conferences.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (moreAvailable && indexPath.section == conferences.count)
        return 0.f;
    
    SystemConferenceItemView *r = [conferences objectAtIndex:indexPath.section];
    return r.view.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 3.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (conferences.count == section)
        return 0.1f;
    else
        return 40.f;
}

// 헤더뷰에 날자를 현시
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    
    if (conferences.count == section)
        return view;
    
    if (conferences.count == 0)
        return view;
    
    SystemConferenceItemView *v = [conferences objectAtIndex:section];
    SystemConferenceListRecord *r = v.record;
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 50, 15, 100, 20)];
    [dateLabel setTextAlignment:NSTextAlignmentCenter];
    dateLabel.text = [NSString stringWithFormat:@"%@ %@ %@",
                      [r stringDate],
                      [r stringWeekDay],
                      [r stringTime]];
    dateLabel.font = FONT(12.f);
    dateLabel.layer.cornerRadius = 5.f;
    dateLabel.layer.masksToBounds = YES;
    dateLabel.backgroundColor = [UIColor ggaGrayBorderColor];
    [view addSubview:dateLabel];
    return view;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)loadmore
{
    loading = YES;
    currPageNo ++;
    
    NSArray *data = [NSArray arrayWithObjects:
                     [NSNumber numberWithInt:currPageNo],
                     [NSNumber numberWithInt:UID],
                     nil];
    [[HttpManager sharedInstance] getAdminNewsWithDelegate:self data:data];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == conferences.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"More"];
        [cell.contentView addSubview:moreView];
        
        if (!loading)
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:2.f];
        
        return cell;
    }
    
    NSString *cellIdentifier = @"cellSystemConference";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    SystemConferenceItemView *v = [conferences objectAtIndex:indexPath.section];
    [cell.contentView addSubview:v.view];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (void)refresh
{
    currPageNo = 0;
    moreAvailable = NO;
    [conferences removeAllObjects];
    [self loadmore];
    [self.refreshControl endRefreshing];
}

- (void)backToPage
{
    [Common BackToPage];
}

#pragma HttpManagerDelegate
- (void)getAdminNewsResultWithErrorCode:(int)errorcode more:(int)more data:(NSArray *)data
{
    if (loading == NO)
        return;
    
    loading = NO;
    moreAvailable = more == 1;
    
    for (SystemConferenceListRecord *record in data) {
        SystemConferenceItemView *item = [[SystemConferenceItemView alloc] initWithSystemConferenceRecord:record];
        [conferences addObject:item];
    }

    [self.tableView reloadData];
}

@end
