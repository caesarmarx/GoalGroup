//
//  ClubMarksDetailController.h
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"

@class ClubMarksDetailController;
ClubMarksDetailController *gClubMarksDetailController;


@interface ClubMarksDetailController : UIViewController<HttpManagerDelegate>
{
    int nClubID;
}

- (id)initWithClubID:(int)clubid;

@end
