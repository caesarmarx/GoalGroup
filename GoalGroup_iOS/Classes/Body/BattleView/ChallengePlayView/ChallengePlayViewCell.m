//
//  ChallengePlayViewCell.m
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ChallengePlayViewCell.h"
#import "ChallengeItemView.h"
#import "Common.h"

@implementation ChallengePlayViewCell
{
    UIView *topView;
    UIView *swipeView;
    ChallengeItemView *itemView;
    UILabel *datetimeLabel;
    UILabel *stadiumLabel;
    UILabel *playerLabel;

    NSString *stadiumStr;
}
- (id)initMyChallengeWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    showTeam = NO;
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (id)initChallengeWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    showTeam = NO;
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    
}

- (id)initNoticeWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    showTeam = YES;
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self layoutComponents];
        swiped = NO;

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutComponents
{
    int h = SCREEN_WIDTH / 2;
    topView = [[UIView alloc] initWithFrame:CGRectMake(3, 10, SCREEN_WIDTH - 6, h)];
    topView.backgroundColor = [UIColor colorWithRed:11/255.f green:197/255.f blue:96/255.f alpha:1.f];
    topView.layer.cornerRadius = 8;
    topView.layer.masksToBounds = YES;
    itemView = [[ChallengeItemView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 6,  h)];
    itemView.showTeam = showTeam;
    itemView.detail = NO;
    itemView.letterMode = NO;
    itemView.delegate = self;
    UIGraphicsBeginImageContext(itemView.frame.size);
    [[UIImage imageNamed:@"challenge_cell_bg"] drawInRect:itemView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    itemView.backgroundColor = [UIColor colorWithPatternImage:image];
    [topView addSubview:itemView];
    swipeView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60 - 10, 10, 60 + 6, h)];
    swipeView.layer.cornerRadius = 8;
    swipeView.backgroundColor = [UIColor colorWithRed:7/255.f green:118/255.f blue:58/255.f alpha:1.f];
    
    UIButton *recommendButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [recommendButton setImage:IMAGE(@"chall_func_01") forState:UIControlStateNormal];
    recommendButton.frame = CGRectMake(swipeView.frame.size.width / 3, 8, 30, 30);
    [recommendButton addTarget:self action:@selector(recommendToClub:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *lblRecommend = [[UIButton alloc] initWithFrame:CGRectMake(swipeView.frame.size.width / 3, 38, 30, 10)];
    lblRecommend.titleLabel.font = FONT(12.f);
    lblRecommend.titleLabel.textColor = [UIColor whiteColor];
    lblRecommend.titleLabel.textAlignment = NSTextAlignmentCenter;
    [lblRecommend addTarget:self action:@selector(recommendToClub:) forControlEvents:UIControlEventTouchDown];
    [lblRecommend setTitle:LANGUAGE(@"challenge_play_swipe_recommend") forState:UIControlStateNormal];
    
    UIButton *responeButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [responeButton setImage:IMAGE(@"chall_func_02") forState:UIControlStateNormal];
    responeButton.frame = CGRectMake(swipeView.frame.size.width / 3, h / 3 + 6 , 30, 30);
    [responeButton addTarget:self action:@selector(agreeGame:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *lblBattle = [[UIButton alloc] initWithFrame:CGRectMake(swipeView.frame.size.width / 3, h / 3 + 36, 30, 10)];
    lblBattle.titleLabel.font = FONT(12.f);
    lblBattle.titleLabel.textColor = [UIColor whiteColor];
    lblBattle.titleLabel.textAlignment = NSTextAlignmentCenter;
    [lblBattle addTarget:self action:@selector(agreeGame:) forControlEvents:UIControlEventTouchDown];
    [lblBattle setTitle:LANGUAGE(@"challenge_play_swipe_battle") forState:UIControlStateNormal];
    
    UIButton *discussButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [discussButton setImage:IMAGE(@"chall_func_03") forState:UIControlStateNormal];
    discussButton.frame = CGRectMake(swipeView.frame.size.width / 3, h / 3 * 2 + 5, 30, 30);
    [discussButton addTarget:self action:@selector(goToChallengeDiscuss:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *lblChat = [[UIButton alloc] initWithFrame:CGRectMake(swipeView.frame.size.width / 3, h / 3 * 2 + 35, 30, 10)];
    lblChat.titleLabel.font = FONT(12.f);
    lblChat.titleLabel.textColor = [UIColor whiteColor];
    lblChat.titleLabel.textAlignment = NSTextAlignmentCenter;
    [lblChat addTarget:self action:@selector(goToChallengeDiscuss:) forControlEvents:UIControlEventTouchDown];
    [lblChat setTitle:LANGUAGE(@"challenge_play_swipe_chat")  forState:UIControlStateNormal];
    
    [swipeView addSubview:recommendButton];
    [swipeView addSubview:lblRecommend];
    [swipeView addSubview:responeButton];
    [swipeView addSubview:lblBattle];
    [swipeView addSubview:discussButton];
    [swipeView addSubview:lblChat];
    
    datetimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150, -1, 133, 20)];
    datetimeLabel.font = FONT(13.f);
    datetimeLabel.textAlignment = NSTextAlignmentRight;
    datetimeLabel.textColor = [UIColor blackColor];
    
    stadiumLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 300, h - 21, 253, 20)];
    [stadiumLabel setTextAlignment:NSTextAlignmentCenter];
    stadiumLabel.font = [UIFont boldSystemFontOfSize:15.f];
    stadiumLabel.textAlignment = NSTextAlignmentRight;
    stadiumLabel.textColor = [UIColor whiteColor];
    
    UILabel *stadiumArrow = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 45, h - 21, 20, 20)];
    [stadiumArrow setTextAlignment:NSTextAlignmentCenter];
    stadiumArrow.font = [UIFont boldSystemFontOfSize:15.f];
    stadiumArrow.textAlignment = NSTextAlignmentRight;
    stadiumArrow.textColor = [UIColor whiteColor];
    stadiumArrow.text = @">>";
    
    playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 35 - 3, h / 4 - 3, 70, 20)];
    playerLabel.font = FONT(13.f);
    playerLabel.textAlignment = NSTextAlignmentCenter;
    playerLabel.textColor = [UIColor blackColor];
    [topView addSubview:datetimeLabel];
    [topView addSubview:stadiumLabel];
    [topView addSubview:playerLabel];
    [topView addSubview:stadiumArrow];
    
    [self.contentView addSubview:swipeView];
    [self.contentView addSubview:topView];
    
    UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRightInChallengeCell:)];
    [rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.contentView  addGestureRecognizer:rightGesture];
    
    UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeftInChallengeCell:)];
        [leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.contentView addGestureRecognizer:leftGesture];
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)dataWithChallengeRecord:(ChallengeListRecord *)data
{
    self.challengeRecord = data;
    
    [itemView dataWithChallengeItem:data];
    datetimeLabel.text = [NSString stringWithFormat:@"%@/%@", [data stringWithPlayDate], [NSWeek stringWithLinearIntegerWeek:[data intWithPlayDay]]];
    
    stadiumStr = [data stringWithPlayStadiumAddress];
    playerLabel.text = [NSString stringWithFormat:@"%@", [data stringWithPlayers]];
    
    [self displayStadium];
}

