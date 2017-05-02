//
//  PlayerDetailController.h
//  GoalGroup
//
//  Created by KCHN on 2/26/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"
#import "SexSelectController.h"
#import "CitySelectController.h"
#import "ZoneSelectController.h"
#import "WeekSelectController.h"
#import "TeamSelectController.h"

@class PlayerDetailController;
PlayerDetailController *gPlayerDetailController;

@interface PlayerDetailController : UIViewController<UITextFieldDelegate, HttpManagerDelegate, CitySelectControllerDelegate, SexSelectControllerDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, TeamSelectControllerDelegate>

- (id)initWithPlayerID:(int)pid showInviteButton:(BOOL)show;

@end
