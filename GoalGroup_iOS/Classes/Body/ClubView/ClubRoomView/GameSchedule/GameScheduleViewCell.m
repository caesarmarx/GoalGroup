//
//  GameScheduleViewCell.m
//  GoalGroup
//
//  Created by KCHN on 2/13/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "GameScheduleViewCell.h"
#import "Common.h"

@implementation GameScheduleViewCell
{
    UIView *topView;
    UIView *swipeView;
    UIView *alphaView;
    BOOL swiped;
    UIImageView *vsImage;
}

@synthesize nMineClub;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        swiped = NO;
        
        NSUInteger itemWidth = SCREEN_WIDTH - 10;
        int h = SCREEN_WIDTH / 2.5;
        topView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, itemWidth, h)];
        topView.backgroundColor = [UIColor colorWithRed:11/255.f green:197/255.f blue:96/255.f alpha:1.f];
        
        UIGraphicsBeginImageContext(topView.frame.size);
        [[UIImage imageNamed:@"game_schedule_bg"] drawInRect:topView.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        topView.backgroundColor = [UIColor colorWithPatternImage:image];
        
        vsImage = [[UIImageView alloc] initWithFrame:CGRectMake(itemWidth / 2 - 40, 18, 80, 20)];
        
        sendClubImage = [[UIImageView alloc] initWithFrame:CGRectMake( itemWidth / 4 - 25, h / 2 - 25, 50, 50)];
        sendClubImage.userInteractionEnabled = YES;
        recvClubImage = [[UIImageView alloc] initWithFrame:CGRectMake( itemWidth / 4 * 3 - 25, h / 2 - 25, 50, 50)];
        recvClubImage.userInteractionEnabled = YES;
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemWidth / 2 - 80, 0, 160, 20)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = FONT(13.f);
        
        vsLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemWidth / 2 - 22, h / 2 - 20, 44, 44)];
        vsLabel.font = FONT(24.f);
        vsLabel.textAlignment = NSTextAlignmentCenter;
        vsLabel.textColor = [UIColor blackColor];
        vsLabel.layer.cornerRadius = 22.f;
        vsLabel.layer.masksToBounds = YES;
        vsLabel.backgroundColor = [UIColor purpleColor];
        
        alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, h)];
        alphaView.backgroundColor = [UIColor ggaGrayTransParentColor];
        alphaView.hidden = YES;
        
        team1Label = [[UILabel alloc] initWithFrame:CGRectMake(itemWidth / 4 - 45 , h / 2 + 25, 90, 30)];
        team1Label.font = FONT(18.f);
        team1Label.textColor = [UIColor whiteColor];
        team1Label.textAlignment = NSTextAlignmentCenter;
        
        team2Label = [[UILabel alloc] initWithFrame:CGRectMake(itemWidth / 4 * 3 - 45, h / 2 + 25, 90, 30)];
        team2Label.font = FONT(18.f);
        team2Label.textColor = [UIColor whiteColor];
        team2Label.textAlignment = NSTextAlignmentCenter;
        
        UIImageView *playIcon = [[UIImageView alloc] initWithFrame:CGRectMake(11, h / 2 - 17, 16, 16)];
        playIcon.image = [UIImage imageNamed:@"vs_man_icon"];
        [topView addSubview:playIcon];
        
        sendPlayerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, h / 2, 20, 20)];
        sendPlayerLabel.font = FONT(15.f);
        sendPlayerLabel.textAlignment = NSTextAlignmentCenter;
        sendPlayerLabel.textColor = [UIColor blackColor];
        
        playIcon = [[UIImageView alloc] initWithFrame:CGRectMake(itemWidth - 10 - 20 + 1, h / 2 - 17, 16, 16)];
        playIcon.image = [UIImage imageNamed:@"vs_man_icon"];
        [topView addSubview:playIcon];
        
        recvPlayerLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemWidth - 10 - 20, h / 2, 20, 20)];
        recvPlayerLabel.font = FONT(15.f);
        recvPlayerLabel.textAlignment = NSTextAlignmentCenter;
        recvPlayerLabel.textColor = [UIColor blackColor];
        
        playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemWidth / 2 - 40, 18, 80, 20)];
        playerLabel.font = FONT(15.f);
        playerLabel.textAlignment = NSTextAlignmentCenter;
        playerLabel.textColor = [UIColor whiteColor];
        
        [topView addSubview:vsImage];
        [topView addSubview:timeLabel];
        [topView addSubview:sendClubImage];
        [topView addSubview:recvClubImage];
        [topView addSubview:vsLabel];
        [topView addSubview:team1Label];
        [topView addSubview:team2Label];
        [topView addSubview:sendPlayerLabel];
        [topView addSubview:recvPlayerLabel];
        [topView addSubview:playerLabel];
        [topView addSubview:alphaView];
        
        swipeView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60 - 20, 0, 75, h)];
        swipeView.layer.cornerRadius = 8;
        swipeView.backgroundColor = [UIColor colorWithRed:11/255.f green:197/255.f blue:96/255.f alpha:1.f];
        
        UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [joinButton setImage:IMAGE(@"schedule_func_01") forState:UIControlStateNormal];
        joinButton.frame = CGRectMake(30, h / 8 - 5, 30, 30);
        [joinButton addTarget:self action:@selector(joinButtonclick) forControlEvents:UIControlEventTouchDown];
        
        UIButton *lblJoin = [[UIButton alloc] initWithFrame:CGRectMake(30, h / 8 + 25, 30, 10)];
        lblJoin.titleLabel.font = FONT(12.f);
        lblJoin.titleLabel.textColor = [UIColor whiteColor];
        lblJoin.titleLabel.textAlignment = NSTextAlignmentCenter;
        [lblJoin addTarget:self action:@selector(joinButtonclick) forControlEvents:UIControlEventTouchDown];
        [lblJoin setTitle:LANGUAGE(@"game_schedule_join")  forState:UIControlStateNormal];
        
        UIButton *discussButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [discussButton setImage:IMAGE(@"chall_func_03") forState:UIControlStateNormal];
        discussButton.frame = CGRectMake(30, h / 4 * 3 - 20, 30, 30);
        [discussButton addTarget:self action:@selector(discussButtonClick) forControlEvents:UIControlEventTouchDown];
        
        UIButton *lblDiscuss = [[UIButton alloc] initWithFrame:CGRectMake(30, h / 4 * 3 + 10, 30, 10)];
        lblDiscuss.titleLabel.font = FONT(12.f);
        lblDiscuss.titleLabel.textColor = [UIColor whiteColor];
        lblJoin.titleLabel.textAlignment = NSTextAlignmentCenter;
        [lblDiscuss addTarget:self action:@selector(discussButtonClick) forControlEvents:UIControlEventTouchDown];
        [lblDiscuss setTitle:LANGUAGE(@"challenge_play_swipe_chat")  forState:UIControlStateNormal];
        
        [swipeView addSubview:joinButton];
        [swipeView addSubview:lblJoin];
        [swipeView addSubview:discussButton];
        [swipeView addSubview:lblDiscuss];
        
        [self.contentView addSubview:swipeView];
        [self.contentView addSubview:topView];
        
        
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeftInCell:)];
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRightInCell:)];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        
//        UIView *sendPlayerBack = [[UIView alloc] initWithFrame:CGRectMake(itemWidth / 4 - 25, h / 2 - 25, 50, 50)];
//        UIView *recvPlayerBack = [[UIView alloc] initWithFrame:CGRectMake(itemWidth / 4 * 3 - 25, h / 2 - 25, 50, 50)];
//        [topView addSubview:sendPlayerBack];
//        [topView addSubview:recvPlayerBack];
        
        UITapGestureRecognizer *leftTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLeftInCell:)];
        [sendClubImage addGestureRecognizer:leftTapGesture];
        
        UITapGestureRecognizer *rightTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapRightInCell:)];
        [recvClubImage addGestureRecognizer:rightTapGesture];
        
        
        [self.contentView addGestureRecognizer:swipeLeft];
        [self.contentView addGestureRecognizer:swipeRight];
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

