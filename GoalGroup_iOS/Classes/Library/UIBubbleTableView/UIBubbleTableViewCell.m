//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "CacheManager.h"
#import "NSBubbleData.h"
#import "UIImage+Mask.h"
#import "UIImage+Web.h"
#import "Common.h"


@interface UIBubbleTableViewCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) UIImageView *avatarImage;

- (void) setupInternalData;

@end

@implementation UIBubbleTableViewCell

@synthesize data = _data;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar = _showAvatar;
@synthesize avatarImage = _avatarImage;
@synthesize delegate = _delegate;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}

#if !__has_feature(objc_arc)
- (void) dealloc
{
    self.data = nil;
    self.customView = nil;
    self.bubbleImage = nil;
    self.avatarImage = nil;
    [super dealloc];
}
#endif

- (void)setDataInternal:(NSBubbleData *)value
{
	self.data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.backgroundColor = [UIColor ggaUserGrayBackgroundColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.bubbleImage)
    {
#if !__has_feature(objc_arc)
        self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
        self.bubbleImage = [[UIImageView alloc] init];        
#endif
        [self addSubview:self.bubbleImage];
    }
    
    NSBubbleType type = self.data.type;
    
    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;

    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
    CGFloat y = 0;
    
    // Adjusting the x coordinate for avatar
    if (self.showAvatar)
    {
        [self.avatarImage removeFromSuperview];
        self.avatarImage = [[UIImageView alloc] init];
//#if !__has_feature(objc_arc)
//        self.avatarImage = [[[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])] autorelease];
//#else
//        self.avatarImage = [[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])];
//#endif
        self.avatarImage.layer.cornerRadius = 20.0;
        self.avatarImage.layer.masksToBounds = YES;
        self.avatarImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
        self.avatarImage.layer.borderWidth = 1.0;
        self.avatarImage.userInteractionEnabled = YES;
        
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 12 : self.frame.size.width - 52;
        CGFloat avatarY = 0;//self.frame.size.height - 50;
        
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 40, 40);
        [self addSubview:self.avatarImage];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(avatarX, avatarY + 40, 40, 10)];
        nameLabel.text = self.data.avatarName;
        nameLabel.font = FONT(9.f);
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = [UIColor ggaGrayTextColor];
        [self addSubview:nameLabel];
        
        NSString *imageUrl = self.data.avatarUrl;
        if (imageUrl && ![imageUrl isEqualToString:@""])
        {
            self.avatarImage.image = [CacheManager GetCacheImageWithURL:imageUrl];
            if (!self.avatarImage.image)
            {
                [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
                 {
                     if (image)
                     {
                         [CacheManager CacheWithImage:image filename:imageUrl];
                         self.avatarImage.image = image;
                     }
                     else
                     {
                         self.avatarImage.image = IMAGE(@"man_default");
                     }
                     [self setNeedsDisplay];
                     return ;
                 }
                 ];
            }
        }
        else
            self.avatarImage.image = IMAGE(@"man_default");
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userIconClick:)];
        [self.avatarImage addGestureRecognizer:singleTapGesture];
        
        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
        if (delta > 0) y = delta;
        
        if (type == BubbleTypeSomeoneElse) x += 54;
        if (type == BubbleTypeMine) x -= 54;
    }

    NSUInteger posGapY = 11, posGapX = 0;
    
    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    self.customView.frame = CGRectMake(x + self.data.insets.left - posGapX, posGapY + 5, width, height);
    [self.contentView addSubview:self.customView];

    if (type == BubbleTypeSomeoneElse)
    {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];

    }
    else {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14]; //Modified By Boss.
    }

    switch (self.data.cellType) {
        case BubbleTypeImage:
            self.bubbleImage.frame = CGRectMake(x - posGapX - 1, posGapY, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
            self.customView.frame = CGRectMake(x + self.data.insets.left - posGapX, posGapY + 12, width, height);
            break;
        case BubbleTypeVoice:
            self.customView.frame = CGRectMake(x + self.data.insets.left - posGapX, posGapY, width, height);
            self.bubbleImage.frame = CGRectMake(x - posGapX - 4, posGapY - 1, width + self.data.insets.left + self.data.insets.right, height + 5);
            break;
        default:
            self.bubbleImage.frame = CGRectMake(x - posGapX, posGapY, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
            break;
    }
    
    if ((self.data.audioUploading && type == BubbleTypeMine))
    {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.frame = CGRectMake(self.customView.frame.origin.x - 35, posGapX + 13, 20, 20);
        [loadingView startAnimating];
        [self.contentView addSubview:loadingView];
    }
    else if (self.data.audioDownloading && type == BubbleTypeSomeoneElse)
    {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.frame = CGRectMake(self.bubbleImage.frame.origin.x + self.bubbleImage.frame.size.width + 15, posGapX + 13, 20, 20);
        [loadingView startAnimating];
        [self.contentView addSubview:loadingView];
    }
    else
    {
        if (!self.data.sendMsg && type == BubbleTypeMine)
        {
            UIImageView *noChattingImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.customView.frame.origin.x - 35, posGapX + 13, 20, 20)];
            noChattingImage.image = IMAGE(@"no_send_msg");
            [self.contentView addSubview:noChattingImage];
        }
    }
    

}

- (void)userIconClick:(UITapGestureRecognizer *)recognizer
{
    [self.delegate userIconClickForPlayerDetail:self.data.nSenderID];
}
@end
