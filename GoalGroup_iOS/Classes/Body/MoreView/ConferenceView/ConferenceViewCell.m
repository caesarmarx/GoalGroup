//
//  ConferenceViewCell.m
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ConferenceViewCell.h"
#import "Common.h"
#import "Utils.h"

@implementation ConferenceViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor ggaUserGrayBackgroundColor];
        
        thumbSendImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        thumbRecvImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, 10, 40, 40)];

        sendClubName = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, 70, 30)];
        sendClubName.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
        sendClubName.font = FONT(15.f);
        sendClubName.textAlignment = NSTextAlignmentLeft;
        
        recvClubName = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60 - 70, 20, 70, 30)];
        recvClubName.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
        recvClubName.font = FONT(15.f);
        recvClubName.textAlignment = NSTextAlignmentRight;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, 20, 80, 22)];
        imgView.image = [UIImage imageNamed:@"vs_center_bg"];
        
        playersLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 70, 22)];
        playersLabel.textColor = [UIColor whiteColor];
        playersLabel.textAlignment = NSTextAlignmentCenter;
        playersLabel.font = FONT(14.f);
        [imgView addSubview:playersLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 60, 10, 120, 13)];
        dateLabel.backgroundColor = [UIColor colorWithRed:0.f green:151/255.f blue:69/255.f alpha:1.f];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.font = BOLDFONT(13.f);
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.layer.cornerRadius = 6;
        dateLabel.layer.masksToBounds = YES;
        
        UIView *chatView = [[UIView alloc] initWithFrame:CGRectMake(30, 50, SCREEN_WIDTH - 60, 20)];
        chatView.layer.cornerRadius = 10;
        chatView.layer.masksToBounds = YES;
        chatView.backgroundColor = [UIColor colorWithRed:133/255.f green:133/255.f blue:133/255.f alpha:1.f];
        
        lastChatLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, chatView.frame.size.width - 8, 20)];
        lastChatLabel.font = FONT(12.5f);
        lastChatLabel.textColor = [UIColor whiteColor];
        [chatView addSubview:lastChatLabel];
        
        unreadView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, 60, 10, 10)];
        unreadLabel = [[UILabel alloc] init];
        [unreadView addSubview:unreadLabel];
        
        [self.contentView addSubview:thumbRecvImage];
        [self.contentView addSubview:thumbSendImage];
        [self.contentView addSubview:sendClubName];
        [self.contentView addSubview:recvClubName];
        [self.contentView addSubview:imgView];
        [self.contentView addSubview:dateLabel];
        [self.contentView addSubview:chatView];
        [self.contentView addSubview:unreadView];
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

- (void)drawConferenceWithRecord:(ConferenceListRecord *)record
{
    NSString *imageUrl = [record stringWithSendClubImage];
    if (imageUrl && ![imageUrl isEqualToString:@""])
    {
        thumbSendImage.image = [CacheManager GetCacheImageWithURL:imageUrl];
        if (!thumbSendImage.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:imageUrl];
                     thumbSendImage.image = [image circleImageWithSize:thumbSendImage.frame.size.width];
                 }
                 else
                 {
                     thumbSendImage.image = [IMAGE(@"club_default") circleImageWithSize:thumbSendImage.frame.size.width];
                 }
             }
             ];
        }
        else
            thumbSendImage.image = [[CacheManager GetCacheImageWithURL:imageUrl] circleImageWithSize:thumbSendImage.frame.size.width];
    }
    else
        thumbSendImage.image = [IMAGE(@"club_default") circleImageWithSize:thumbSendImage.frame.size.width];
    
    imageUrl = [record stringWithRecvClubImage];
    if (imageUrl && ![imageUrl isEqualToString:@""])
    {
        thumbRecvImage.image = [CacheManager GetCacheImageWithURL:imageUrl];
        if (!thumbRecvImage.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:imageUrl];
                     thumbRecvImage.image = [image circleImageWithSize:thumbRecvImage.frame.size.width];
                 }
                 else
                 {
                     thumbRecvImage.image = [IMAGE(@"club_default") circleImageWithSize:thumbRecvImage.frame.size.width];
                 }
                 [self setNeedsDisplay];
             }
             ];
        }
        else
            thumbRecvImage.image = [[CacheManager GetCacheImageWithURL:imageUrl] circleImageWithSize:thumbRecvImage.frame.size.width];
    }
    else
        thumbRecvImage.image = [IMAGE(@"club_default") circleImageWithSize:thumbSendImage.frame.size.width];


    
    sendClubName.text = [record stringWithTeam1];
    recvClubName.text = [record stringWithTeam2];
    
    lastChatLabel.text = [record stringWithLastMsgChatter];

    NSDateFormatter *outformat = [[NSDateFormatter alloc] init];
    [outformat setDateFormat:@"yyyy-MM-dd"];
    
    NSString *strTmp = [record stringWithGameDateTime];
    NSString *strDate = [strTmp substringToIndex:10];
    
    NSDate *dateTmp = [outformat dateFromString:strDate];
    
    [outformat setDateFormat:@"MM-dd"];
    strDate = [outformat stringFromDate:dateTmp];
    
    NSString *strTime = [[strTmp substringFromIndex:11] substringToIndex:5];
    
    [outformat setDateFormat:@"e"];
    NSInteger weekdayNumber = (NSInteger)[[outformat stringFromDate:dateTmp] integerValue];
    
    dateLabel.text = [ NSString stringWithFormat:@"%@/%@ %@", strDate, [Utils stringWithWeekDay:weekdayNumber], strTime];
    playersLabel.text = [NSString stringWithFormat:@"%d%@", [record intWithGamePlayers],LANGUAGE(@"player number")];

    [self setNeedsDisplay];
    
    int unread = [record intWithUnreadCount];
    if (unread == 0)
    {
        unreadView.hidden = YES;
        return;
    }
    
    NSString *unreadStr = [NSString stringWithFormat:@"%d", unread];
    CGSize size = [unreadStr sizeWithFont:FONT(13.f)];
    int nW = size.width > 10? size.width + 10: 20;

    unreadView.frame = CGRectMake(SCREEN_WIDTH - 50, 50, nW, 20);
    unreadView.layer.cornerRadius = 10;
    unreadView.layer.masksToBounds = YES;
    unreadView.hidden = NO;
    unreadView.backgroundColor = [UIColor redColor];
    
    unreadLabel.frame = CGRectMake(0, 0, nW, 20);
    unreadLabel.text = unreadStr;
    unreadLabel.textColor = [UIColor whiteColor];
    unreadLabel.textAlignment = NSTextAlignmentCenter;
    
    
    [self setNeedsDisplay];
}

@end
