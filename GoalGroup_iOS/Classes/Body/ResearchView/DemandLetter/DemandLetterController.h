//
//  DemandLetterController.h
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DemandLetterItemView.h"
#import "HttpManager.h"
#import "DAOverlayView.h"

@interface DemandLetterController : UITableViewController<DemandLetterItemViewDelegate, HttpManagerDelegate, UIAlertViewDelegate, DAOverlayViewDelegate, UIScrollViewDelegate>
{
    NSMutableArray *letters;
    int currPageNo;
    BOOL loading;
    BOOL moreAvailable;
    
    UIActivityIndicatorView *moreView;
}

@property (nonatomic, strong) DemandLetterItemView *swipedCell;

@end
