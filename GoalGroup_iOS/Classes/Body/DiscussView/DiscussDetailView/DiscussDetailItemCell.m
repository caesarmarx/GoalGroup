//
//  DiscussDetailItemCell.m
//  GoalGroup
//
//  Created by KCHN on 2/13/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DiscussDetailItemCell.h"
#import "Common.h"

@interface DiscussDetailItemCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *backImage;

- (void) setupInternalData;

@end


@implementation DiscussDetailItemCell

@synthesize data = _data;
@synthesize customView = _customView;
@synthesize backImage = _backImage;

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
    self.backImage = nil;
    [super dealloc];
}
#endif

- (void)setDataInternal:(DiscussDetailItemData *)value
{
	self.data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor ggaUserGrayBackgroundColor];
    
    if (!self.backImage)
    {
#if !__has_feature(objc_arc)
        self.backImage = [[[UIImageView alloc] init] autorelease];
#else
        self.backImage = [[UIImageView alloc] init];
#endif
        [self addSubview:self.backImage];
    }
    
    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;
    
    CGFloat x = self.frame.size.width - width - 10;
    CGFloat y = 0;
    
    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    self.customView.frame = CGRectMake(x + 5, y + 10, width, height);
    [self.contentView addSubview:self.customView];
}
@end
