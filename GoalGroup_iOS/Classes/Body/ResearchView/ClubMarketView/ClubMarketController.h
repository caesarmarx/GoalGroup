//
//  ClubMarketController.h
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "ClubMarketItemView.h"
#import "HttpManager.h"
#import "DAOverlayView.h"
#import "ClubSearchConditionController.h"


@interface ClubMarketController : UITableViewController<ClubMarketItemViewDelegate, HttpManagerDelegate, DAOverlayViewDelegate, ClubSearchConditionControllerDeleagte, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray  *searchResult;
@property (nonatomic, strong)  UIActivityIndicatorView *moreView;
@property (nonatomic, strong) ClubMarketItemView *swipedCell;
@property NSInteger currPageNo;
@property BOOL loading;
@property BOOL moreAvailable;
@property NSInteger selectedIndex;

- (void)loadMore;

@end
