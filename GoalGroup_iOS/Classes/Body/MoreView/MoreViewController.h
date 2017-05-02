//
//  MoreViewController.h
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ggaAppDelegate.h"

@class MHTabBarController;

@interface MoreViewController : UITableViewController
{
    NSArray *title;
}
@property(nonatomic, assign) MHTabBarController *delegate;
@end
