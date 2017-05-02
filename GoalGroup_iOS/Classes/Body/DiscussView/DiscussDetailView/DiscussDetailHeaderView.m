//
//  DiscussDetailHeaderView.m
//  GoalGroup
//
//  Created by MacMini on 3/18/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DiscussDetailHeaderView.h"
#import "Common.h"

@implementation DiscussDetailHeaderView
{
    UIImageView *offerImage;
    UILabel *offerLabel;
    UILabel *dateLabel;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 62, 62)];
        backView.layer.cornerRadius = 31;
        backView.layer.masksToBounds = YES;
        backView.backgroundColor = [UIColor whiteColor];
        
        offerImage = [[UIImageView alloc] initWithFrame:CGRectMake(11, 16, 60, 60)];
        offerImage.layer.cornerRadius = 30;
        offerImage.layer.masksToBounds = YES;
        
        offerLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 35, 55, 20)];
        offerLabel.textAlignment = NSTextAlignmentLeft;
        offerLabel.textColor = [UIColor colorWithRed:140/255.f green:140/255.f blue:140/255.f alpha:140/255.f];
        offerLabel.font = FONT(14.f);
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 90, 35, 100, 20)];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        dateLabel.textColor = [UIColor colorWithRed:188/255.f green:188/255.f blue:188/255.f alpha:188/255.f];
        dateLabel.font = FONT(12.f);
        
        UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(135, 45, SCREEN_WIDTH - 230, 0.5f)];
        separateLine.backgroundColor = [UIColor blackColor];
        
        [self addSubview:backView];
        [self addSubview:separateLine];
        [self addSubview:offerImage];
        [self addSubview:dateLabel];
        [self addSubview:offerLabel];
    }
    self.backgroundColor = [UIColor ggaUserGrayBackgroundColor];
    return self;
}

- (void)drawRect:(CGRect)rect
{
}

- (void)drawHeaderWithData:(NSArray *)data
{
    dateLabel.text = [data objectAtIndex:0];
    offerLabel.text = [data objectAtIndex:1];
    
    NSString *imageUrl = [data objectAtIndex:2];
    
    if (imageUrl && ![imageUrl isEqualToString:@""])
    {
        offerImage.image = [CacheManager GetCacheImageWithURL:imageUrl];
        if (!offerImage.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:imageUrl];
                     offerImage.image = [image circleImageWithSize:offerImage.frame.size.width];
                 }
                 else
                 {
                     offerImage.image = [IMAGE(@"man_default") circleImageWithSize:offerImage.frame.size.width];
                 }
             }
             ];
        }
        else
            offerImage.image = [[CacheManager GetCacheImageWithURL:imageUrl] circleImageWithSize:offerImage.frame.size.width];
    }
    else
        offerImage.image = [IMAGE(@"man_default") circleImageWithSize:offerImage.frame.size.width];
    
    [self setNeedsDisplay];
}
@end
