//
//  GameDetailController.m
//  GoalGroup
//
//  Created by MacMini on 4/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "GameDetailController.h"
#import "GameDetailPlayerCell.h"
#import "PersonalGameResultRecord.h"
#import "ClubDetailController.h"
#import "PersonalResultInputController.h"
#import "PlayerDetailController.h"
#import "Common.h"

@interface GameDetailController ()
{
    UIButton *backButton, *saveButton;
    UIActivityIndicatorView *moreView;
    
    BOOL moreAvailable;
    BOOL loading;
    int page;
}
@end

@implementation GameDetailController

+ (GameDetailController *)sharedInstance:(ChallengeListRecord *)gameInfo club:(int)clubID
{
    @synchronized(self)
    {
        if (gGameDetailController == nil)
            gGameDetailController = [[GameDetailController alloc] initWithClubID:clubID];
    }
    
    [gGameDetailController withGameInfo:gameInfo club:clubID];
    
    return gGameDetailController;
}

- (id)initWithClubID:(int)clubID
{
    nClubID = clubID;
    self = [super init];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self layoutComponents];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 40.f)];
    [moreView startAnimating];

}

- (void)viewWillAppear:(BOOL)animated
{
    saveButtonRegion.hidden = [gameInfo intWithVSStatus] == 4 && ([[ClubManager sharedInstance] checkCorchClub:nClubID])? NO: YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (players.count > 0)
        return moreAvailable? players.count + 1 : players.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == players.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"More"];
        [cell.contentView addSubview:moreView];
        
        if (!loading)
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:2.f];
        return cell;
    }
    
    if (players.count == 0)
        return [[GameDetailPlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    NSString *cellIndentifier = @"cellIdentifier";
    
    GameDetailPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil){
        cell = [[GameDetailPlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    PersonalGameResultRecord *record = [players objectAtIndex:indexPath.row];
    [cell drawPlayerWithName:[record stringWithPlayerName] image:[record stringWithPlayerImageUrl] goal:[NSString stringWithFormat:@"%d", [record intWithPlayerGoals]] assist:[NSString stringWithFormat:@"%d", [record intWithPlayerAssists]] overall:[NSString stringWithFormat:@"%d", [record intWithOverallPoints]]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([gameInfo intWithVSStatus] != 4)
        return;
    
    if (![[ClubManager sharedInstance] checkCorchClub:nClubID])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"you are not corch")];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)indexPath.row] forKey:@"PERSONALGAMERESULTINDEX"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PersonalGameResultRecord *record = [players objectAtIndex:indexPath.row];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    PersonalResultInputController *vc = [PersonalResultInputController sharedInstance];
    
    [vc setGoal:[record intWithPlayerGoals] assist:[record intWithPlayerAssists] point:[record intWithOverallPoints] title:[record stringWithPlayerName]];
    vc.delegate = self;
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

#pragma UserDefined
- (void)layoutComponents
{
    self.view.backgroundColor = [UIColor ggaGrayBackColor];
    
    self.title = LANGUAGE(@"game_detail_information");
    
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    
    saveButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 37)];
    saveButton = [[UIButton alloc] initWithFrame:CGRectMake(18, 0, 24, 22)]; //Modified By Boss.2015/05/13
    [saveButton setImage:IMAGE(@"save_ico") forState:UIControlStateNormal];
    [saveButton setTag:1001];
    saveButton.titleLabel.font = FONT(14.f);
    [saveButton addTarget:self action:@selector(savePerson) forControlEvents:UIControlEventTouchDown];
    [saveButtonRegion addSubview:saveButton];
    
    UIButton *lblButton = [[UIButton alloc] initWithFrame:CGRectMake(18, 23, 24, 15)];
    [lblButton setTitle:LANGUAGE(@"lbl_club_detail_save") forState:UIControlStateNormal];
    lblButton.titleLabel.textColor = [UIColor whiteColor];
    lblButton.titleLabel.font = FONT(12.f);
    [lblButton addTarget:self action:@selector(savePerson) forControlEvents:UIControlEventTouchDown];
    [saveButtonRegion addSubview:lblButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButtonRegion];
    
    gameView = [[ChallengeItemView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, SCREEN_WIDTH / 2)];
    gameView.showTeam = YES;
    gameView.detail = YES;
    gameView.letterMode = NO;
    gameView.delegate = self;
    gameView.backgroundColor = [UIColor whiteColor];
    
    playerView = [[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH / 2 + 20, SCREEN_WIDTH, SCREEN_HEIGHT - SCREEN_WIDTH / 2 - 20 - 64) style:UITableViewStylePlain];
    playerView.delegate = self;
    playerView.dataSource = self;
    playerView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:gameView];
    [self.view addSubview:playerView];
    
}

