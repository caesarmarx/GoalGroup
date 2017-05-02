//
//  SettingsViewController.h
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSwitch.h"
#import "TTFadeSwitch.h"
#import "HttpManager.h"

@interface SettingsViewController : UITableViewController<HttpManagerDelegate, UIAlertViewDelegate>
{
    TTFadeSwitch *inviteClubAlarmSwitch;
    TTFadeSwitch *adminPageAlarmSiwtch;
    
    NSArray *switchs;
    
    NSArray *labels1;
    NSArray *labels2;
    NSArray *labels3;
    NSArray *labels4;
    NSArray *labels5;
    NSArray *labels6;
}
@end
