//
//  RefereeSelectController.h
//  GoalGroup
//
//  Created by MacMini on 3/14/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RefereeSelectController;
@protocol RefereeSelectControllerDelegate <NSObject>

@optional
- (void)refereeOptionSelected:(int)mode;
@end

@interface RefereeSelectController : UITableViewController
- (id)initWithDelegate:(id<RefereeSelectControllerDelegate>) delegate;
@property(nonatomic, retain) id<RefereeSelectControllerDelegate> delegate;
@end