- (void)withGameInfo:(ChallengeListRecord *)record club:(int)clubID
{
    gameInfo = record;
    nClubID = clubID;
    saveButtonRegion.hidden = ![[ClubManager sharedInstance] checkAdminClub:nClubID];
    page = 0;
    moreAvailable = NO;
    
    if (players == nil)
        players = [[NSMutableArray alloc] init];
    else
        [players removeAllObjects];

    [playerView reloadData];
    [gameView dataWithChallengeItem:gameInfo];
    [self loadMore];
}

- (void)loadMore
{
    loading = YES;
    page ++;

    NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:nClubID],
                     [NSNumber numberWithInt:[gameInfo intWithGameID]],
                     [NSNumber numberWithInt:page],
                     nil];
    
    [[HttpManager sharedInstance] browseApplyGameListWithDelegate:self data:data];
}

- (void)browseApplyGameListWithErrorCode:(int)errorcode dataMore:(int)more data:(NSArray *)data
{
    if (errorcode == 0)
    {
        if (!loading)
            return;
        
        loading = NO;
        moreAvailable = more == 1;
        
        for (PlayerListRecord *item in data) {
            PersonalGameResultRecord *person = [[PersonalGameResultRecord alloc] initWithPlayerId:[item intWithPlayerID] playerName:[item stringWithPlayerName] playerImageUrl:[item imageUrlWithPlayerImage] goal:[item intWithGoals] assist:[item intWithAssists] point:[item intwithPoints]];
            
            [players addObject:person];
        }
        
        [playerView reloadData];
    }
}

- (void)backToPage
{
    [Common BackToPage];
}

- (void)savePerson
{
    if ([gameInfo intWithVSStatus] != 4)
        return;
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:[gameInfo intWithGameID]],
                             [NSNumber numberWithInt:nClubID],
                             nil];
    
    NSString *itemUserId = @"";
    NSString *itemGoalPoint = @"";
    NSString *itemAssist = @"";
    NSString *itemPoint = @"";
    
    for (PersonalGameResultRecord *item in players) {
        if ([itemUserId isEqualToString:@""])
            itemUserId = [NSString stringWithFormat:@"%d", [item intWithPlayerID]];
        else
            itemUserId = [NSString stringWithFormat:@"%@,%d", itemUserId, [item intWithPlayerID]];
        
        if ([itemGoalPoint isEqualToString:@""])
            itemGoalPoint = [NSString stringWithFormat:@"%d", [item intWithPlayerGoals]];
        else
            itemGoalPoint = [NSString stringWithFormat:@"%@,%d", itemGoalPoint, [item intWithPlayerGoals]];
        
        if ([itemAssist isEqualToString:@""])
            itemAssist = [NSString stringWithFormat:@"%d", [item intWithPlayerAssists]];
        else
            itemAssist = [NSString stringWithFormat:@"%@,%d", itemAssist, [item intWithPlayerAssists]];
        
        if ([itemPoint isEqualToString:@""])
            itemPoint = [NSString stringWithFormat:@"%d", [item intWithOverallPoints]];
        else
            itemPoint = [NSString stringWithFormat:@"%@,%d", itemPoint, [item intWithOverallPoints]];
    }
    
    [array addObject:itemUserId];
    [array addObject:itemGoalPoint];
    [array addObject:itemAssist];
    [array addObject:itemPoint];
    
    [AlertManager WaitingWithMessage];
    [[HttpManager sharedInstance] setUserPointWithDelegate:self data:array];
}

#pragma PersonalResultInputControllerDelegate
- (void)inputFinished:(int)goal assist:(int)assist point:(int)point
{
    int index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PERSONALGAMERESULTINDEX"] intValue];
    PersonalGameResultRecord *record = [players objectAtIndex:index];
    [record setGoal:goal assist:assist point:point];
    [playerView reloadData];
}

#pragma HttpManagerDelegate
- (void)setUserPointResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"save success")];
}

#pragma ChallengeItemViewDelegate
- (void)doClickClubDetail:(NSInteger)nClub
{
    if (nClub < 1) return;
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubDetailController alloc] initWithClub:(int)nClub fromClubCenter:NO] animated:YES];

}

#pragma GameDetailPlayerCellDelegate
- (void)playerDetailClick:(GameDetailPlayerCell *)cell
{
    NSIndexPath *indexPath = [playerView indexPathForCell:cell];
    int nPlayerID = [[players objectAtIndex:indexPath.row] intWithPlayerID];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[PlayerDetailController alloc] initWithPlayerID:nPlayerID showInviteButton:NO] animated:YES];
}
@end
