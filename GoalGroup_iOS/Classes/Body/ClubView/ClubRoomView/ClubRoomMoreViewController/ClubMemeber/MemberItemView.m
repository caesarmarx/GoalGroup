//
//  MemberItemView.m
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "MemberItemView.h"
#import "Common.h"

@implementation MemberItemView
{
    UIColor *borderColor;
}

@synthesize healthEffect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        borderColor = nil;
        healthEffect = YES;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoDetailView:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)drawCorchWithRecord:(PlayerListRecord *)record
{
    borderColor = [UIColor colorWithRed:1.f green:219.f/255.f blue:0.f alpha:1.f];
    [self drawWithRecord:record];
}

- (void)drawCaptainWithRecord:(PlayerListRecord *)record
{
    borderColor = [UIColor colorWithRed:56.f/255.f green:190.f/255.f blue:244.f/255.f alpha:1.f];
    [self drawWithRecord:record];
}

- (void)drawWithRecord:(PlayerListRecord *)record
{
    self.record = record;
    
    if (borderColor == nil)
    {
        int userType = [record intWithUserType];
        if ((userType & CLUB_USER_POST_CAPTAIN) == CLUB_USER_POST_CAPTAIN)
            borderColor = [UIColor colorWithRed:56.f/255.f green:190.f/255.f blue:244.f/255.f alpha:1.f];
        else if ((userType & CLUB_USER_POST_CORCH) == CLUB_USER_POST_CORCH)
            borderColor = [UIColor colorWithRed:1.f green:219.f/255.f blue:0.f alpha:1.f];
        else if (borderColor == nil)
            borderColor = [UIColor whiteColor];
    }
    
    NSString *imageUrl = [record imageUrlWithPlayerImage];
    if (imageUrl && ![imageUrl isEqualToString:@""])
    {
        memberThumbImage = [CacheManager GetCacheImageWithURL:imageUrl];
        
        if (!memberThumbImage)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     image = [image circleImageWithSize:image.size.width];
                     [CacheManager CacheWithImage:image filename:imageUrl];
                     memberThumbImage = image;
                 }
                 else
                 {
                     memberThumbImage = IMAGE(@"man_default");
                 }
                 if (borderColor != nil)
                     memberThumbImage = [memberThumbImage imageAsCircle:YES
                                                            withDiamter:memberThumbImage.size.width
                                                            borderColor:borderColor
                                                            borderWidth:6.f
                                                           shadowOffSet:memberThumbImage.size
                                         ];
                 [self setNeedsDisplay];
             }];
        }
        else
            memberThumbImage = [[CacheManager GetCacheImageWithURL:imageUrl] circleImageWithSize:memberThumbImage.size.width];
    }
    else
        memberThumbImage = IMAGE(@"man_default");
    
    nameStr = [record stringWithPlayerName];
    healthState = [record valueWithHealth];
    nUserType = [record intWithUserType];
    nPlayerId = [record intWithPlayerID];
    nTempState = [record intWithTempState];
    
    if (nTempState ==1)
        borderColor = [UIColor redColor];

    memberThumbImage = [memberThumbImage imageAsCircle:YES
                                            withDiamter:memberThumbImage.size.width
                                            borderColor:borderColor
                                            borderWidth:6.f
                                            shadowOffSet:memberThumbImage.size
                            ];
    
    [self setNeedsDisplay];
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSInteger width = rect.size.width;
    CGFloat nap = width / 12.f;
    
    [memberThumbImage drawInRect:CGRectMake(nap * 2, 0, nap * 8, nap * 8)];
    [nameStr drawInRect:CGRectMake(0, nap * 8, width, nap * 4)
               withFont:SCREEN_HEIGHT > 480? FONT(16.f) : FONT(12.f)
          lineBreakMode:NSLineBreakByCharWrapping
              alignment:NSTextAlignmentCenter
     ];
    if (healthState && healthEffect)
        [IMAGE(@"health_mark") drawInRect:CGRectMake(6 * nap + 3, 0, nap * 3, nap * 3)];
}

- (void)gotoDetailView:(UITapGestureRecognizer *)recognizer
{
    [self.delegate memberItemClicked:self withUserType:nUserType withPlayerId:nPlayerId];
}
@end
