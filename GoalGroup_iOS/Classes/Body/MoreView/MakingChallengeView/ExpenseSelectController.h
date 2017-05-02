//
//  ExpenseSelectController.h
//  GoalGroup
//
//  Created by MacMini on 3/14/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExpenseSelectController;
@protocol ExpenseSelectControllerDelegate <NSObject>

@optional
- (void)expenseSelected:(int)mode;
@end

@interface ExpenseSelectController : UITableViewController
- (id)initWithDelegate:(id<ExpenseSelectControllerDelegate>) delegate;
@property(nonatomic, retain) id<ExpenseSelectControllerDelegate> delegate;
@end
