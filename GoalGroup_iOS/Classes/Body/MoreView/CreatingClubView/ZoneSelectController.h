//
//  ZoneSelectController.h
//  GoalGroup
//
//  Created by MacMini on 3/10/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoneSelectController : UITableViewController
{
    NSMutableArray *titles;
}

- (id)initWithCityIndex:(int)index;
- (id)initWithAllArea;
@end
