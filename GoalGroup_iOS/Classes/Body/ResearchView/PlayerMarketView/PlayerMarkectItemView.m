//
//  PlayerMarkectItemView.m
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "Common.h"
#import "PlayerMarkectItemView.h"
#import "NSPosition.h"
#import "DistrictManager.h"
#import "NSWeek.h"

@implementation PlayerMarkectItemView
{
    UIView *topView;
    UIView *swipeView;
    UIView *thumbBack;
}
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        swipeView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60 - 15, 3, 60 + 13, 130 - 5)]; //Modified By Boss.2015/05/04
        swipeView.backgroundColor = [UIColor ggaThemeColor];
        
        _recommendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recommendButton setImage:[UIImage imageNamed:@"market_item1"] forState:UIControlStateNormal];
        _recommendButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _recommendButton.titleLabel.textColor= [UIColor blackColor];
        _recommendButton.userInteractionEnabled = YES;
        _recommendButton.frame = CGRectMake(25, 130/4 - 20, 30, 30);
        [_recommendButton addTarget:self action:@selector(DoRecommend:) forControlEvents:UIControlEventTouchDown];
        [swipeView addSubview:_recommendButton];
        
        _tempInviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tempInviteButton setImage:[UIImage imageNamed:@"market_item2"] forState:UIControlStateNormal];
        _tempInviteButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _tempInviteButton.titleLabel.textColor= [UIColor blackColor];
        _tempInviteButton.userInteractionEnabled = YES;
        _tempInviteButton.frame = CGRectMake(25, 130 / 2 - 16, 30, 30);
        [_tempInviteButton addTarget:self action:@selector(DoTempInvite:) forControlEvents:UIControlEventTouchDown];
        [swipeView addSubview:_tempInviteButton];

        _inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_inviteButton setImage:[UIImage imageNamed:@"market_item3"] forState:UIControlStateNormal];
        _inviteButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _inviteButton.titleLabel.textColor= [UIColor blackColor];
        _inviteButton.userInteractionEnabled = YES;
        _inviteButton.frame = CGRectMake(25, 130 / 4 * 3 - 10, 30, 30);
        [_inviteButton addTarget:self action:@selector(DoInvite:) forControlEvents:UIControlEventTouchDown];
        [swipeView addSubview:_inviteButton];
        
        //Added By Boss.2015/05/04 - rounded corner
        swipeView.layer.cornerRadius = 8;
        swipeView.layer.masksToBounds = YES;
        [self.contentView addSubview:swipeView];
        
        topView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, SCREEN_WIDTH - 4, 130 - 4)]; //Added By Boss.2015/05/02
        UIGraphicsBeginImageContext(topView.frame.size);
        [[UIImage imageNamed:@"player_pane"] drawInRect:topView.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        topView.backgroundColor = [UIColor colorWithPatternImage:image];
        
        UIColor* color = [UIColor whiteColor];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 150, 18)];
        [_nameLabel setFont:FONT(14.f)];
        [_nameLabel setTextColor:color];
        [topView addSubview:_nameLabel];

        _thumbImage = [[UIImageView alloc] init];
        _thumbImage.frame = CGRectMake(1, 1, 50, 50);
        _thumbImage.layer.cornerRadius = 22;
        _thumbImage.layer.masksToBounds = YES;

        thumbBack = [[UIView alloc] initWithFrame:CGRectMake(10, swipeView.frame.size.height / 2 - 27, 52, 52)];
        thumbBack.layer.cornerRadius = 25;
        thumbBack.layer.masksToBounds = YES;
        thumbBack.backgroundColor = color;
        [thumbBack addSubview:_thumbImage];
        [topView addSubview:thumbBack];
        
        _ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, 100, 12)];
        [_ageLabel setFont:FONT(12.f)];
        [_ageLabel setTextColor:color];
        _ageLabel.numberOfLines = 1;
        [topView addSubview:_ageLabel];

        _footballAgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 30, 100, 12)];
        [_footballAgeLabel setFont:FONT(12.f)];
        [_footballAgeLabel setTextColor:color];
        _footballAgeLabel.numberOfLines = 1;
        [topView addSubview:_footballAgeLabel];

        _heightLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 45, 100, 12)];
        [_heightLabel setFont:FONT(12.f)];
        [_heightLabel setTextColor:color];
        _heightLabel.numberOfLines = 1;
        [topView addSubview:_heightLabel];

        _weightLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 45, 100, 12)];
        [_weightLabel setFont:FONT(12.f)];
        [_weightLabel setTextColor:color];
        _weightLabel.numberOfLines = 1;
        [topView addSubview:_weightLabel];

        UIFont *boldFont = [UIFont boldSystemFontOfSize:14];
        _posLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 65, 60, 15)];
        [_posLabel setFont:boldFont];
        [_posLabel setTextColor:color];
        [topView addSubview:_posLabel];
        
        _posResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 65, 170, 15)];
        [_posResultLabel setFont:FONT(12.f)];
        [_posResultLabel setTextColor:color];
        [topView addSubview:_posResultLabel];
        _weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 85, 60, 15)];
        [_weekLabel setFont:boldFont];
        [_weekLabel setTextColor:color];
        [topView addSubview:_weekLabel];
        
        _weekResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 85, 170, 15)];
        [_weekResultLabel setFont:FONT(12.f)];
        [_weekResultLabel setTextColor:color];
        [topView addSubview:_weekResultLabel];
        _areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 105, 60, 15)];
        [_areaLabel setFont:boldFont];
        [_areaLabel setTextColor:color];
        [topView addSubview:_areaLabel];
        _areaResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 105, 170, 15)];
        [_areaResultLabel setFont:FONT(12.f)];
        [_areaResultLabel setTextColor:color];
        [topView addSubview:_areaResultLabel];
        [self.contentView addSubview:topView];

        UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightGestureInCell:)];
        rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
        [self.contentView addGestureRecognizer:rightGesture];
        
        UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftGestureInCell:)];
        leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.contentView addGestureRecognizer:leftGesture];
        
        UITapGestureRecognizer *singleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPlayerDetail:)];
        [thumbBack addGestureRecognizer:singleGesture];
        
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

