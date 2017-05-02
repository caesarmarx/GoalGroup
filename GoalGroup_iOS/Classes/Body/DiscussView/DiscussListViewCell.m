//
//  DiscussListViewCell.m
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DiscussListViewCell.h"
#import "Common.h"
#import "DiscussListRecord.h"

@implementation DiscussListViewCell
{
    UIView *offerView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        backView = [[UIView alloc] initWithFrame:CGRectMake(10, 35, SCREEN_WIDTH - 20, 75)];//60
        backView.backgroundColor = [UIColor ggaGrayBackColor];
        backView.layer.cornerRadius = 5.f;
        
        thumbOffer = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 50, 50)];

        thumbDiscuss = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, 40, 60, 60)];
        thumbDiscuss.layer.cornerRadius = 5.f;
        thumbDiscuss.layer.masksToBounds = YES;
        
        offerView = [[UIView alloc] initWithFrame:CGRectMake(70 - 25, 35 - 10, 100, 20)];
        offerView.backgroundColor = [UIColor ggaThemeColor];
        offerView.layer.cornerRadius = 10.f;
        
        offerLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 65, 20)];
        [offerLabel setTextAlignment:NSTextAlignmentLeft];
        offerLabel.backgroundColor = [UIColor clearColor];
        [offerLabel setFont:FONT(15.f)];
        [offerLabel setTextColor:[UIColor whiteColor]];
        [offerView addSubview:offerLabel];
        
        introLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 35 + 15, SCREEN_WIDTH - 80 , 60)];//50
        [introLabel setFont:FONT(14.f)];
        [introLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [introLabel setNumberOfLines:3];
        [introLabel setTextColor:[UIColor ggaTextColor]];
        
        articleBack = [[UIImageView alloc] init];
        articleBack.frame = CGRectMake(45 - 10 / 2, 60 - 10, 10, 20);
        articleBack.layer.cornerRadius = 10;
        articleBack.backgroundColor = [UIColor redColor];
        articleBack.hidden = YES;
        
        articles = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
        articles.textAlignment = NSTextAlignmentCenter;
        articles.font = FONT(14.f);
        articles.textColor = [UIColor whiteColor];
        [articleBack addSubview:articles];

        [self.contentView addSubview:backView];
        [self.contentView addSubview:offerView];
        [self.contentView addSubview:thumbOffer];
        [self.contentView addSubview:thumbDiscuss];
        [self.contentView addSubview:introLabel];
        [self.contentView addSubview:articleBack];
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
#pragma UserDefined
- (void)dataWithDiscussRecord:(DiscussListRecord *)record
{
    
    offerLabel.text = [record stringWithOffer];
    introLabel.text = [record stringWithIntroduce];
    
    if ([record intWithReplyCount] > 0){
        NSString *articleCnt = [NSString stringWithFormat:@"%d", [record intWithReplyCount]];
        CGSize size = [articleCnt sizeWithFont:FONT(14.f) constrainedToSize:CGSizeMake(40, 20)];
        
        size.width = size.width < 20? 20:size.width;
        
        articleBack.frame = CGRectMake(45 - size.width / 2, 60 - 10, size.width, 20);
        articleBack.hidden = NO;
        
        articles.frame = CGRectMake(0, 0, size.width, 20);
        articles.text = articleCnt;

        [self setNeedsDisplay];
    }
    else
        articleBack.hidden = YES;
    
    NSString *nameStr = [record stringWithOffer];
    CGSize nameSize = [nameStr sizeWithFont:FONT(15.f) constrainedToSize:CGSizeMake(100, 20)];
    [offerView setFrame:CGRectMake(offerView.frame.origin.x, offerView.frame.origin.y, nameSize.width + 35, 20)];
    [offerLabel setFrame:CGRectMake(offerLabel.frame.origin.x, offerLabel.frame.origin.y, nameSize.width, 20)];
    
    
    NSString *playerUrl = [record imageWithOfferUrl];
    if (playerUrl && ![playerUrl isEqualToString:@""])
    {
        thumbOffer.image = [CacheManager GetCacheImageWithURL:playerUrl];
        if (!thumbOffer.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:playerUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:playerUrl];
                     thumbOffer.image = [image imageAsCircle:YES withDiamter:thumbOffer.frame.size.width borderColor:[UIColor whiteColor] borderWidth:2.f shadowOffSet:thumbOffer.frame.size];
                 }
                 else
                 {
                     thumbOffer.image = [IMAGE(@"man_default") imageAsCircle:YES withDiamter:thumbOffer.frame.size.width borderColor:[UIColor whiteColor] borderWidth:2.f shadowOffSet:thumbOffer.frame.size];
                 }
                 
                 [self setNeedsDisplay];
             }
             ];
        }
        else
            thumbOffer.image = [[CacheManager GetCacheImageWithURL:playerUrl] imageAsCircle:YES withDiamter:thumbOffer.frame.size.width borderColor:[UIColor whiteColor] borderWidth:2.f shadowOffSet:thumbOffer.frame.size];
    }
    else
        thumbOffer.image = [IMAGE(@"man_default") imageAsCircle:YES withDiamter:thumbOffer.frame.size.width borderColor:[UIColor whiteColor] borderWidth:2.f shadowOffSet:thumbOffer.frame.size];

    NSString *contentUrl = [record imageWithDiscussUrl];
    
    if (contentUrl && ![contentUrl isEqualToString:@""])
    {
        thumbDiscuss.image = [CacheManager GetCacheImageWithURL:contentUrl];
        if (!thumbDiscuss.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:contentUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:contentUrl];
                     thumbDiscuss.image = image;
                 }
             }
             ];
        }
        introLabel.frame = CGRectMake(introLabel.frame.origin.x, introLabel.frame.origin.y, SCREEN_WIDTH - 80 - 60, introLabel.frame.size.height);
        [self addSubview:thumbDiscuss];
    }
    else
    {
        [thumbDiscuss removeFromSuperview];
        introLabel.frame = CGRectMake(introLabel.frame.origin.x, introLabel.frame.origin.y, SCREEN_WIDTH - 80, introLabel.frame.size.height);
    }
    
    [self setNeedsDisplay];

}

@end
