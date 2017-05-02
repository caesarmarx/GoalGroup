//
//  DiscussDetailItemData.m
//  GoalGroup
//
//  Created by MacMini on 3/18/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DiscussDetailItemData.h"
#import "Common.h"

@implementation DiscussDetailItemData
{
    NSString *overString;
}

//@synthesize date = _date;
@synthesize type = _type;
@synthesize view = _view;
@synthesize record = _record;


const UIEdgeInsets textInsetsMine1 = {5, 10, 11, 17};

- (id)initWithRecord:(DiscussDetailListRecord *)record after:(NSString *)who
{
    self.record = record;
    
    if (record.discussDeep == -1)
        return [self initWithText:record.contentStr
                            image:record.imageUrl
                             deep:record.discussDeep];
    else
    {
        return [self initWithText:record.contentStr
                             name:record.nameStr
                            majorName:who
                             deep:record.discussDeep];
    }
}

- (id)initWithText:(NSString *)text name:(NSString *)name majorName:(NSString *)majorName deep:(int)d
{
    UIFont *font = [UIFont systemFontOfSize:13.f];
    UIColor *colorText = [UIColor colorWithRed:108/255.f green:108/255.f blue:108/255.f alpha:1.f];
    
    int replyWidth = SCREEN_WIDTH - 20;
    int deep = (self.record.discussDeep + 1) * 8;

    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(replyWidth - 18, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(deep, 35, size.width, size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.text = (text ? text : @"");
    label.textColor = colorText;
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(deep, 12, [name sizeWithFont:FONT(14.f)].width, 20)];
    UILabel *gap = [[UILabel alloc] initWithFrame:CGRectMake(deep + nameLabel.frame.size.width, 12, 35, 20)];
    UILabel *majorLabel = [[UILabel alloc] initWithFrame:CGRectMake(deep + nameLabel.frame.size.width + gap.frame.size.width, 12, SCREEN_WIDTH - 100 - nameLabel.frame.size.width, 20)];
    
    gap.text = LANGUAGE(@"restore");
    gap.textAlignment = NSTextAlignmentCenter;
    gap.font = FONT(14.f);
    gap.textColor = [UIColor colorWithRed:184/255.f green:184/255.f blue:184/255.f alpha:1.f];
    
    nameLabel.font = FONT(14.f);
    nameLabel.text = name;
    nameLabel.textColor = [UIColor colorWithRed:11/255.f green:196/255.f blue:97/255.f alpha:1.f];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(replyWidth - 100 - 15, 15, 100, 10)];
    dateLabel.font = FONT(10.f);
    dateLabel.text = self.record.dateStr;
    dateLabel.textAlignment = NSTextAlignmentRight;
    dateLabel.textColor = [UIColor colorWithRed:184/255.f green:184/255.f blue:184/255.f alpha:1.f];
    dateLabel.backgroundColor = [UIColor clearColor];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, replyWidth, size.height + 20)];
    UIImageView *backImage = [[UIImageView alloc] init];
    
    if (self.record.discussDeep != -1)
    {
        backImage.image = [[UIImage imageNamed:@"discuss_back_item"] stretchableImageWithLeftCapWidth:100 topCapHeight:20];
        backImage.frame = CGRectMake(0, 0, replyWidth - 10, size.height + 40);
        [v addSubview:backImage];
    }
    
    if ([majorName compare:@""] != NSOrderedSame) {
        majorLabel.text = majorName;
        majorLabel.font = nameLabel.font;
        majorLabel.textColor = nameLabel.textColor;
        [v addSubview:gap];
        [v addSubview:majorLabel];
    }
    
    [v addSubview:label];
    [v addSubview:nameLabel];
    [v addSubview:dateLabel];
    
    return [self initWithView:v insets:textInsetsMine1 deep:d];
}

