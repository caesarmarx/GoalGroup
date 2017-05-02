//
//  NSBubbleData.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "NSBubbleData.h"
#import <QuartzCore/QuartzCore.h>
#import "CacheManager.h"
#import "UIImage+Web.h"
#import "UIImage+Mask.h"
#import "FileManager.h"
#import "NSString+MD5.h"
#import "MyPhoto.h"
#import "MyPhotoSource.h"
#import "Common.h"
#import "EGOPhotoViewController.h"

@implementation NSBubbleData
{
    NSString *playerNick;
    int gameType;
}

#pragma mark - Properties

@synthesize date = _date;
@synthesize type = _type;
@synthesize view = _view;
@synthesize insets = _insets;
@synthesize avatar = _avatar;
@synthesize avatarUrl = _avatarUrl;
@synthesize nSenderID = _nSenderID;
@synthesize avatarName = _avatarName;
@synthesize sendMsg = _sendMsg;
@synthesize audioUploading = _audioUploading;
@synthesize audioDownloading = _audioDownloading;
@synthesize priKeyIndex = _priKeyIndex;

#pragma mark - Lifecycle

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_date release];
	_date = nil;
    [_view release];
    _view = nil;
    
    self.avatar = nil;
    self.avatarUrl = nil;

    [super dealloc];
}
#endif

#pragma mark - Text bubble
const UIEdgeInsets textInsetsMine = {5, 10, 11, 17};

const UIEdgeInsets textInsetsSomeone = {5, 15, 11, 10};

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithText:text date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithText:text date:date type:type];
#endif    
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type
{
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(200, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = (text ? text : @"");
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.userInteractionEnabled = YES;
    
    gameType = -1;
    
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClickedForDetail:)];
    [label addGestureRecognizer:singleRecognizer];
    
    NSString *searchStr = [NSString stringWithFormat:@"%@%@", LANGUAGE(@"myrecommend"), LANGUAGE(@"member")];
    if ([text rangeOfString:searchStr].location != NSNotFound)
    {
        NSArray *tmp = [text componentsSeparatedByString:@"\r\n"];
        playerNick = [tmp objectAtIndex:1];
        gameType = 100;
    }
    
    searchStr = [NSString stringWithFormat:@"%@%@", LANGUAGE(@"myrecommend"), LANGUAGE(@"challenge")];
    if ([text rangeOfString:searchStr].location != NSNotFound)
        gameType = GAME_TYPE_CHALLENGE;
    
    searchStr = [NSString stringWithFormat:@"%@%@", LANGUAGE(@"myrecommend"), LANGUAGE(@"notice")];
    if ([text rangeOfString:searchStr].location != NSNotFound)
        gameType = GAME_TYPE_NOTIFY;
    
    
#if !__has_feature(objc_arc)
    [label autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:label date:date type:type insets:insets cellType:BubbleTypeText];
}


#pragma mark - Image bubble

const UIEdgeInsets imageInsetsMine = {11, 13, 16, 22};
const UIEdgeInsets imageInsetsSomeone = {11, 18, 16, 14};



#pragma image
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImage:image date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithImage:image date:date type:type];
#endif
}

- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type
{
    CGSize size = image.size;
    if (size.width > 200)
    {
        size.height /= (size.width / 200);
        size.width = 200;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = image;
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    
    
#if !__has_feature(objc_arc)
    [imageView autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:imageView date:date type:type insets:insets cellType:BubbleTypeImage];
}

+ (id)dataWithImageUrl:(NSString *)imageUrl date:(NSDate *)date type:(NSBubbleType)type viewController:(UIViewController *)vc
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImageUrl:imageUrl date:date type:type viewController:vc] autorelease];
#else
    return [[NSBubbleData alloc] initWithImageUrl:imageUrl date:date type:type viewController:vc];
#endif
}

