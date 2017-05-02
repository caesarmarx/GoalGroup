//
//  ChallengePlayViewController.h
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"
#import "ChallengePlayViewCell.h"
#import "ClubSelectController.h"
#import "FPPopoverController.h"
#import "HttpManager.h"
#import "GCDiscreetNotificationView.h"
#import "TeamSelectController.h"
#import "DAOverlayView.h"

@interface ChallengePlayViewController : UITableViewController<ChallengePlayViewCellDelegate, HttpManagerDelegate, ClubSelectControllerDelegate, FPPopoverControllerDelegate, TeamSelectControllerDelegate, DAOverlayViewDelegate, UIScrollViewDelegate>
{
    NSMutableArray *challengeplays;
    int currPageNo;
    BOOL loading;
    BOOL moreAvailable;
    
    UIActivityIndicatorView *moreView;
    
    //YES means "agree", NO means "discuss"
    BOOL agreeMode;
    
    GCDiscreetNotificationView *dnv;
}

@property (nonatomic, strong) ChallengePlayViewCell *swipedCell;
@property (nonatomic, retain) FPPopoverController *popover;

- (void)loadMore;

@end
