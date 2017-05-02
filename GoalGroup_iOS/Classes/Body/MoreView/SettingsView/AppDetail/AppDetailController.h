//
//  AppDetailController.h
//  GoalGroup
//
//  Created by MacMini on 3/9/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"

@class AppDetailController;
AppDetailController *gAppDetaiController;

@interface AppDetailController : UIViewController<HttpManagerDelegate>

+ (AppDetailController *)sharedInstance;

@end
