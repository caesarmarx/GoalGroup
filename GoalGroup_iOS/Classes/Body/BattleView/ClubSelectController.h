//
//  ClubSelectController.h
//  GoalGroup
//
//  Created by MacMini on 3/11/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClubSelectController;
@protocol ClubSelectControllerDelegate <NSObject>

@optional
- (void)clubSelectClick:(int)club;

@end



ClubSelectController *gClubSelectController;
@interface ClubSelectController : UITableViewController

+ (ClubSelectController *)sharedInstance;

@property(nonatomic, weak) id<ClubSelectControllerDelegate> delegate;

@end