- (id)initWithText:(NSString *)text image:(NSString *)imageUrl deep:(int)d
{
    BOOL imaged = YES;
    if ([imageUrl isEqualToString:@""]) imaged = NO;
    
    int nImgWidth = SCREEN_WIDTH / 7 * 3;
    int nImgHeight = nImgWidth /4 * 5;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 9, nImgWidth, nImgHeight)];
    
    if (imaged)
    {
        imageView.image = [CacheManager GetCacheImageWithURL:imageUrl];
        
        if (!imageView.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:imageUrl];
                     imageView.image = image;
                 }
             }
             ];
        }
        
        if (imageView.image != nil && imageView.image.size.height < nImgHeight && imageView.image.size.width < nImgWidth) {
            imageView.frame = CGRectMake(20, 9, imageView.image.size.width, imageView.image.size.height);
            nImgWidth = imageView.image.size.width;
            nImgHeight = imageView.image.size.height;
        }
        
        UITapGestureRecognizer *singleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:singleGestureRecognizer];
    }
    
    UIFont *font = [UIFont systemFontOfSize:14.f];
    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(imaged? SCREEN_WIDTH - nImgWidth - 45: SCREEN_WIDTH - 45, imaged ? imageView.frame.size.height : 99999) lineBreakMode:NSLineBreakByCharWrapping];
    UILabel *contentLabelByImage = [[UILabel alloc] initWithFrame:CGRectMake(imaged? nImgWidth + 25 :20, imaged ? 10 : 5, size.width, size.height)];
    contentLabelByImage.numberOfLines = 0;
    contentLabelByImage.lineBreakMode = NSLineBreakByCharWrapping;
    contentLabelByImage.text = (text ? text : @"");
    contentLabelByImage.font = font;
    contentLabelByImage.backgroundColor = [UIColor clearColor];
    
    NSString *downText = nil;
    CGSize sizeTmp;
    int nByImage = -1;
    
    for(int i=0; i < text.length; i++) {
        downText = [text substringToIndex:i];
        sizeTmp = [downText sizeWithFont:font constrainedToSize:CGSizeMake(size.width, 99999) lineBreakMode:NSLineBreakByCharWrapping];
        if (sizeTmp.height > size.height) {
            downText = [text substringFromIndex:(i-1)];
            nByImage = (i-1);
            break;
        }
    }
    
    UILabel *contentLabelDownImage = nil;
    int addHeight = 0;
    if (nByImage > -1 && nByImage < text.length) {
        CGSize sizeDown = [(downText ? downText : @"") sizeWithFont:font constrainedToSize:CGSizeMake(SCREEN_WIDTH - 45, 99999) lineBreakMode:NSLineBreakByCharWrapping];
        
        contentLabelDownImage = [[UILabel alloc] initWithFrame:CGRectMake(20, contentLabelByImage.frame.origin.y + MAX(size.height, imageView.frame.size.height), SCREEN_WIDTH - 45, sizeDown.height)];
        contentLabelDownImage.text = [text substringFromIndex:nByImage];
        contentLabelDownImage.numberOfLines = 0;
        contentLabelDownImage.lineBreakMode = NSLineBreakByCharWrapping;
        contentLabelDownImage.font = font;
        contentLabelDownImage.backgroundColor = [UIColor clearColor];
        
        addHeight = contentLabelDownImage.frame.size.height + 10;
        
        contentLabelByImage.text = [text substringToIndex:nByImage];
    }
    
    int vheight = 0;
    if (imaged) {
        if (contentLabelDownImage == nil) {
            vheight = nImgHeight + 10;
        } else {
            vheight = nImgHeight + addHeight;
        }
    } else {
        vheight = size.height + addHeight;
    }
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 10, vheight + 10)];
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 30, vheight + 10)];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius = 10;
    backView.layer.masksToBounds = YES;
    
    [v addSubview:backView];
    [v addSubview:contentLabelByImage];
    if (contentLabelDownImage != nil) {
        [v addSubview:contentLabelDownImage];
    }
    [v addSubview:imageView];
    
    return [self initWithView:v insets:textInsetsMine1 deep:d];
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
    [self.delegate discussDetailImageClicked:_record.imageUrl];
}

- (id)initWithView:(UIView *)view insets:(UIEdgeInsets)insets deep:(int)d
{
    self = [super init];
    if (self)
    {
        _view = view;
    }
    return self;
}
@end
