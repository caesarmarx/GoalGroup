//
//  CitySelectController.h
//  GoalGroup
//
//  Created by MacMini on 3/9/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CitySelectController;
CitySelectController *gCitySelectController;

@protocol CitySelectControllerDelegate <NSObject>

- (void)selectedCityWithIndex:(int)index;

@end

@interface CitySelectController : UITableViewController
{
    NSMutableArray *titles;
}

+ (CitySelectController *)sharedInstance;

@property(nonatomic, weak) id<CitySelectControllerDelegate> delegate;
@property(nonatomic, strong) NSString *beforeSelected;
@end
