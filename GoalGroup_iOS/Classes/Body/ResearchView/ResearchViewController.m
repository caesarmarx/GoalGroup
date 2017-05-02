//
//  SettingsViewController.m
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ResearchViewController.h"
#import "PlayerMarketController.h"
#import "ClubMarketController.h"
#import "DemandLetterController.h"
#import "TempInvitionLetterController.h"
#import "Common.h"

@interface ResearchViewController ()

@end

@implementation ResearchViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        rscLabelsMono = [NSArray arrayWithObjects:LANGUAGE(@"PLAYER_MARKET_TITLE"), LANGUAGE(@"club center"), nil];
        rscLabelsDi = [NSArray arrayWithObjects:LANGUAGE(@"INVITATION LETTER"),LANGUAGE(@"RENT_LETTER"), nil];
        rscLabelsTetra = [NSArray arrayWithObjects:LANGUAGE(@"FOOTBALL_EQUIPMENT"), nil];
        rscLabelsPenta = [NSArray arrayWithObjects:LANGUAGE(@"EVERY_PENTA"), nil];
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
    
    [self layoutComponents];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshCount];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)layoutComponents
{
    
    NSUInteger gapHeight = 15;
    NSUInteger conHeight = 25;
    NSUInteger navHeight = 0;
    NSUInteger height = navHeight + gapHeight;
    NSUInteger labelWidth = 80;
    
    NSUInteger itemHeight = (conHeight + gapHeight) * 2;
    
    UIView *itemBack = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight) * 2 + 8)];
    itemBack.layer.cornerRadius = 5;
    itemBack.layer.masksToBounds = YES;
    itemBack.backgroundColor = [UIColor ggaThemeGrayColor];
    LBorderView *dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2 + 5, itemBack.frame.size.width - 30, 0.3f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [itemBack addSubview:dotView];
    [self.view addSubview:itemBack];
    
    height += 8;
    UIFont *font = FONT(15.f);
    
    playerMarketView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH, conHeight)];
    playerMarketLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 1, labelWidth, conHeight)];
    [playerMarketLabel setFont:font];
    [playerMarketLabel setTextAlignment:NSTextAlignmentLeft];
    playerMarketLabel.text = LANGUAGE(@"PLAYER_MARKET_TITLE");
    [playerMarketView addSubview:playerMarketLabel];
    
    UIImage *img = [UIImage imageNamed:@"player_search"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(10, 3, 20, 20)];
    [playerMarketView addSubview:imgView];
    [self.view addSubview: playerMarketView];
    
    UITapGestureRecognizer *singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerMarketClicked:)];
    [playerMarketView addGestureRecognizer:singleFinterTap];
    
    height = height + itemHeight / 2;
    clubMarketView = [[UIView alloc] initWithFrame:CGRectMake(10, height+ 3, SCREEN_WIDTH -  20, conHeight)];
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clubMarketClicked:)];
    [clubMarketView addGestureRecognizer:singleFinterTap];
    clubMarketLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, labelWidth, conHeight)];
    [clubMarketLabel setFont:font];
    [clubMarketLabel setTextAlignment:NSTextAlignmentLeft];
    clubMarketLabel.text =LANGUAGE(@"club center");
    [clubMarketView addSubview:clubMarketLabel];
    
    img = [UIImage imageNamed:@"club_search"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(10, 3, 20, 20)];
    [clubMarketView addSubview:imgView];
    [self.view addSubview:clubMarketView];
    
    
    height = height + itemHeight / 2 + gapHeight;
    itemBack = [[UIView alloc] init];
    itemBack.layer.cornerRadius = 5;
    itemBack.layer.masksToBounds = YES;
    itemBack.tag = 100;
    itemBack.backgroundColor = [UIColor ggaThemeGrayColor];
    itemBack.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight )* 2 + 8);
    [self.view addSubview:itemBack];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2 + 5, itemBack.frame.size.width - 30, 0.3f)];
    dotView.borderType = BorderTypeDashed;
    dotView.tag = 300;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [itemBack addSubview:dotView];
    height += 8;
    inviteLetterView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH - 30, conHeight)];
    inviteLetterLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 1, labelWidth, conHeight)];
    [inviteLetterLabel setFont:FONT(14.f)];
    [inviteLetterLabel setTextAlignment:NSTextAlignmentLeft];
    inviteLetterLabel.text = LANGUAGE(@"INVITATION LETTER");
    [inviteLetterView addSubview:inviteLetterLabel];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteLetterPress:)];
    [inviteLetterView addGestureRecognizer:singleFinterTap];
    
    img = [UIImage imageNamed:@"inv_list"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(10, 4, 20, 20)];
    [inviteLetterView addSubview:imgView];
    
    inviteCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 65, 5, 20, 20)];
    inviteCountLabel.textAlignment = NSTextAlignmentCenter;
    inviteCountLabel.layer.cornerRadius = 10;
    inviteCountLabel.layer.masksToBounds = YES;
    inviteCountLabel.textColor = [UIColor whiteColor];
    inviteCountLabel.backgroundColor = [UIColor redColor];
    inviteCountLabel.hidden = YES;
    [inviteLetterView addSubview: inviteCountLabel];

    [self.view addSubview: inviteLetterView];
    
    
    height = height + conHeight + gapHeight;
    
    tmpLetterView = [[UIView alloc] initWithFrame:CGRectMake(10, height + 5, SCREEN_WIDTH - 30, conHeight)];
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tmpLetterPress:)];
    [tmpLetterView addGestureRecognizer:singleFinterTap];
    
    tmpLetterLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, labelWidth, conHeight)];
    [tmpLetterLabel setFont:FONT(14.f)];
    [tmpLetterLabel setTextAlignment:NSTextAlignmentLeft];
    tmpLetterLabel.text = LANGUAGE(@"RENT_LETTER");
    [tmpLetterView addSubview:tmpLetterLabel];
    
    img = [UIImage imageNamed:@"temp_inv_list"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(10, 3, 20, 20)];
    [tmpLetterView addSubview:imgView];
    
    tmpCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 65, 5, 20, 20)];
    tmpCountLabel.textAlignment = NSTextAlignmentCenter;
    tmpCountLabel.layer.cornerRadius = 10;
    tmpCountLabel.layer.masksToBounds = YES;
    tmpCountLabel.textColor = [UIColor whiteColor];
    tmpCountLabel.backgroundColor = [UIColor redColor];
    tmpCountLabel.hidden = YES;
    [tmpLetterView addSubview: tmpCountLabel];

    [self.view addSubview:tmpLetterView];
    
    [self refreshCount];

}

