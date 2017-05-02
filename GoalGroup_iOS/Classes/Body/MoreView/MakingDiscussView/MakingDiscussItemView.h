//
//  MakingDiscussItemView.h
//  GoalGroup
//
//  Created by MacMini on 3/18/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MakingDiscussItemViewDelegate <NSObject>
@optional
- (void)nonEmptyItemView:(int)itemID;
- (void)emptyItemView:(int)itemID;
- (void)beginEditingItemView:(int)itemID;
- (void)takePhotoClickItemView:(int)itemID;
@end

@interface MakingDiscussItemView : UIView<UITextViewDelegate>
{
    int item_id;
    UIImageView *discussImage;
    UITextView *discussText;
}

- (id)initWithFrame:(CGRect)rect WithItemID:(int)item withDelegate:(id<MakingDiscussItemViewDelegate>) delegate;
- (NSString *)discussContent;
- (UIImage *)discussImage;
- (NSString *)discussImageUrl;
- (void)setImage:(UIImage *)image;
@property(nonatomic, retain) id<MakingDiscussItemViewDelegate> delegate;
@property(nonatomic, strong) NSString *serverName;

@end
