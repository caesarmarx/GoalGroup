//
//  WeekSelectController.h
//  GoalGroup
//
//  Created by KCHN on 2/10/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeekSelectController;
WeekSelectController *gWeekSelectController;

@interface WeekSelectController : UITableViewController
{
    NSArray *titles;
}

+ (WeekSelectController *)sharedInstance;
@end