- (void)refreshCount
{
    NSString *strInvCount = nInvCount == 0? @"": [NSString stringWithFormat:@"%d", nInvCount];
    NSString *strTmpInvCount = nTempInvCount == 0? @"": [NSString stringWithFormat:@"%d", nTempInvCount];
    
    if (![strInvCount isEqualToString:@""] && ![strInvCount isEqualToString:@"0"]) {
        inviteCountLabel.hidden = NO;
        inviteCountLabel.text = strInvCount;
    }
    else
        inviteCountLabel.hidden = YES;

    if (![strTmpInvCount isEqualToString:@""] && ![strTmpInvCount isEqualToString:@"0"]) {
        tmpCountLabel.hidden = NO;
        tmpCountLabel.text = strTmpInvCount;
    }
    else
        tmpCountLabel.hidden = YES;

}

- (void)clubMarketClicked:(UITapGestureRecognizer *)recognizer
{
    [[ClubSearchConditionController sharedInstance] removeSearchConditions];

    ggaAppDelegate *appDelegate = APP_DELEGATE;
    UIViewController *vc = [[ClubMarketController alloc] init];
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

- (void)playerMarketClicked:(UITapGestureRecognizer *)recognizer
{
    [[PlayerSearchConditionController sharedInstance] removeSearchConditions];

    ggaAppDelegate *appDelegate = APP_DELEGATE;
    PlayerMarketController *vc = [[PlayerMarketController alloc] init];
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

- (void)inviteLetterPress:(UITapGestureRecognizer *)recognizer
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    DemandLetterController *vc = [[DemandLetterController alloc] init];
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

- (void)tmpLetterPress:(UITapGestureRecognizer *)recognizer
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    TempInvitionLetterController *vc = [[TempInvitionLetterController alloc] init];
    [appDelegate.ggaNav pushViewController:vc animated:YES];

}
@end