#pragma Events
- (void)didSwipeLeftInCell:(UISwipeGestureRecognizer *)recognizer
{
    if (_mode)
        return;
    
    if (swiped)
        return;
    
    swiped = YES;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    topView.frame = CGRectMake(topView.frame.origin.x - 50, topView.frame.origin.y, topView.frame.size.width - 10, topView.frame.size.height);
    alphaView.frame = CGRectMake(alphaView.frame.origin.x, alphaView.frame.origin.y, alphaView.frame.size.width - 10, alphaView.frame.size.height);
    [UIView commitAnimations];
    
    [self.delegate menuDidShowInCell:self];
}

- (void)didSwipeRightInCell:(UISwipeGestureRecognizer *)recognizer
{
    if (_mode)
        return;
    
    if (!swiped)
        return;
    
    swiped = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    
    topView.frame = CGRectMake(topView.frame.origin.x + 50, topView.frame.origin.y, topView.frame.size.width + 10, topView.frame.size.height);
    alphaView.frame = CGRectMake(alphaView.frame.origin.x, alphaView.frame.origin.y, alphaView.frame.size.width + 10, alphaView.frame.size.height);
    [UIView commitAnimations];
    
    [self.delegate menuDidHideInCell];
}

- (void)didTapLeftInCell:(UITapGestureRecognizer *)gesture
{
    [self.delegate clubDetailClick:self send:YES];
}

