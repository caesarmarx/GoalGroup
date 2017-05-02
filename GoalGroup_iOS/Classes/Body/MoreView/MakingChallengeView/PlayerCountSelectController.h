//
//  PlayerCountSelectController.h
//  GoalGroup
//
//  Created by MacMini on 3/14/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerCountSelectController;
@protocol PlayerCountSelectControllerDelegate <NSObject>

@optional
- (void)playerCountSelected:(int)count;
@end

@interface PlayerCountSelectController : UITableViewController
- (id)initWithDelegate:(id<PlayerCountSelectControllerDelegate>)delegate;
@property(nonatomic, retain) id<PlayerCountSelectControllerDelegate> delegate;
@end
