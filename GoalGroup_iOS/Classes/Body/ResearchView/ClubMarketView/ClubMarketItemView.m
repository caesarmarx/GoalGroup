//
//  ClubMarketItemView.m
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubMarketItemView.h"
#import "Common.h"
#import "NSPosition.h"
#import "DistrictManager.h"
#import "NSWeek.h"

@implementation ClubMarketItemView
{
    UIView *topView;
    UIView *swipeView;
}
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        swipeView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60 - 15, 2, 60 + 13, 130 - 4)]; //Modified By Boss.2015/05/04
        swipeView.backgroundColor = [UIColor ggaThemeColor];
        
        //Added By Boss.2015/05/04 - rounded corner
        swipeView.layer.cornerRadius = 8;
        swipeView.layer.masksToBounds = YES;
        _joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_joinButton setImage:[UIImage imageNamed:@"market_club1"] forState:UIControlStateNormal];
        _joinButton.titleLabel.textColor= [UIColor blackColor];
        _joinButton.userInteractionEnabled = YES;
        _joinButton.frame = CGRectMake(24, 130 / 8, 32, 32);
        [_joinButton addTarget:self action:@selector(doJoin:) forControlEvents:UIControlEventTouchDown];
        [swipeView addSubview:_joinButton];
         
        _noticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
         [_noticeButton setImage:[UIImage imageNamed:@"market_club2"] forState:UIControlStateNormal];
        _noticeButton.titleLabel.textColor= [UIColor blackColor];
        _noticeButton.userInteractionEnabled = YES;
        _noticeButton.frame = CGRectMake(24, 130 / 8 * 4 + 14, 32, 32);
        [_noticeButton addTarget:self action:@selector(doNotice:) forControlEvents:UIControlEventTouchDown];
        [swipeView addSubview:_noticeButton];
        
        [self.contentView addSubview:swipeView];
        
        topView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, SCREEN_WIDTH - 4, 130 - 4)];
        UIGraphicsBeginImageContext(topView.frame.size);
        [[UIImage imageNamed:@"club_pane"] drawInRect:topView.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        topView.backgroundColor = [UIColor colorWithPatternImage:image];
        [self.contentView addSubview:topView];
        
        UIView *thumbBack = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        [topView addSubview:thumbBack];

        _thumbImage = [[UIImageView alloc] init];
        _thumbImage.frame = CGRectMake(0, 0, 50, 50);
        _thumbImage.layer.cornerRadius = 20;
        _thumbImage.layer.masksToBounds = YES;
        [thumbBack addSubview:_thumbImage];
        
        UIColor* color = [UIColor whiteColor];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, 100, 18)];
        [_nameLabel setTextColor:color];
        [_nameLabel setFont:FONT(15.f)];
        [topView addSubview:_nameLabel];
        
        _memberIcon =[[UIImageView alloc] init];
        _memberIcon.frame = CGRectMake(180, 7, 15, 15);
        _memberIcon.image = [UIImage imageNamed:@"club_man_ico"];
        [topView addSubview:_memberIcon];
        
        _memberLabel = [[UILabel alloc] initWithFrame:CGRectMake(203, 7, 30, 14)];
        [_memberLabel setFont:FONT(13.f)];
        [_memberLabel setTextColor:color];
        _memberLabel.numberOfLines = 1;
        [topView addSubview:_memberLabel];
        
        _rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 7, 100, 14)];
        [_rateLabel setFont:FONT(13.f)];
        [_rateLabel setTextColor:color];
        _rateLabel.numberOfLines = 1;
        _rateLabel.text =LANGUAGE(@"action rate");
        [topView addSubview:_rateLabel];
        
        UIFont *boldFont = [UIFont boldSystemFontOfSize:14];
        
        _ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 50, 60, 15)];
        [_ageLabel setFont:boldFont];
        [_ageLabel setTextColor:color];
        [topView addSubview:_ageLabel];
        
        _ageResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 50, 180, 15)];
        [_ageResultLabel setFont:FONT(12.f)];
        [_ageResultLabel setTextColor:color];
        [topView addSubview:_ageResultLabel];
        
        _weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 73, 60, 15)];
        [_weekLabel setFont:boldFont];
        [_weekLabel setTextColor:color];
        [topView addSubview:_weekLabel];
        
        _weekResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 73, 180, 15)];
        [_weekResultLabel setFont:FONT(12.f)];
        [_weekResultLabel setTextColor:color];
        [topView addSubview:_weekResultLabel];
        
        _areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 96, 60, 15)];
        [_areaLabel setFont:boldFont];
        [_areaLabel setTextColor:color];
        [topView addSubview:_areaLabel];
        
        _areaResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 96, 180, 15)];
        [_areaResultLabel setFont:FONT(12.f)];
        [_areaResultLabel setTextColor:color];
        [topView addSubview:_areaResultLabel];

        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoClubDetail:)];
        [thumbBack addGestureRecognizer:recognizer];
        
        UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftGestureInCell:)];
        leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.contentView addGestureRecognizer:leftRecognizer];
        
        UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightGestureInCell:)];
        rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self.contentView addGestureRecognizer:rightRecognizer];
        
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

