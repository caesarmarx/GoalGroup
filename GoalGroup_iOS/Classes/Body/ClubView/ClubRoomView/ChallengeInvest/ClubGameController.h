//
//  ClubGameController.h
//  GoalGroup
//
//  Created by KCHN on 2/26/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClubGameController.h"
#import "HttpManager.h"
#import "ClubGameViewCell.h"
#import "DAOverlayView.h"

@interface ClubGameController : UITableViewController<HttpManagerDelegate, ClubGameViewCellDelegate, DAOverlayViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate>
{
    NSMutableArray *games;
    int currPageNo;
    BOOL loading;
    BOOL moreAvailable;
    BOOL showTeam;
    
    UIActivityIndicatorView *moreView;
    int nClubID;
}

@property (nonatomic, strong) ClubGameViewCell *swipedCell;

- (void)loadMore;
- (id)initChallengeStyle:(int)c_id;
- (id)initNoticeStyle:(int)c_id;

@end
