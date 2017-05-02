//
//  ggaAppDelegate.h
//  GoalGroup
//
//  Created by KCHN on 1/28/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHTabBarController.h"
#import "HttpManager.h"
#import "ChallengePlayViewController.h"
#import "ResearchViewController.h"
#import "ClubListViewController.h"
#import "DiscussListViewController.h"
#import "FPPopoverController.h"
#import "SocketIO.h"
#import "HttpClient.h"
#import <sqlite3.h>
#import "KxMenu.h"
#import "NotificationManager.h"
#import "RunTimeHttpManager.h"

@interface ggaAppDelegate : UIResponder <UIApplicationDelegate, MHTabBarControllerDelegate, HttpManagerDelegate, UIActionSheetDelegate, INotificationManagerDelegate, RunTimeHttpManagerDelegate>
{
    UINavigationController *ggaNav;
    MHTabBarController *tabBC;
    ChallengePlayViewController *battleVC;
    DiscussListViewController *discussVC;
    ClubListViewController *clublistVC;
    ResearchViewController *researchVC;
    
    NSArray *menuItems;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *ggaNav;
@property (nonatomic, retain) FPPopoverController *popover;
@property (nonatomic, retain) MHTabBarController *tabBC;

@property (strong, nonatomic) SocketIO *socketIO;
@property (strong, nonatomic) HttpClient *httpClientForUpload;

+ (id) sharedInstance;
- (void)loginSuccessed;
- (void)showLoginVC;
- (void)refreshCountView:(int)roomID;
- (void)referLabelRefresh;
- (void)selectedIndex:(int)index;
-(void)checkNotification:(NSDictionary *)options;
@end
