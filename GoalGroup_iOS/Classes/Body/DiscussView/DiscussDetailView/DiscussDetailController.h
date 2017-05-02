//
//  DiscussDetailController.h
//  GoalGroup
//
//  Created by KCHN on 2/13/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscussDetailHeaderView.h"
#import "DiscussDetailItemData.h"
#import "HttpManager.h"
#import "DAOverlayView.h"

@interface DiscussDetailController : UIViewController<UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate, HttpManagerDelegate, DiscussDetailItemDataDelegate, DAOverlayViewDelegate>
{
    int nMainID;
    NSMutableArray *articles;
    int currPageNo;
    BOOL loading;
    BOOL moreAvailable;
    
    UIActivityIndicatorView *moreView;
    UIImage *imageForImage;
    DAOverlayView *overlayView;
}

@property(nonatomic, strong) UIView *inputView;
@property(nonatomic, retain) UITextField *inputField;
@property(nonatomic, strong) UIButton *sendButton;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) DiscussDetailHeaderView *headerView;


- (id)initWithMainID:(int)mainID;
- (void)loadMore;
@end
