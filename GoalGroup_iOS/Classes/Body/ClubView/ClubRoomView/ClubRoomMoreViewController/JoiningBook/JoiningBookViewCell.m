//
//  JoiningBookViewCell.m
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "JoiningBookViewCell.h"
#import "Common.h"
#import "NSPosition.h"

@implementation JoiningBookViewCell
{
    UIView *topView;
    UIView *swipeView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        swiped = NO;
        // Initialization code
        UIColor *backColor = [UIColor colorWithRed:242/255.f green:242/255.f blue:242/255.f alpha:1.0f];
        topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        topView.backgroundColor = backColor;
        
        thumbImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        
        UIView *thumbBack = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [thumbBack addSubview:thumbImage];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPlayerDetail:)];
        [thumbBack addGestureRecognizer:tapGesture];
        
        namePosLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 200, 15)];
        namePosLabel.font = [UIFont boldSystemFontOfSize:12.f];
        namePosLabel.textColor = [UIColor ggaTextColor];
        
        posLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 23, 150, 15)];
        posLabel.font = FONT(12.f);
        posLabel.textColor = [UIColor ggaGrayTextColor];
        bookingDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 42, 150, 15)];
        bookingDateLabel.font = FONT(12.f);
        bookingDateLabel.textColor = [UIColor ggaGrayTextColor];
        
        UIView *agreeView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 60, 60)];
        agreeView.backgroundColor = backColor;
        
        _agreeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60 + 15, 15, 30, 30)];
        [_agreeButton setImage:IMAGE(@"invitiation_edit") forState:UIControlStateNormal];
        [_agreeButton addTarget:self action:@selector(agreeButtonClick:) forControlEvents:UIControlEventTouchDown];
        
        [topView addSubview:agreeView];
        [topView addSubview:_agreeButton];
        [topView addSubview:thumbBack];
        [topView addSubview:namePosLabel];
        [topView addSubview:posLabel];
        [topView addSubview:bookingDateLabel];
        
        UIColor *swapColor = [UIColor colorWithRed:223/255.f green:222/255.f blue:222/255.f alpha:1.0f];
        swipeView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 60, 60)];
        swipeView.backgroundColor = swapColor;
        
        _disagreeButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 30, 30)];
        [_disagreeButton setImage:IMAGE(@"invitiation_delete") forState:UIControlStateNormal];
        [_disagreeButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchDown];
        [swipeView addSubview:_disagreeButton];
        
        [self.contentView addSubview:swipeView];
        [self.contentView addSubview:topView];
        
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        
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
- (void)didSwipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    if (swiped)
        return;
    
    swiped = YES;
    
    [self openMenuView];
}

- (void)didSwipeRight:(UISwipeGestureRecognizer *)recognizer
{
    if (!swiped)
        return;
    
    swiped = NO;
    [self closeMenuView];
    
}

- (void)openMenuView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    topView.frame = CGRectMake(topView.frame.origin.x - 60, topView.frame.origin.y, topView.frame.size.width, topView.frame.size.height);
    [UIView commitAnimations];
    
    [self.delegate menuDidShowInCell:self];
}

- (void)closeMenuView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    topView.frame = CGRectMake(topView.frame.origin.x + 60, topView.frame.origin.y, topView.frame.size.width, topView.frame.size.height);
    [UIView commitAnimations];
    
    [self.delegate menuDidHideInCell];
}

- (void)agreeButtonClick:(UITapGestureRecognizer *)recognizer
{
    [self.delegate doClickAgree:self];
}

- (void)cancelButtonClick:(UITapGestureRecognizer *)recognizer
{
    [self.delegate doClickDisagress:self];
}

#pragma UserDefined
- (void)gotoPlayerDetail:(UITapGestureRecognizer *)recognizer
{
    [self.delegate doClickPlayerDetail:self];
}

- (void)drawJoiningBookWithRecord:(PlayerListRecord *)record
{
    
    NSString *str = [record stringWithPlayerName];
    namePosLabel.text = str;
    str =[record stringWithBookingDate];
    NSArray* list = [str componentsSeparatedByString:@" "];
    if (list != nil && [list count] > 0) {
        bookingDateLabel.text = (NSString*)list[0];
    }
    posLabel.text = [NSString stringWithFormat:@"%@Åy%@Åz",[NSPosition stringPrefixDetailWithIntegerPosition:[record intWithPosition]], [NSPosition stringDetailWithIntegerPosition:[record intWithPosition]]];

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
    
    [self setNeedsDisplay];
}

-(void)closeMenu
{
    [self didSwipeRight:nil];
}

@end