- (void)drawClubWithRecord:(ClubListRecord *)record
{
    _nameLabel.text = [record stringWithClubName];
    _memberLabel.text = [NSString stringWithFormat:@"%ld", [record valueWithMembers]];
    _rateLabel.text = [NSString stringWithFormat:@"%@ : %ld",LANGUAGE(@"action rate"), [record valueWithActiveRate]];
    _ageLabel.text = LANGUAGE(@"Average_Age");
    _ageResultLabel.text = [NSString stringWithFormat:@": %ld",[record valueWithAverageAge]];
    _areaLabel.text = LANGUAGE(@"active zone with out comma");
    _areaResultLabel.text = [NSString stringWithFormat:@": %@",[[DistrictManager sharedInstance] stringAreaNamesArrayOfAreaIDs:[record stringWithActiveArea]]];
    _weekLabel.text= LANGUAGE(@"active time with out comma");
    _weekResultLabel.text= [NSString stringWithFormat:@": %@",[NSWeek stringWithIntegerWeek: [record intWithActiveWeeks]]];
    
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
                     _thumbImage.image = [IMAGE(@"club_icon") circleImageWithSize:_thumbImage.frame.size.width];
                 }
                 [self setNeedsDisplay];
             }
             ];
        }
        else
            _thumbImage.image = [[CacheManager GetCacheImageWithURL:imageUrl] circleImageWithSize:_thumbImage.frame.size.width];
    }
    else
        _thumbImage.image = [IMAGE(@"club_icon") circleImageWithSize:_thumbImage.frame.size.width];

    
    [self setNeedsDisplay];
}

#pragma Events
- (void)rightGestureInCell:(UISwipeGestureRecognizer *)recognizer
{
    if (!swiped)
        return;
    
    swiped = NO;
    [self closeMenuView];
}

#pragma Events
- (void)leftGestureInCell:(UISwipeGestureRecognizer *)recognizer
{
    if (swiped)
        return;
    
    swiped = YES;
    [self openMenuView];
}

- (void)closeMenuView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    topView.frame = CGRectMake(topView.frame.origin.x + 60, topView.frame.origin.y, topView.frame.size.width + 6, topView.frame.size.height);
    [UIView commitAnimations];
    
    [self.delegate menuDidHideInCell];
}

- (void)openMenuView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    topView.frame = CGRectMake(topView.frame.origin.x - 60, topView.frame.origin.y, topView.frame.size.width - 6, topView.frame.size.height);
    [UIView commitAnimations];
    
    [self.delegate menuDidShowInCell:self];
}

#pragma Events
- (void)doJoin:(id)sender
{
    [self.delegate doClickJoin:self];
}

- (void)doNotice:(id)sender
{
    [self.delegate doClickNotie:self fromView:sender];
}

- (void)gotoClubDetail:(UITapGestureRecognizer *)recognizer
{
    [self.delegate doClickClubDetail:self];
}

- (void)closeMenu
{
    [self rightGestureInCell:nil];
}
@end