#pragma Events
- (void)didSwipeLeftInChallengeCell:(UISwipeGestureRecognizer *)recognizer
{
    if (swiped)
        return;
    
    swiped = YES;
    
    [self openMenuView];
    
}

#pragma Events
- (void)didSwipeRightInChallengeCell:(UISwipeGestureRecognizer *)recognizer
{
    if (!swiped)
        return;
    
    swiped = NO;
    
    [self closeMenuView];
}

#pragma Events
- (void)didTapInChallengeCell:(UITapGestureRecognizer *)recognizer
{
    if (swiped)
    {
        swiped = NO;
        [self closeMenuView];
    }
    else
    {
        swiped = YES;
        [self openMenuView];
    }
}

#pragma UserDefine
- (void)closeMenuView
{

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    topView.frame = CGRectMake(topView.frame.origin.x + 60, topView.frame.origin.y, topView.frame.size.width, topView.frame.size.height);
    topView.layer.cornerRadius = 8;
    topView.layer.masksToBounds = YES;
    [UIView commitAnimations];

    [self displayStadium];
    
    [self.delegate menuDidHideInCell];
}

#pragma UserDefine
- (void)openMenuView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    topView.frame = CGRectMake(topView.frame.origin.x - 60, topView.frame.origin.y, topView.frame.size.width, topView.frame.size.height);
    topView.layer.cornerRadius = 0;
    topView.layer.masksToBounds = NO;
    topView.backgroundColor = [UIColor colorWithRed:11/255.f green:197/255.f blue:96/255.f alpha:1.f];
    [UIView commitAnimations];
    
    [self displayStadium];
    
    [self.delegate menuDidShowInCell:self];
}

#pragma UserEvents
- (void)goToChallengeDiscuss:(ChallengeItemView *)cell
{
    [self.delegate gotoChallengeDiscuss:self withArrowView:cell];
}

- (void)recommendToClub:(ChallengeItemView *)cell
{
    [self.delegate recommandToClubRoom:self];
}

- (void)agreeGame:(ChallengeItemView *)cell
{
    [self.delegate agreeGame:self withArrowView:cell];
}

- (void)displayStadium
{
    //if (swiped)
    //    stadiumLabel.text = [@"<<" stringByAppendingString:stadiumStr];
    //else
        stadiumLabel.text = stadiumStr;
    
}

- (void)closeMenu
{
    [self didSwipeRightInChallengeCell:nil];
}

#pragma ChallengeItemViewDelegate
- (void)doClickClubDetail:(NSInteger)nClubID
{
    [self.delegate gotoClubDetail:self clubID:nClubID];
}

@end
