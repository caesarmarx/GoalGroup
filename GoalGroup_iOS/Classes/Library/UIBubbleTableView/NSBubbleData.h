//
//  NSBubbleData.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <Foundation/Foundation.h>
#import "PlayerManager.h"

@protocol NSBubbleDataDelegate <NSObject>
@optional
- (void)playerDetailVCWithPlayerNick:(NSString *)nickName;
- (void)gameListVCWithGameType:(int)type;
@end

typedef enum _NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1,
    BubbleTypeText = 2,
    BubbleTypeImage = 3,
    BubbleTypeVoice = 4,
} NSBubbleType;

@interface NSBubbleData : NSObject <PlayingDelegate>
{
    BOOL isPlaying;
    NSString *voicemailUrl;
    UIViewController *vcForImage;
    UIImage *imageForImage;
}

@property (readonly, nonatomic, strong) NSDate *date;
@property (readonly, nonatomic) NSBubbleType type;
@property (readonly, nonatomic, strong) UIView *view;
@property (readonly, nonatomic) UIEdgeInsets insets;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *avatarName;
@property int nSenderID;
@property int cellType;
@property BOOL sendMsg;
@property BOOL audioUploading;
@property BOOL audioDownloading;
@property int priKeyIndex;

@property (nonatomic, strong) id<NSBubbleDataDelegate> delegate;

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithImageUrl:(NSString *)imageUrl date:(NSDate *)date type:(NSBubbleType)type viewController:(UIViewController *)vc;;
+ (id)dataWithImageUrl:(NSString *)imageUrl date:(NSDate *)date type:(NSBubbleType)type viewController:(UIViewController *)vc;
- (id)initWithAudioUrl:(NSString *)audioUrl date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithAudioUrl:(NSString *)audioUrl date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets cellType:(NSBubbleType)cellType;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets cellType:(NSBubbleType)cellType;
- (void)setVoicemailUrl:(NSString *)url;

@end
