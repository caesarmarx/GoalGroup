//
//  PlayerMarketController.h
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerMarkectItemView.h"
#import "HttpManager.h"
#import "ClubSelectController.h"
#import "FPPopoverController.h"
#import "GameScheduleController.h"
#import "TeamSelectController.h"
#import "PlayerSearchConditionController.h"
#import "DAOverlayView.h"

@interface PlayerMarketController : UITableViewController<PlayerMarketItemViewDelegate, HttpManagerDelegate, FPPopoverControllerDelegate, ClubSelectControllerDelegate, GameScheduleControllerDelegate, TeamSelectControllerDelegate, DAOverlayViewDelegate, PlayerSearchConditionControllerDelegate, UIScrollViewDelegate>
{
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray  *searchResult;
@property NSInteger currPageNo;
@property BOOL loading;
@property BOOL moreAvailable;
@property NSInteger selectedIndex;
@property (nonatomic, strong)  UIActivityIndicatorView *moreView;

@property (nonatomic, retain) FPPopoverController *popover;
@property (nonatomic, strong) PlayerMarkectItemView *swipedCell;

- (void)loadMore;

@end
