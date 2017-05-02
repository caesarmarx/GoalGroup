//
//  StadiumSelectController.h
//  GoalGroup
//
//  Created by MacMini on 3/9/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StadiumSelectController;
StadiumSelectController *gStadiumSelectController;

@protocol StadiumSelectControllerDelegate <NSObject>

- (void)selectedStadiumWithIndex:(int)index;

@end

@interface StadiumSelectController : UITableViewController
{
    NSMutableArray *titles;
}
- (id)initWithDelegate:(id<StadiumSelectControllerDelegate>) delegate;
+ (StadiumSelectController *)sharedInstance;

@property(nonatomic, weak) id<StadiumSelectControllerDelegate> delegate;

@end
