//
//  JoiningBookController.h
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JoiningBookViewCell.h"
#import "HttpManager.h"
#import "DAOverlayView.h"


@interface JoiningBookController : UITableViewController<JoiningBookViewCellDelegate, HttpManagerDelegate, DAOverlayViewDelegate, UIScrollViewDelegate>
{
    NSMutableArray *joinings;
    int currPageNo;
    BOOL loading;
    BOOL moreAvailable;
    
    UIActivityIndicatorView *moreView;
    int nClubID;
}

@property (nonatomic, strong) JoiningBookViewCell *swipedCell;
- (void)loadMore;
- (id)initWithClubID:(int)club;
@end
