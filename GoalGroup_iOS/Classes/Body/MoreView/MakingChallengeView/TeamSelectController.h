//
//  TeamSelectController.h
//  GoalGroup
//
//  Created by MacMini on 3/14/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamSelectController;
@protocol TeamSelectControllerDelegate <NSObject>
@optional
- (void)teamSelected:(int)teamid;
- (void)multiTeamSelected:(NSArray *)teams;
@end

@interface TeamSelectController : UITableViewController
{
    BOOL adminMode;
    BOOL mutilMode;
}

- (id)initAdminMutliSelectModeWithDelegate:(id<TeamSelectControllerDelegate>) delegate;
- (id)initAdminMonoSelModeWithDelegate:(id<TeamSelectControllerDelegate>) delegate;
- (id)initNormalMultiSelectModeWithDelegate:(id<TeamSelectControllerDelegate>) delegate;
- (id)initNormalMonoSelectModeWithDelegate:(id<TeamSelectControllerDelegate>) delegate;

@property(nonatomic, retain) id<TeamSelectControllerDelegate> delegate;
@end
