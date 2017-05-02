//
//  UserRegisterController.h
//  GoalGroup
//
//  Created by MacMini on 3/11/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"

@class UserRegisterController;
UserRegisterController *gUserRegisterController;

@interface UserRegisterController : UIViewController<UITextFieldDelegate, HttpManagerDelegate>
{
}
+ (UserRegisterController *)sharedInstance;


@end
