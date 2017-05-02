//
//  DiscussListViewController.h
//  GoalGroup
//
//  Created by KCHN on 1/30/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"

@interface DiscussListViewController : UITableViewController<HttpManagerDelegate, UIScrollViewDelegate>
{
    NSMutableArray *arrangeDiscuss;
    NSMutableArray *sectionArray;
    int currPageNo;
    BOOL loading;
    BOOL moreAvailable;
    
    UIActivityIndicatorView *moreView;
}

-(void)loadMore;

@end
