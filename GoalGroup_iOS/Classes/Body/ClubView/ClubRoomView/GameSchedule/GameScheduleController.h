//
//  GameScheduleController.h
//  GoalGroup
//
//  Created by KCHN on 2/13/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"
#import "GameScheduleViewCell.h"
#import "gamescheduleRecord.h"
#import "DAOverlayView.h"

@class GameScheduleController;
GameScheduleController *gGameScheduleController;

@protocol GameScheduleControllerDelegate <NSObject>

@optional
- (void)gameScheduleItemClick:(GameScheduleRecord *)record;

@end

@interface GameScheduleController : UITableViewController<HttpManagerDelegate, GameScheduleViewCellDelegate, DAOverlayViewDelegate, UIScrollViewDelegate>
{
    NSMutableArray *schedules;
    BOOL loading;
    BOOL moreAvailable;
    int currPageNo;
    UIActivityIndicatorView *moreView;
    
    int nClubID;
}

+ (GameScheduleController *)sharedInstance;
- (void)loadmore;
- (void)selectMode:(BOOL) mode withClubID:(int)c_id;

@property(nonatomic) BOOL selectModeBeforeJoin;
@property(nonatomic, retain) id<GameScheduleControllerDelegate> delegate;
@property(nonatomic, strong) GameScheduleViewCell *swipedCell;

@end
