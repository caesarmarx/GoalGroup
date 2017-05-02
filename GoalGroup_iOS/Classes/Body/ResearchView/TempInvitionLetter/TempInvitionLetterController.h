//
//  TempInvitionLetterController.h
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TempInvitionLetterItemView.h"
#import "HttpManager.h"
#import "DAOverlayView.h"

@interface TempInvitionLetterController : UITableViewController<TempInvitioLetterItemViewDelegate, HttpManagerDelegate, DAOverlayViewDelegate, UIScrollViewDelegate>
{
    NSMutableArray *tmpletters;
    int currPageNo;
    BOOL loading;
    BOOL moreAvailable;
    
    UIActivityIndicatorView *moreView;
}

@property (nonatomic, strong) TempInvitionLetterItemView *swipedCell;

@end
