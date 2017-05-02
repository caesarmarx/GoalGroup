//
//  ClubGameViewCell.m
//  GoalGroup
//
//  Created by KCHN on 2/26/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubGameViewCell.h"
#import "Common.h"
#import "ChallengeItemView.h"

@implementation ClubGameViewCell
{
    ChallengeItemView *itemView;
    UIView *topView;
    UIView *swipeView;
    UIView *cancelView;
}

- (id)initMyChallengeWithStyle:(UITableViewCellStyle)style resueIdentifier:(NSString *)resueIdentifier
{
    showTeam = NO;
    return [self initWithStyle:style reuseIdentifier:resueIdentifier];
}

- (id)initMyNoticeWithStyle:(UITableViewCellStyle)style resueIdentifier:(NSString *)resueIdentifier
{
    showTeam = YES;
    return [self initWithStyle:style reuseIdentifier:resueIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self layoutComponents];
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
    self.backgroundColor = [UIColor whiteColor];
    
    topView = [[UIView alloc] initWithFrame:CGRectMake(3, 5, SCREEN_WIDTH - 6, SCREEN_WIDTH / 2)];
    topView.backgroundColor = [UIColor whiteColor];
    
    itemView = [[ChallengeItemView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 6, SCREEN_WIDTH / 2)];
    itemView.showTeam  = showTeam;
    itemView.detail = YES;
    itemView.backgroundColor = [UIColor whiteColor];
    itemView.letterMode = NO;
    itemView.delegate = self;
    [topView addSubview:itemView];
    
    UIGraphicsBeginImageContext(itemView.frame.size);
    [[UIImage imageNamed:@"challenge_cell_bg"] drawInRect:itemView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    itemView.backgroundColor = [UIColor colorWithPatternImage:image];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(1, 1, 30, 30);
    [cancelButton addTarget:self action:@selector(gameCancel) forControlEvents:UIControlEventTouchDown];
    [cancelButton setImage:IMAGE(@"game_delete") forState:UIControlStateNormal];
    cancelButton.layer.cornerRadius = 8;
    cancelButton.layer.masksToBounds = YES;
    
    cancelView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 16, SCREEN_WIDTH / 2 - 10 , 32, 32)];
    cancelView.layer.cornerRadius = 8;
    cancelView.layer.masksToBounds = YES;
    [cancelView addSubview:cancelButton];
    [self addSubview:cancelView];
    
    //Added by KCHN
    swipeView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60 - 10, 5, 60 + 6, SCREEN_WIDTH / 2)];
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
    [lblRecommend addTarget:self action:@selector(agreeGame:) forControlEvents:UIControlEventTouchDown];
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

    [self.contentView addSubview:swipeView];
    [self.contentView addSubview:topView];
    
    UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didTapInChallengeCell:)];
    [rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.contentView  addGestureRecognizer:rightGesture];
    UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didTapInChallengeCell:)];
    [leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.contentView addGestureRecognizer:leftGesture];
}

#pragma UserDefined
- (void)dataWithChallengeRecord:(ChallengeListRecord *)data
{
    [itemView dataWithChallengeItem:data];
    
    if (![[ClubManager sharedInstance] checkAdminClub:_nclub])
        cancelView.hidden = YES;
    else
    {
        if ([data intWithSendClubID] == _nclub)
            cancelView.hidden = NO;
        else
            cancelView.hidden = YES;
    }
}

#pragma Events
- (void)didSwipeLeftInChallengeCell:(UISwipeGestureRecognizer *)recognizer
{
    if (!showTeam) return;
    if (swiped) return;
    swiped = YES;
    [self openMenuView];
    
}

#pragma Events
- (void)didSwipeRightInChallengeCell:(UISwipeGestureRecognizer *)recognizer
{
    if (!showTeam) return;
    if (!swiped) return;
    swiped = NO;
    [self closeMenuView];
}

#pragma Events
- (void)didTapInChallengeCell:(UITapGestureRecognizer *)recognizer
{
    if (!showTeam) return;
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
    topView.layer.masksToBounds = NO;
    
    cancelView.frame = CGRectMake(cancelView.frame.origin.x + 60, cancelView.frame.origin.y, cancelView.frame.size.width, cancelView.frame.size.height);

    [UIView commitAnimations];
    
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
    
    cancelView.frame = CGRectMake(cancelView.frame.origin.x - 60, cancelView.frame.origin.y, cancelView.frame.size.width, cancelView.frame.size.height);

    [UIView commitAnimations];
    
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

- (void)closeMenu
{
    [self didTapInChallengeCell:nil];
}


#pragma Events
- (void)gameCancel
{
    NSLog(@"cancel");
    [self.delegate cancelButtonClick:self];
}

#pragma ChallengeItemViewDelegate
- (void)doClickClubDetail:(NSInteger)nClub
{
    [self.delegate gotoClubDetail:nil clubID:(int)nClub];
}
@end