- (void)didTapRightInCell:(UITapGestureRecognizer *)gesture
{
    [self.delegate clubDetailClick:self send:NO];
}

- (void)joinButtonclick
{
    if (_mode)
        return;
    
    [self.delegate joinGameClick:self];
}

- (void)discussButtonClick
{
    if (_mode)
        return;
    
    [self.delegate gotoDiscussRoomClick:self];
}

#pragma UserDefined
- (void)drawWithGameScheduleRecord:(GameScheduleRecord *)record
{
    timeLabel.text = [NSString stringWithFormat:@"%@/%@ %@", [record stringWithGameDate], [record stringWithGameDay], [record stringWithGameTime]];
    team1Label.text = [record stringWithHomeName];
    team2Label.text = [record stringWithAwayName];
    playerLabel.text = [NSString stringWithFormat:@"%d%@", [record intwithPlayerMode],LANGUAGE(@"player number")];
    sendPlayerLabel.text = [NSString stringWithFormat:@"%d", [record intWithHomePlayer]];
    recvPlayerLabel.text = [NSString stringWithFormat:@"%d", [record intWithAwayPlayer]];
    [self loadClubImage:[record stringWithHomeUrl] WithImageView:sendClubImage];
    [self loadClubImage:[record stringWithAwayUrl] WithImageView:recvClubImage];
    
    int n = [record intWithVsStatus];
    NSString *t = [record stringWithGameResult];
    NSArray *marks = [t componentsSeparatedByString:@":"];
    int mark1 = [[marks objectAtIndex:0] intValue];
    int mark2 = 0;
    
    if ([marks count] == 2)
        mark2 = [[marks objectAtIndex:1] intValue];
    
    int nSendClub = [record intWithHomeID];
    
    switch (n) {
        case GAME_STATUS_DELAY:
        case GAME_STATUS_JOINFINISHED:
            vsImage.image = IMAGE(@"vs_center_bg");
            vsLabel.text = @"V S";
            alphaView.hidden = YES;
            break;
        case GAME_STATUS_RUNNING:
            vsImage.image = IMAGE(@"vs_center_bg");
            vsLabel.text = [record stringWithGameResult];
            alphaView.hidden = YES;
            break;
        case GAME_STATUS_CANCELLED:
            vsImage.image = IMAGE(@"vs_center_bg");
            vsLabel.text = [record stringWithGameResult];
            alphaView.hidden = NO;
            break;
        case GAME_STATUS_FINISHED:
            if (nSendClub == nMineClub)
                vsImage.image = mark1 < mark2? IMAGE(@"vs_center_bg_02"): IMAGE(@"vs_center_bg");
            else
                vsImage.image = mark1 > mark2? IMAGE(@"vs_center_bg_02"): IMAGE(@"vs_center_bg");
            
            vsLabel.text = [record stringWithGameResult];
            alphaView.hidden = NO;
            break;
        default:
            break;
    }
    
    if (_mode)
    {
        vsLabel.text = LANGUAGE(@"tempInvite");
        vsLabel.backgroundColor = [UIColor redColor];
        vsLabel.textColor = [UIColor whiteColor];
        vsLabel.font = BOLDFONT(24.f);
    }
    else
    {
        vsLabel.backgroundColor = [UIColor clearColor];
        vsLabel.textColor = [UIColor blackColor];
        vsLabel.font = FONT(24.f);
    }
    
}

- (void)loadClubImage:(NSString *)imageUrl WithImageView:(UIImageView *)imageView
{
    if (imageUrl && ![imageUrl isEqualToString:@""])
    {
        imageView.image = [CacheManager GetCacheImageWithURL:imageUrl];
        if (!imageView.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:imageUrl];
                     imageView.image = [image circleImageWithSize:imageView.frame.size.width];
                 }
                 else
                 {
                     imageView.image = [IMAGE(@"club_icon") circleImageWithSize:imageView.frame.size.width];
                 }
                 [self setNeedsDisplay];
                 return ;
             }
             ];
        }
        else
            imageView.image = [[CacheManager GetCacheImageWithURL:imageUrl] circleImageWithSize:imageView.frame.size.width];
    }
    else
        imageView.image = [IMAGE(@"club_icon") circleImageWithSize:imageView.frame.size.width];
        
    [self setNeedsDisplay];
}

- (void)closeMenu
{
    [self didSwipeRightInCell:nil];
}
@end
