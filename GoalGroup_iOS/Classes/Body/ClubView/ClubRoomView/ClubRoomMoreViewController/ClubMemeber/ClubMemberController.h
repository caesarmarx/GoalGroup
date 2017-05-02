//
//  ClubMemberController.h
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemberItemView.h"
#import "HttpManager.h"
#import "OBDragDrop.h"
#import "ClubMemberListController.h"

@class ClubMemberController;
ClubMemberController *gClubMemberController;

@interface ClubMemberController : UIViewController<MemberItemViewDelegate, HttpManagerDelegate, ClubMemberListControllerDelegate, OBOvumSource, OBDropZone, UIPopoverControllerDelegate, UIAlertViewDelegate>
{
    NSMutableArray  *members;
    NSMutableArray  *deletedMembers;
    UIView          *trashView;
    
    MemberItemView  *corchView;
    MemberItemView  *captainView;
    
    UIScrollView    *forwardView;
    NSMutableArray  *forwardViewContents;
    UIScrollView    *middleView;
    NSMutableArray  *middleViewContents;
    UIScrollView    *defenceView;
    NSMutableArray  *defenceViewContents;
    UIScrollView    *keeperView;
    NSMutableArray  *keeperViewContents;
    
    OBDragDropManager   *dragDropManager;
    UIPopoverController *sourcesPopoverController;
    
    NSMutableDictionary *dropedMembers;
    
    int nMineClubID;
}

+ (ClubMemberController *)sharedInstance;
- (id)initWithClubID:(int)clubid;

@end