- (id)initWithImageUrl:(NSString *)imageUrl date:(NSDate *)date type:(NSBubbleType)type viewController:(UIViewController *)vc
{
    vcForImage = vc;
    CGSize size = CGSizeMake(50, 50);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
    [imageView addGestureRecognizer:singleTapGesture];
    
    if (imageUrl && ![imageUrl isEqualToString:@""])
    {
        imageForImage = [CacheManager GetCacheImageWithURL:imageUrl];
        imageView.image = imageForImage; //imageView.image = [imageForImage imageByScalingAndCroppingForSize:size];
        if (!imageView.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     imageForImage = image;
                     [CacheManager CacheWithImage:image filename:imageUrl];
                     imageView.image= image;
                 }
                 return ;
             }
             ];
        }
        
    }

    
#if !__has_feature(objc_arc)
    [imageView autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:imageView date:date type:type insets:insets cellType:BubbleTypeImage];
}



#pragma audio
+ (id)dataWithAudioUrl:(NSString *)audioUrl date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithAudioUrl:audioUrl date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithAudioUrl:audioUrl date:date type:type];
#endif
}

- (id)initWithAudioUrl:(NSString *)audioUrl date:(NSDate *)date type:(NSBubbleType)type
{
    voicemailUrl = audioUrl;
    CGSize size = CGSizeMake(30, 30);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = [UIImage imageNamed:@"voicemail-mark"];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voicemailClick:)];
    [imageView addGestureRecognizer:singleTapGesture];
    
#if !__has_feature(objc_arc)
    [imageView autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:imageView date:date type:type insets:insets cellType:BubbleTypeVoice];
}



#pragma mark - Custom view bubble

+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets cellType:(NSBubbleType)cellType
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithView:view date:date type:type insets:insets] autorelease];
#else
    return [[NSBubbleData alloc] initWithView:view date:date type:type insets:insets cellType:cellType];
#endif    
}

- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets cellType:(NSBubbleType)cellType
{
    self = [super init];
    if (self)
    {
        _priKeyIndex = 0;
#if !__has_feature(objc_arc)
        _view = [view retain];
        _date = [date retain];
#else
        _view = view;
        _date = date;
#endif
        _type = type;
        _insets = insets;
        _cellType = cellType;
    }
    return self;
}



#pragma audioPlay
- (void)voicemailClick:(UITapGestureRecognizer *)recognizer
{
    if (isPlaying)
    {
        isPlaying = NO;
        [[PlayerManager sharedManager] stopPlaying];
    }
    else if (!self.audioDownloading && !self.audioUploading)
    {
        NSString *voicemailFilePath = [FileManager GetVoiceFilePath:[voicemailUrl MD5]];
        NSLog(@"voicemail url: %@", voicemailUrl);
        NSLog(@"voicemail will play: %@", voicemailFilePath);
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:voicemailFilePath])
        {
            [PlayerManager sharedManager].delegate = nil;
            [[PlayerManager sharedManager] playAudioWithFileName:voicemailFilePath delegate:self];
        }
        else
            [AlertManager AlertWithMessage:LANGUAGE(@"failed")];
    }
}

- (void)playingStoped
{
    isPlaying = NO;
}



#pragma imageShow
- (void)imageClick:(UITapGestureRecognizer *)recognizer
{
    MyPhoto *mp = [[MyPhoto alloc] initWithImage:imageForImage];
    MyPhotoSource *mps = [[MyPhotoSource alloc] initWithPhotos:[NSArray arrayWithObject:mp]];
    EGOPhotoViewController *epc = [[EGOPhotoViewController alloc] initWithPhotoSource:mps];
    [vcForImage.navigationController pushViewController:epc animated:YES];
}

- (void)labelClickedForDetail:(UITapGestureRecognizer *)recognizer
{
    switch (gameType) {
        case GAME_TYPE_CHALLENGE:
        case GAME_TYPE_NOTIFY:
            [self.delegate gameListVCWithGameType:gameType];
            break;
        case 100:
            [self.delegate playerDetailVCWithPlayerNick:playerNick];
        default:
            break;
    }
}

- (void)setVoicemailUrl:(NSString *)url
{
    voicemailUrl = url;
}
@end
