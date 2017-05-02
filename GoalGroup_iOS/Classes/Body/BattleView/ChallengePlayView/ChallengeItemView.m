//
//  ChallengeItemView.m
//  GoalGroup
//
//  Created by KCHN on 2/14/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ChallengeItemView.h"
#import "Common.h"

@implementation ChallengeItemView
{
    NSInteger w;
    NSThread *thread;
}
- (id)initWithFrame:(CGRect)frame
{
    UIFont *font = (frame.size.width >= 300)? FONT(13.f): FONT(10.f);
    
    self = [super initWithFrame:frame];
    if (self) {
        sendClubImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        recvClubImage = [[UIImageView alloc] initWithFrame:CGRectMake(50, 10, 50, 50)];
    }
    center = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 12, frame.size.height / 3 - 5, frame.size.width/12 * 10, frame.size.height / 3 + 10)];
    center.layer.cornerRadius = 15;
    center.layer.masksToBounds = YES;
    center.backgroundColor = [UIColor colorWithRed:7/255.f green:118/255.f blue:58/255.f alpha:1.f];
    center.layer.opacity = 0.5;
    [self addSubview:center];
    
    centerPeople = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width / 2 - 35, frame.size.height / 3 - 17, 70, 20)];
    centerPeople.layer.cornerRadius = 10;
    centerPeople.layer.masksToBounds = YES;
    centerPeople.backgroundColor = [UIColor colorWithRed:255/255.f green:219/255.f blue:0.f alpha:1.f];
    centerPeople.textColor = [UIColor blackColor];
    centerPeople.textAlignment = NSTextAlignmentCenter;
    centerPeople.font = font;
    [self addSubview:centerPeople];
    
    lblDate = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 106, 0, 90, 20)];
    lblDate.font = font;
    lblDate.textColor = [UIColor blackColor];
    lblDate.textAlignment = NSTextAlignmentRight;
    [self addSubview:lblDate];
    
    lblClub1 = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 4 - 50, frame.size.height / 2, 100, 40)];
    lblClub1.textColor = [UIColor whiteColor];
    
    lblClub2 = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 4 * 3 - 50, frame.size.height / 2, 100, 40)];
    lblClub2.textColor = [UIColor whiteColor];
    
    lblClub1.font = font;
    lblClub2.font = font;
    
    lblClub1.textAlignment = NSTextAlignmentCenter;
    lblClub2.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:lblClub1];
    [self addSubview:lblClub2];
    
    lblStadium = [[UILabel alloc] init];
    lblStadium.font = [UIFont boldSystemFontOfSize:15.f];
    lblStadium.textColor = [UIColor whiteColor];
    lblStadium.textAlignment = NSTextAlignmentRight;
    [self addSubview:lblStadium];
    
    lblStadiumArrow = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 40, frame.size.height - 28, 20, 30)];
    lblStadiumArrow.font = [UIFont boldSystemFontOfSize:15.f];
    lblStadiumArrow.textColor = [UIColor whiteColor];
    lblStadiumArrow.textAlignment = NSTextAlignmentRight;
    lblStadiumArrow.text = @">>";
    [self addSubview:lblStadiumArrow];
    
    w = frame.size.width / 20;
    NSInteger h = frame.size.height / 10;
    
    NSInteger i = (w > h)? h:w;
    sendClubBack = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 4 - i * 2, h * 3 - i * 1.5, i * 4, i * 4)];
    recvClubBack = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 4 * 3 - i * 2, h * 3 - i * 1.5, i * 4, i * 4)];
    @try {
        [sendClubImage setFrame: CGRectMake(0, 0, i * 4, i * 4)];
        [recvClubImage setFrame: CGRectMake(0, 0, i * 4, i * 4)];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    sendClubBack.backgroundColor = [UIColor ggaTransParentColor];
    recvClubBack.backgroundColor = [UIColor ggaTransParentColor];
    [sendClubBack addSubview:sendClubImage];
    [recvClubBack addSubview:recvClubImage];
    
    [self addSubview:sendClubBack];
    [self addSubview:recvClubBack];
    
    lblTime = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 2 - 30, h * 4.5, 60, h)];
    lblTime.textAlignment = NSTextAlignmentCenter;
    lblTime.textColor = [UIColor colorWithRed:245/255.f green:211/255.f blue:3/255.f alpha:1.f];
    lblTime.font = FONT(16.f);
    
    [self addSubview:lblTime];
    
    return self;
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    [IMAGE(@"challenge_cell_bg") drawInRect:CGRectMake(5, 0, rect.size.width - 10, rect.size.height)];
    
    w = rect.size.width / 20;
    NSInteger h = rect.size.height / 10;
    
    NSInteger i = (w > h)? h:w;
    
    [[UIColor ggaTextColor] setFill];
    
    if (_detail)
    {
        centerPeople.text = playerStr;
        lblDate.text = [NSString stringWithFormat:@"%@/%@", dateStr, playDayStr];
        lblStadium.text = stadiumStr;
        lblStadiumArrow.hidden = NO;
    }
    else
        lblStadiumArrow.hidden = YES;
    
    lblClub1.text = sendClubStr;
    if (_showTeam)
        lblClub2.text = recvClubStr;
    
    UITapGestureRecognizer *sendGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoClubDetail:)];
    [sendClubBack addGestureRecognizer:sendGesture];
    
    if (_showTeam)
    {
        UITapGestureRecognizer *recvGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoClubDetail:)];
        [recvClubBack addGestureRecognizer:recvGesture];
    }
    
    if (_letterMode){
        UILabel *temp = [[UILabel alloc] init];
        temp.frame = tempInvState == 1 ? CGRectMake(rect.size.width / 4 + i - 5,  h * 3 - i * 1.5, i + 5, i + 5)
                                       : CGRectMake(rect.size.width / 4 * 3 + i - 5, h * 3 - i * 1.5, i + 5, i + 5);
        temp.layer.cornerRadius = (i + 5) / 2;
        temp.layer.masksToBounds = YES;
        temp.textAlignment = NSTextAlignmentCenter;
        temp.text = LANGUAGE(@"invitation");
        temp.textColor = [UIColor whiteColor];
        temp.backgroundColor = [UIColor redColor];
        temp.font = BOLDFONT(i);
        [self addSubview:temp];
    }
    
    [[UIColor redColor] setFill];
    lblTime.text = timeStr;
}

