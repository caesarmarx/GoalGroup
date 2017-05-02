//
//  ClubSettingsController.h
//  GoalGroup
//
//  Created by KCHN on 2/12/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTFadeSwitch.h"
#import "HttpManager.h"

@class ClubSettingsController;
ClubSettingsController *gClubSettingsController;

@interface ClubSettingsController : UITableViewController<HttpManagerDelegate, UIAlertViewDelegate>
{
    int nRoomID;
    int nClubID;
    NSArray *titles10;
    NSArray *titles9;
    NSInteger SWITCHTAG;
    TTFadeSwitch *switch1, *switch2, *switch3, *switch4, *switch5, *switch6, *switch7, *switch8;
    NSArray *switches;
}
+ (ClubSettingsController *)sharedInstance;
- (id)initWithRoomID:(int)roomID clubID:(int)clubID;

@end
