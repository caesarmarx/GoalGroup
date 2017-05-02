//
//  GameDetailPlayerCell.m
//  GoalGroup
//
//  Created by MacMini on 4/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "GameDetailPlayerCell.h"
#import "Common.h"

@implementation GameDetailPlayerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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
    //[super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutComponents
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(7, 10 + 25, SCREEN_WIDTH - 14, 42)];
    backView.layer.cornerRadius = 5;
    backView.layer.masksToBounds = YES;
    backView.backgroundColor = [UIColor ggaThemeGrayColor];
    [self.contentView addSubview:backView];
    
    playerImage = [[UIImageView alloc] initWithFrame:CGRectMake(11, 10, 50, 50)];
    playerImage.userInteractionEnabled = YES;
    
    UIView *playerNameView = [[UIView alloc] initWithFrame:CGRectMake(53, 25, 80, 20)];
    playerNameView.layer.cornerRadius = 10.f;
    playerNameView.layer.masksToBounds = YES;
    playerNameView.backgroundColor = [UIColor colorWithRed:9/255.f green:185/255.f blue:90/255.f alpha:1.f];
    
    playerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 70, 20)];
    playerNameLabel.layer.cornerRadius = 10;
    playerNameLabel.layer.masksToBounds = YES;
    playerNameLabel.backgroundColor = [UIColor clearColor];
    [playerNameLabel setFont:BOLDFONT(14.f)];
    playerNameLabel.textAlignment = NSTextAlignmentLeft;
    [playerNameLabel setTextColor:[UIColor whiteColor]];
    [playerNameView addSubview:playerNameLabel];
    
    UIColor *color = [UIColor colorWithRed:198/255.f green:198/255.f blue:198/255.f alpha:1.f];
    UILabel *lblGoal, *lblAsistant, *lblOther;
    
    lblGoal = [[UILabel alloc] initWithFrame:CGRectMake(125, 25, 63, 20)];
    lblGoal.textAlignment = NSTextAlignmentCenter;
    lblGoal.layer.cornerRadius = 9;
    lblGoal.layer.masksToBounds = YES;
    lblGoal.backgroundColor = color;
    lblGoal.text =[NSString stringWithFormat:@"  %@", LANGUAGE(@"ClubMarkItem_Title_5") ] ;
    [lblGoal setFont:FONT(12.f)];
    lblGoal.textColor = [UIColor colorWithRed:85/255.f green:85/255.f blue:85/255.f alpha:1.f];
    
    UIView *backView1 = [[UIView alloc] initWithFrame:CGRectMake(117, 25, 20, 20)];
    backView1.backgroundColor = [UIColor whiteColor];
    backView1.layer.cornerRadius = 9;
    backView1.layer.masksToBounds = YES;
    
    lblAsistant = [[UILabel alloc] initWithFrame:CGRectMake(180, 25, 60, 20)];
    lblAsistant.layer.cornerRadius = 10;
    lblAsistant.textAlignment = NSTextAlignmentCenter;
    lblAsistant.layer.masksToBounds = YES;
    lblAsistant.backgroundColor = color;
    lblAsistant.text =[NSString stringWithFormat:@"  %@",LANGUAGE(@"HELP ATTACK")] ;
    [lblAsistant setFont:FONT(12.f)];
    lblAsistant.textColor = [UIColor colorWithRed:85/255.f green:85/255.f blue:85/255.f alpha:1.f];
    
    UIView *backView2 = [[UIView alloc] initWithFrame:CGRectMake(172, 25, 20, 20)];
    backView2.backgroundColor = [UIColor whiteColor];
    backView2.layer.cornerRadius = 9;
    backView2.layer.masksToBounds = YES;
    
    lblOther = [[UILabel alloc] initWithFrame:CGRectMake(233, 25, 70, 20)];
    lblOther.layer.cornerRadius = 10;
    lblOther.layer.masksToBounds = YES;
    lblOther.backgroundColor = color;
    lblOther.textAlignment = NSTextAlignmentCenter;
    lblOther.text =[NSString stringWithFormat:@"   %@",LANGUAGE(@"GameDetailCell Label 1")];
    [lblOther setFont:FONT(12.f)];
    lblOther.textColor = [UIColor colorWithRed:85/255.f green:85/255.f blue:85/255.f alpha:1.f];
    
    UIView *backView3 = [[UIView alloc] initWithFrame:CGRectMake(224, 25, 20, 20)];
    backView3.backgroundColor = [UIColor whiteColor];
    backView3.layer.cornerRadius = 9;
    backView3.layer.masksToBounds = YES;
    
    [self.contentView addSubview:lblOther];
    [self.contentView addSubview:backView3];
    [self.contentView addSubview:lblAsistant];
    [self.contentView addSubview:backView2];
    [self.contentView addSubview:lblGoal];
    [self.contentView addSubview:backView1];
    [self.contentView addSubview:playerNameView];
    
    UIColor *fontColor = [UIColor colorWithRed:85/255.f green:85/255.f blue:85/255.f alpha:1.f];

    goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 50, 40, 20)];
    goalLabel.textAlignment = NSTextAlignmentCenter;
    goalLabel.textColor = fontColor;
    [goalLabel setFont:BOLDFONT(18.f)];
    
    assistantLabel = [[UILabel alloc] initWithFrame:CGRectMake(193, 50, 40, 20)];
    assistantLabel.textAlignment = NSTextAlignmentCenter;
    assistantLabel.textColor = fontColor;
    [assistantLabel setFont:BOLDFONT(18.f)];
    
    pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 50, 40, 20)];
    pointLabel.textAlignment = NSTextAlignmentCenter;
    pointLabel.textColor = fontColor;
    [pointLabel setFont:BOLDFONT(18.f)];
    
    [self.contentView addSubview:goalLabel];
    [self.contentView addSubview:assistantLabel];
    [self.contentView addSubview:pointLabel];
    
    UIView *imgView =[[UIImageView alloc] initWithFrame:CGRectMake(10, 9, 52, 52)];
    imgView.backgroundColor = [UIColor whiteColor];
    imgView.layer.cornerRadius = 26;
    imgView.layer.masksToBounds = YES;
    [self.contentView addSubview:imgView];
    [self.contentView addSubview:playerImage];
    
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerDetailClick:)];
    [playerImage addGestureRecognizer:singleRecognizer];
}

#pragma UserDefined
- (void)drawPlayerWithName:(NSString *)name image:(NSString *)imageUrl goal:(NSString *)goal assist:(NSString *)assist overall:(NSString *)point
{
    playerNameLabel.text = name;
    CGSize nameSize = [name sizeWithFont:BOLDFONT(14.f)];
    if (nameSize.width > 60)
        playerNameLabel.textAlignment = NSTextAlignmentLeft;
    else
        playerNameLabel.textAlignment = NSTextAlignmentCenter;
    
    [self loadClubImage:imageUrl WithImageView:playerImage];
    
    goalLabel.text = goal;
    assistantLabel.text = assist;
    pointLabel.text = point;
}

#pragma UserDefined
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
                     imageView.image = [IMAGE(@"man_default") circleImageWithSize:imageView.frame.size.width];
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
        imageView.image = [IMAGE(@"man_default") circleImageWithSize:imageView.frame.size.width];
    [self setNeedsDisplay];
}

- (void)playerDetailClick:(UITapGestureRecognizer *)recognizer
{
    [self.delegate playerDetailClick:self];
}

@end
