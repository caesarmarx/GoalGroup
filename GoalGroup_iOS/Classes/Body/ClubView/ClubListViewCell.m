//
//  ClubListViewCell.m
//  GoalGroup
//
//  Created by KCHN on 2/6/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubListViewCell.h"
#import "Common.h"
#import "Sqlite3Manager.h"

@implementation ClubListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        _thumbImage = [[UIImageView alloc] init];
        _thumbImage.frame = CGRectMake(5, 5, 40, 40);
        _thumbImage.userInteractionEnabled = YES;
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, SCREEN_WIDTH - 100, 40)];
        [_nameLabel setFont:FONT(15.f)];
        [_nameLabel setTextColor:[UIColor ggaTextColor]];
        
        _unreadView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 15, 20, 20)];
        _unreadView.layer.cornerRadius = 10.f;
        _unreadView.backgroundColor = [UIColor redColor];
        _unreadView.hidden = YES;
        
        _unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _unreadLabel.backgroundColor = [UIColor clearColor];
        _unreadLabel.textColor = [UIColor whiteColor];
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.font = FONT(14.f);
        [_unreadView addSubview:_unreadLabel];
        
        [self.contentView addSubview:_thumbImage];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_unreadView];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clubDetail)];
        [_thumbImage addGestureRecognizer:tapRecognizer];
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

- (void)dataWithClubRecord:(id)record
{
    _nameLabel.text = [record stringWithClubName];
    
    NSString *imageUrl = [record stringWithClubImageUrl];
    if (imageUrl && ![imageUrl isEqualToString:@""])
    {
        _thumbImage.image = [CacheManager GetCacheImageWithURL:imageUrl];
        if (!_thumbImage.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:imageUrl];
                     _thumbImage.image = [image circleImageWithSize:_thumbImage.frame.size.width];
                 }
                 else
                 {
                     _thumbImage.image = [IMAGE(@"club_default") circleImageWithSize:_thumbImage.frame.size.width];
                 }
             }
             ];
        }
        else
            _thumbImage.image = [[CacheManager GetCacheImageWithURL:imageUrl] circleImageWithSize:_thumbImage.frame.size.width];
    }
    else
        _thumbImage.image = [IMAGE(@"club_default") circleImageWithSize:_thumbImage.frame.size.width];
    
    int room = [[ClubManager sharedInstance] intRoomIDWithClubID:[record intWithClubID]];
    int unread = [[Sqlite3Manager sharedInstance] intWithUnreadMessageCountInRoom:room];
    if (unread == 0)
    {
        _unreadView.hidden = YES;
        return;
    }
    
    CGSize size = [[NSString stringWithFormat:@"%d", unread] sizeWithFont:FONT(14.f)];
    int w = size.width > 20? size.width: 20;
    
    _unreadView.frame = CGRectMake(SCREEN_WIDTH - 40, 15, w, 20);
    _unreadView.hidden = NO;
    
    _unreadLabel.frame = CGRectMake(0, 0, w, 20);
    _unreadLabel.text = [NSString stringWithFormat:@"%d", unread];

}

- (void)clubDetail
{
    [self.delegate clubDetailClick:self];
}
@end
