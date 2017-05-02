//
//  SwipeMenuViewCell.h
//  GoalGroup
//
//  Created by MacMini on 3/21/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwipeMenuViewCell : UITableViewCell
{
    BOOL swiped;
}
- (void)openMenuView;
- (void)closeMenuView;

@end
