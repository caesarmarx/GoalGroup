//
//  ConferenceController.m
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ConferenceController.h"
#import "ConferenceListRecord.h"
#import "ConferenceViewCell.h"
#import "SystemConferenceController.h"
#import "DiscussRoomManager.h"
#import "ClubRoomViewController.h"
#import "Common.h"

@interface ConferenceController ()

@end

@implementation ConferenceController

+ (ConferenceController *)sharedInstance
{
    @synchronized(self)
    {
        if (gConferenceController == nil)
            gConferenceController = [[ConferenceController alloc] init];
    }
    return gConferenceController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = LANGUAGE(@"REPORT");

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
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
}
- (void)viewWillAppear:(BOOL)animated
{
    [self refresh];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint curPoint = scrollView.contentOffset;
    if (curPoint.x == 0.f && curPoint.y < 0.f)
        [scrollView setContentOffset:CGPointMake(0.f, 0.f)];
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
        return conferences.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 60.f;
    else
        return 75.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (conferences.count == 0)
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    ConferenceListRecord *record;
    record = (ConferenceListRecord *)[conferences objectAtIndex:indexPath.row];
    NSString *CellIdentifier = @"CellConference";
    if (indexPath.row == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor ggaUserGrayBackgroundColor];
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        img.image = IMAGE(@"system_notice");
        [cell.contentView addSubview:img];
        
        UILabel *cellTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, SCREEN_WIDTH - 100, 20)];
        cellTitle.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
        cellTitle.text = @"平台消息";
        cellTitle.font = BOLDFONT(22.f);
        [cell.contentView addSubview:cellTitle];
        
        return cell;
    }

    ConferenceViewCell *cell = [[ConferenceViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [cell drawConferenceWithRecord:record];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ggaAppDelegate *appDelegate = APP_DELEGATE;
    if (indexPath.row == 0)
    {
        [appDelegate.ggaNav pushViewController:[[SystemConferenceController alloc] init] animated:YES];
    } else
    {
        ConferenceListRecord *record = [conferences objectAtIndex:indexPath.row];
        [appDelegate.ggaNav pushViewController:[[ClubRoomViewController alloc] initWithNibName:@"ClubRoomViewController" conference:record] animated:YES];
    }
}

- (void)loadMore
{
}

- (void)refresh
{
    self.tableView.backgroundColor = [UIColor ggaUserGrayBackgroundColor];
    conferences = [[NSMutableArray alloc] init];
    
    //체계뉴스용 아이텀을 추가
    ConferenceListRecord *mngRecord = [[ConferenceListRecord alloc] initWithID:0 sendImage:@"" recvImage:@"" dateTime:@"" gameType:0 gameId:0 team1:0 team2:0 teamStr1:@"" teamStr2:@"" unread:0 players:0 challState:0 gameState:0 lastChatInfo:@""];
    [conferences addObject:mngRecord];
    
    //상의마당아이텀을 추가
    NSMutableArray *conferArray = [[NSMutableArray alloc] init];
    for (DiscussRoomItem *item in [[DiscussRoomManager sharedInstance] getChatRooms])
    {
        int nRoomID = [item intWithRoomID];
        int team1 = [item intWithSendClubID];
        int team2 = [item intWithRecvClubID];
        int nGameType = [item intWithGameType];
        int nGameID = [item intWithGameID];
        int unread = [item unreadCount];
        int players = [item intWithGamePlayers];
        NSString *teamStr1 = [item stringWithSendName];
        NSString *teamStr2 = [item stringWithRecvName];
        NSString *gameDate = [item stringWithGameDate];
        NSString *img1 = [item stringWithSendImageUrl];
        NSString *img2 = [item stringWithRecvImageUrl];
        NSString *lastChat = [item lastChatMsgMan];
        int challState = [item intWithChallState];
        int gameSate = [item intWithGameState];
        
        //채팅리력이 없으면 목록을 추가하지 않는다.
        if ([lastChat compare:@""] == NSOrderedSame)
            continue;
        
        ConferenceListRecord *record = [[ConferenceListRecord alloc] initWithID:nRoomID sendImage:img1 recvImage:img2 dateTime:gameDate gameType:nGameType gameId:nGameID team1:team1 team2:team2 teamStr1:teamStr1 teamStr2:teamStr2 unread:unread players:players challState:challState gameState:gameSate lastChatInfo:lastChat];
        [conferArray addObject:record];
    }
    
    [conferences addObjectsFromArray:[conferArray sortedArrayUsingFunction:stringSort context:NULL]];
    [self.tableView reloadData];
}

/*
 기능: 아이텀들을 날자에 따라 비교하는 함수
 파람: arg1 - 비교아이텀1, arg2 - 비교아이텀2
 리턴: 비교하여 결과를 -1, 0, 1로 되돌린다.
 */
 
NSInteger stringSort(ConferenceListRecord *arg1, ConferenceListRecord *arg2, void *context)
{
    NSString *str1 = [arg1 stringWithLastTime];
    NSString *str2 = [arg2 stringWithLastTime];
    
    return [str2 compare:str1];
}

- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
    [APP_DELEGATE referLabelRefresh];
}

- (void)refreshTableView
{
    [self refresh];
}

@end
