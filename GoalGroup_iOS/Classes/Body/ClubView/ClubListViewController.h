//
//  ClubListViewController.h
//  GoalGroup
//
//  Created by KCHN on 1/30/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"
#import "ClubListViewCell.h"

@class ClubListViewController;
ClubListViewController *gClubListViewController;

@interface ClubListViewController : UITableViewController<HttpManagerDelegate, UIScrollViewDelegate, UIScrollViewAccessibilityDelegate, ClubListViewCellDelegate>
{
    NSMutableArray *clubs;
    int currPageNo;
    BOOL loading;
    BOOL moreAvailable;
    
    UIActivityIndicatorView *moreView;
}

+ (id)sharedInstance;
- (void)loadMore;
- (void)refreshTableView;
- (void)refreshUnreadCount;

@end
