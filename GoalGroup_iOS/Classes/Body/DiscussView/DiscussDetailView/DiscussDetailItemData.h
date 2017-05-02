//
//  DiscussDetailItemData.h
//  GoalGroup
//
//  Created by MacMini on 3/18/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiscussDetailListRecord.h"

@protocol DiscussDetailItemDataDelegate <NSObject>
@optional
- (void)discussDetailImageClicked:(NSString *)imageUrl;
@end

typedef enum _DiscussDetailItemType
{
    DiscussDetailItemMain = 0,
    DiscussDetailItemReply = 1
} DiscussDetailItemType;

@interface DiscussDetailItemData : NSObject

@property (readonly, nonatomic) DiscussDetailItemType type;
@property (readonly, nonatomic, strong) UIView *view;
@property (nonatomic, strong) DiscussDetailListRecord *record;
@property (nonatomic, retain) id<DiscussDetailItemDataDelegate> delegate;

- (id)initWithRecord:(DiscussDetailListRecord *)record after:(NSString *)who;
- (id)initWithText:(NSString *)text name:(NSString *)name majorName:(NSString *)majorName deep:(int)d;
- (id)initWithText:(NSString *)text image:(NSString *)imageUrl deep:(int)d;

@end
