//
//  Setting5WeekTableViewController.h
//  mmj
//
//  Created by pcbeta on 14-10-2.
//  Copyright (c) 2014年 JinYongHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeekTableViewController;
WeekTableViewController *gWeekTableViewController;

@interface WeekTableViewController : UITableViewController
{    
    NSArray *titles;
}


+ (WeekTableViewController *)sharedInstance;
@end
