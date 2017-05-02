//
//  MemberItemView.h
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerListRecord.h"

@class MemberItemView;
@protocol MemberItemViewDelegate <NSObject>
@optional

- (void)memberItemClicked:(MemberItemView *)item withUserType:(int)type withPlayerId:(int)playerId;

@end


@interface MemberItemView : UIView
{
    UIImage *memberThumbImage;
    NSString *nameStr;
    BOOL healthState;
    CGPoint curCenter;
    int nUserType;
    int nPlayerId;
    int nTempState;
}

@property(nonatomic, strong) id<MemberItemViewDelegate> delegate;
@property(nonatomic, strong) PlayerListRecord* record;
@property(nonatomic) BOOL healthEffect;

- (void)drawWithRecord:(PlayerListRecord *)record;
- (void)drawCorchWithRecord:(PlayerListRecord *)record;
- (void)drawCaptainWithRecord:(PlayerListRecord *)record;
@end
