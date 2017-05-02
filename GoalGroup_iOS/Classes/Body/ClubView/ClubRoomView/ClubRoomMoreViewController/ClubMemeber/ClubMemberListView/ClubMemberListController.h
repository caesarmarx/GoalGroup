//
//  ClubMemberListController.h
//  GoalGroup
//
//  Created by KCHN on 3/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.

#import <UIKit/UIKit.h>
#import "ClubMemberListViewCell.h"
#import "HttpManager.h"

@class ClubMemberListController;
ClubMemberListController *gClubMemberListController;

@protocol ClubMemberListControllerDelegate
- (void)didSelectedWithRecord:(PlayerListRecord *)record chooseCorch:(BOOL)chooseCorch;
@end

@interface ClubMemberListController : UITableViewController<ClubMemberListViewCellDelegate, HttpManagerDelegate>
{
    NSMutableArray *players;
    int currPageNo;
    BOOL loading;
    BOOL moreAvailable;
    
    UIActivityIndicatorView *moreView;
    
    BOOL corchSelectMode;
}

- (id)initWithMembers:(NSMutableArray *)members delegate:(id)delegate chooseCorch:(BOOL)chooseCorch;
- (id)initWithHttpMode:(int)club game:(int)game;

@property(nonatomic, retain) id<ClubMemberListControllerDelegate> delegate;
@property(nonatomic) BOOL chooseCorch;

@end
