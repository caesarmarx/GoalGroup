//
//  PersonalMarksDetailController.h
//  GoalGroup
//
//  Created by KCHN on 2/21/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"

@class PersonalMarksDetailController;
PersonalMarksDetailController *gPersonalMarksDetailController;

@interface PersonalMarksDetailController : UIViewController<HttpManagerDelegate>
{
    int nClubID;
}
+ (PersonalMarksDetailController *)sharedInstance;
- (id)initWithClub:(int)club;
@end
