//
//  DemandLetterItemView.m
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DemandLetterItemView.h"
#import "Common.h"

@implementation DemandLetterItemView
{
    UIView *topView;
    UIView *swipeView;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        swiped = NO;
        
        UIColor *backColor = [UIColor colorWithRed:242/255.f green:242/255.f blue:242/255.f alpha:1.0f];
        topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        topView.backgroundColor = backColor;
        
        UIView *thumbBack = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        thumbImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        thumbImage.layer.cornerRadius = 20;
        thumbImage.layer.masksToBounds = YES;
        titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(60, 15, 200, 15)];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:13.f]];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, 150, 15)];
        dateLabel.font = FONT(12.f);
        dateLabel.textColor = [UIColor ggaGrayTextColor];

        UIView *agreeView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 60, 60)];
        agreeView.backgroundColor = backColor;
        
        _agreeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60 + 15, 15, 30, 30)];
        [_agreeButton setImage:IMAGE(@"invitiation_edit") forState:UIControlStateNormal];
        [_agreeButton addTarget:self
                         action:@selector(agreeButtonClick:) forControlEvents:UIControlEventTouchDown];

        [topView addSubview:thumbBack];
        [topView addSubview:agreeView];
        [topView addSubview:_agreeButton];
        [topView addSubview:thumbImage];
        [topView addSubview:titleLabel];
        [topView addSubview:dateLabel];
        
        UIColor *swapColor = [UIColor colorWithRed:223/255.f green:222/255.f blue:222/255.f alpha:1.0f];
        swipeView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 60, 60)];
        swipeView.backgroundColor = swapColor;
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 30, 30)];
        [_cancelButton setImage:IMAGE(@"invitiation_delete") forState:UIControlStateNormal];
        [_cancelButton addTarget:self
                          action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchDown];
        [swipeView addSubview:_cancelButton];
        
        
        [self.contentView addSubview:swipeView];
        [self.contentView addSubview:topView];
        
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        
        [self.contentView addGestureRecognizer:swipeLeft];
        [self.contentView addGestureRecognizer:swipeRight];
        
        UITapGestureRecognizer *singleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clubIconClick:)];
        [thumbBack addGestureRecognizer:singleGesture];

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated]; //Modified By Boss.2015/05/04

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

#pragma Events
- (void)didSwipeRight:(UISwipeGestureRecognizer *)recognizer
{
    if (!swiped)
        return;
    
    swiped = NO;
    
    [self closeMenuView];
}

#pragma UserDefine
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

- (void)clubIconClick:(UITapGestureRecognizer *)recognizer
{
    [self.delegate doClickClubDetail:self];
}

- (void)drawDemandLetterWithRecord:(DemandListRecord *)record
{
    NSString *url = [record imageUrlWithDemandLetter];
    
    if (url  && ![url isEqualToString:@""])
    {
        thumbImage.image = [CacheManager GetCacheImageWithURL:url];
        if (!thumbImage.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:url] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:url];
                     thumbImage.image = [image circleImageWithSize:thumbImage.frame.size.width];
                 }
                 else
                     thumbImage.image = [IMAGE(@"club_default") circleImageWithSize:thumbImage.frame.size.width];
                 [self setNeedsDisplay];
             }
             ];
        }
        else
            thumbImage.image = [[CacheManager GetCacheImageWithURL:url] circleImageWithSize:thumbImage.frame.size.width];
    }
    else
        thumbImage.image = [IMAGE(@"club_default") circleImageWithSize:thumbImage.frame.size.width];
    
    titleLabel.text = [NSString stringWithFormat:@"%@%@", [record stringWithTitle],LANGUAGE(@"DemandLetterItem Title")];
    dateLabel.text = [NSString stringWithFormat:@"%@", [record stringWithDate]]; //Modified By Boss.2015/05/04
    [self setNeedsDisplay];
}

- (void)closeMenu
{
    [self didSwipeRight:nil];
}
@end