- (void)dataWithChallengeItem:(ChallengeListRecord *)record
{
    playDayStr = [record stringWithPlayDay];
    playerStr = [record stringWithPlayers];
    dateStr= [record stringWithPlayDate];
    timeStr = [record stringWithPlayTime];
    stadiumStr = [record stringWithPlayStadiumAddress];
    sendClubStr = [record stringWithSendClubName];
    recvClubStr = [record stringWithRecvClubName];
    vsStr = @"V S";
    
    [self loadClubImage:[record stringWithSendImageUrl] WithImageView:sendClubImage];
    
    if (_showTeam)
        [self loadClubImage:[record stringWithRecvImageUrl] WithImageView:recvClubImage];
    else
        recvClubImage.image = IMAGE(@"club_icon");
    
    sendClubID = [record intWithSendClubID];
    recvClubID = [record intWithRecvClubID];
    tempInvState = [record intWithTempInvState];

    CGRect frame = self.frame;
    if (_letterMode)
        lblStadium.frame = CGRectMake(40, frame.size.height - 28, frame.size.width - 80, 30);
    else
        lblStadium.frame = CGRectMake(frame.size.width / 2 + 20, frame.size.height - 28, frame.size.width / 2 - 62, 30);

}

- (void)gotoClubDetail:(UITapGestureRecognizer *)recognizer
{
    UIView *view = (UIView *)recognizer.view;
    [self.delegate doClickClubDetail:((view.frame.origin.x <= SCREEN_WIDTH / 2)? sendClubID: recvClubID)];
}

- (void)loadClubImage:(NSString *)imageUrl WithImageView:(UIImageView *)imageView
{
    if (imageView != nil) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        imageView.layer.masksToBounds = YES;
    }
    
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

@end
