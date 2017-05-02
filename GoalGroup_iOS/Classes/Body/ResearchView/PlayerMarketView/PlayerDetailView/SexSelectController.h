//
//  SexSelectController.h
//  GoalGroup
//
//  Created by MacMini on 3/17/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SexSelectControllerDelegate <NSObject>
@optional
- (void)sexSelected:(int)index;
@end

@interface SexSelectController : UITableViewController

@property(nonatomic, retain) id<SexSelectControllerDelegate> delegate;

@end
