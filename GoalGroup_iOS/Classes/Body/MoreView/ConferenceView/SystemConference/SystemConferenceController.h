//
//  SystemConferenceController.h
//  GoalGroup
//
//  Created by MacMini on 4/20/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"

@interface SystemConferenceController : UITableViewController<HttpManagerDelegate, UIScrollViewDelegate>
{
    NSMutableArray *conferences;
    int currPageNo;
    BOOL moreAvailable;
    BOOL loading;
    
    UIActivityIndicatorView *moreView;
}
@end
