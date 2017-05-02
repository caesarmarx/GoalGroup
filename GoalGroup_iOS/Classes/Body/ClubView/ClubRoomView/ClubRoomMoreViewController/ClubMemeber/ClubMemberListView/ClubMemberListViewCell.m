//
//  ClubMemberListViewCell.m
//  GoalGroup
//
//  Created by KCHN on 3/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubMemberListViewCell.h"
#import "NSPosition.h"
#import "Common.h"

@implementation ClubMemberListViewCell
{
    UILabel *positionLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIView *thumbBack = [[UIView alloc] initWithFrame:CGRectMake(15, 5, 40, 40)];

        thumbImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 40, 40)];
        thumbImage.layer.cornerRadius = 20.f;
        thumbImage.layer.masksToBounds = YES;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 18, SCREEN_WIDTH - 100, 20)];
        nameLabel.font = FONT(14.f);
        nameLabel.textAlignment = NSTextAlignmentLeft;
        
        positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 25, SCREEN_WIDTH - 100, 20)];
        positionLabel.font = FONT(14.f);
        positionLabel.textAlignment = NSTextAlignmentLeft;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerClick:)];
        [thumbBack addGestureRecognizer:tapRecognizer];
        
        [self.contentView addSubview:thumbBack];
        [self.contentView addSubview:thumbImage];
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:positionLabel];
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
- (void)playerClick:(UITapGestureRecognizer *)recognizer
{
    [self.delegate memberIconClick:self];
}

#pragma UserDefined
- (void)drawListWithData:(PlayerListRecord *)record
{
    self.record = record;
    
    nameLabel.text = [record stringWithPlayerName];
    positionLabel.text = [NSPosition stringDetailWithIntegerPosition:[record intWithPosition]];
    NSString *imageUrl = [record imageUrlWithPlayerImage];
    
    if (imageUrl && ![imageUrl isEqualToString:@""])
    {
        thumbImage.image = [CacheManager GetCacheImageWithURL:imageUrl];
        if (!thumbImage.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:imageUrl];
                     thumbImage.image = [image circleImageWithSize:thumbImage.frame.size.width];
                 }
                 else
                 {
                     thumbImage.image = [IMAGE(@"man_default") circleImageWithSize:thumbImage.frame.size.width];
                 }
             }
             ];
        }
        else
            thumbImage.image = [[CacheManager GetCacheImageWithURL:imageUrl] circleImageWithSize:thumbImage.frame.size.width];
    }
    else
        thumbImage.image = [IMAGE(@"man_default") circleImageWithSize:thumbImage.frame.size.width];
    
    if ([record intWithTempState] == 1)
    {
        thumbImage.layer.borderWidth = 3.f;
        thumbImage.layer.borderColor = [UIColor redColor].CGColor;
    }
    
    
    [self setNeedsDisplay];
}
@end