- (void)drawRect:(CGRect)rect
{
    [IMAGE(@"player_pane") drawInRect:topView.bounds];
}

#pragma Events
- (void)rightGestureInCell:(UISwipeGestureRecognizer *)recognizer
{
    if (!swiped)
        return;
    
    swiped = NO;
    [self closeMenuView];
}

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
-(void)DoRecommend:(id)btn{
    [self.delegate doClickRecommend:self];
}

-(void)DoTempInvite:(id)btn{
    [self.delegate doClickTempInvite:self withFromView:_tempInviteButton];
}

-(void)DoInvite:(id)btn{
    [self.delegate doClickInvite:self withFromView:_inviteButton];
}

- (void)gotoPlayerDetail:(UITapGestureRecognizer *)recognizer
{
    [self.delegate doClickPlayerDetail:self];
}

- (void)drawPlayerWithRecord:(PlayerListRecord *)record
{
    
    _nameLabel.text = [record stringWithPlayerName];
    _ageLabel.text = [NSString stringWithFormat:@"%@: %d",LANGUAGE(@"AGE_AGE"), [record valueWithAge]];
    _footballAgeLabel.text = [NSString stringWithFormat:@"%@: %d",LANGUAGE(@"FOOTBALLAGE"), [record valueWithFootballAge]];
    _heightLabel.text = [NSString stringWithFormat:@"%@: %d",LANGUAGE(@"HEIGHT"), [record valueWithHeight]];
    _weightLabel.text = [NSString stringWithFormat:@"%@: %d",LANGUAGE(@"MAINWEIGHT"), [record valueWithWeight]];
    
    _posLabel.text = LANGUAGE(@"POSITION");
    _posResultLabel.text = [NSString stringWithFormat:@": %@",[NSPosition formattedStringFromPLAYERDETAIL_POSITIONInARow:[NSPosition stringDetailWithIntegerPosition:[record intWithPosition]]]];
    _areaLabel.text= LANGUAGE(@"active zone with out comma");
    _areaResultLabel.text= [NSString stringWithFormat:@": %@",[[DistrictManager sharedInstance] stringAreaNamesArrayOfAreaIDs:[record stringWithArea]]];
    _weekLabel.text = LANGUAGE(@"SEARCH_COND_WEEK");
    _weekResultLabel.text = [NSString stringWithFormat:@": %@",[NSWeek stringWithIntegerWeek:[record intWithWeek]]];
    
    NSString *imageUrl = [record imageUrlWithPlayerImage];
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
                     _thumbImage.image = [IMAGE(@"man_default") circleImageWithSize:_thumbImage.frame.size.width];
                 }
                 [self setNeedsDisplay];
             }];
        }
        else
            _thumbImage.image = [[CacheManager GetCacheImageWithURL:imageUrl] circleImageWithSize:_thumbImage.frame.size.width];
    }
    else
        _thumbImage.image = [IMAGE(@"man_default") circleImageWithSize:_thumbImage.frame.size.width];
    
    [self setNeedsDisplay];
}

- (void)closeMenu
{
    [self rightGestureInCell:nil];
}
@end
