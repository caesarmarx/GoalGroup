//
//  ggaAppDelegate.m
//  GoalGroup
//
//  Created by KCHN on 1/28/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ggaAppDelegate.h"
#import "Common.h"
#import <stdarg.h>
#import "LoginViewController.h"
#import "ConferenceController.h"
#import "Constants.h"
#import "chat.h"
#import "Sqlite3Manager.h"
#import "DateManager.h"
#import "OBDragDrop.h"
#import "MakingChallengeController.h"
#import "CreatingClubController.h"
#import "SettingsViewController.h"
#import "DiscussRoomManager.h"
#import "ClubRoomViewController.h"
#import "ChatMessage.h"
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import "WeiboApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <CoreLocation/CoreLocation.h>
#import <QZoneConnection/ISSQZoneApp.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import "APService.h"
#import "ProcessRemoteNotification.h"

@implementation ggaAppDelegate
{
    UILabel *referLabel;
    int sec;
}
@synthesize ggaNav;
@synthesize tabBC;
@synthesize socketIO, httpClientForUpload;

static id sharedInstance = nil;

+ (id) sharedInstance {
    return sharedInstance;
}
- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}
- (void)initializePlat
{
    /**
     连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
     http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectSinaWeiboWithAppKey:@"568898243"
                               appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                             redirectUri:@"http://www.sharesdk.cn"];
    /**
     连接腾讯微博开放平台应用以使用相关功能，此应用需要引用TencentWeiboConnection.framework
     http://dev.t.qq.com上注册腾讯微博开放平台应用，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入libWeiboSDK.a，并引入WBApi.h，将WBApi类型传入接口
     **/
    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
                                  appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                redirectUri:@"http://www.sharesdk.cn"
                                   wbApiCls:[WeiboApi class]];
    
    /**
     连接QQ空间应用以使用相关功能，此应用需要引用QZoneConnection.framework
     http://connect.qq.com/intro/login/上申请加入QQ登录，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入TencentOpenAPI.framework,并引入QQApiInterface.h和TencentOAuth.h，将QQApiInterface和TencentOAuth的类型传入接口
     **/
    [ShareSDK connectQZoneWithAppKey:@"100371282"
                           appSecret:@"aed9b0303e3ed1e27bae87c33761161d"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    [ShareSDK connectWeChatWithAppId:@"wx4868b35061f87885"
                           appSecret:@"64020361b8ec4c99936c0e3999a9f249"
                           wechatCls:[WXApi class]];
    
    /**
     连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
     http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
     **/
    //旧版中申请的AppId（如：QQxxxxxx类型），可以通过下面方法进行初始化
    //    [ShareSDK connectQQWithAppId:@"QQ075BCD15" qqApiCls:[QQApi class]];
    
    [ShareSDK connectQQWithQZoneAppKey:@"100371282"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
}

/**
 * @brief  托管模式下的初始化平台
 */
- (void)initializePlatForTrusteeship
{
    
    //导入QQ互联和QQ好友分享需要的外部库类型，如果不需要QQ空间SSO和QQ好友分享可以不调用此方法
    [ShareSDK importQQClass:[QQApiInterface class] tencentOAuthCls:[TencentOAuth class]];
    
    //导入腾讯微博需要的外部库类型，如果不需要腾讯微博SSO可以不调用此方法
    [ShareSDK importTencentWeiboClass:[WeiboApi class]];
    
    //导入微信需要的外部库类型，如果不需要微信分享可以不调用此方法
    [ShareSDK importWeChatClass:[WXApi class]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //리모트알림 체크
    if (![LoginManager checkIsAlreadyLogin])
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if ([MyDeviceToken compare:@""] == NSOrderedSame) { //Added By Boss.2015/05/20
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    
    //Added by KCHN 20150722
    savedNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    /*
    //앱이 리모트알림에 의하여 기동될때.
    [self checkNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    */
     
    sharedInstance = self;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [ShareSDK registerApp:@"iosv1101"];
    [self initializePlat];
    
    /*for compiling in PY*/
    
    // Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    // Required
    [APService setupWithOption:launchOptions];
     
    [self configureUI];
    [self configureEmoticon];
    [Language sharedInstance];
    [Chat sharedInstance];
    [Sqlite3Manager sharedInstance];

    [[NetworkManager sharedInstance] checkNetworkStatus:nil];
    httpClientForUpload = [[HttpClient alloc] init];
    
    OBDragDropManager *manager = [OBDragDropManager sharedManager];
    [manager prepareOverlayWindowUsingMainWindow:self.window];
    
    userRegisteredSuccessfully = NO;
    [self showLoginVC];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
//    [APService registerDeviceToken:deviceToken];
 //Added By Boss.2015/05/20
    MyDeviceToken = @"";
    
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"My token is: %@", newToken);
    NSLog(@"My token is - New: %@", deviceToken);
    
    MyDeviceToken = newToken;
    NSUserDefaults *phone = [NSUserDefaults standardUserDefaults];
    [phone setObject:MyDeviceToken forKey:@"DEVICE_TOKEN"];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
    NSLog(@"DidRegisteruserNotificatinSettings");
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"DidFailRegisteruserNotificatinSettings");
}
// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
    [self checkNotification:userInfo];
}
#endif

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required //TODO DELETE
    //[APService handleRemoteNotification:userInfo];
    
    if (application.applicationState == UIApplicationStateActive)
    {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
    }//    return;
    //if (application.applicationState == UIApplicationStateInactive)
    {
        [self checkNotification:userInfo];
    }
    /**
    if (uidForRemoteNotification > 0)
    {
        //앱이 주화면에 있을 때
        if ([ggaNav.topViewController isKindOfClass:[MHTabBarController class]])
        {
            return;
        }
        
        //앱이 다른 화면에 있을 때
        while (![ggaNav.topViewController isKindOfClass:[MHTabBarController class]]) {
            [ggaNav popViewControllerAnimated:NO];
        }
    }
     **/
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    //[APService handleRemoteNotification:userInfo]; //TODO DELETE
    
    //if (application.applicationState == UIApplicationStateActive) //Foreground or Background
    //    return;
    
    
    if (application.applicationState == UIApplicationStateActive) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        //[[NotificationManager sharedInstance] notify:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] who:@"" type:MESSAGE_TYPE_TEXT];
        //UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"通知" message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] delegate:nil cancelButtonTitle:@
         //                         "OK" otherButtonTitles:nil, nil];
        //[alertview show];
    }
    //if (application.applicationState == UIApplicationStateInactive)
    {
        [self checkNotification:userInfo];
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma UserDefinded
- (void)configureUI
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    UIFont *font = [UIFont systemFontOfSize:22.f];
        [[UINavigationBar appearance] setTintColor:[UIColor ggaThemeColor]];
        [[UIBarButtonItem appearance] setTintColor:[UIColor ggaThemeColor]];
#ifdef IOS_VERSION_7
        [[UINavigationBar appearance] setBarTintColor:[UIColor ggaThemeColor]];
#endif
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor ggaWhiteColor], UITextAttributeTextColor,
          [UIColor ggaClearColor], UITextAttributeTextShadowColor,
          font, UITextAttributeFont, nil]];

        [[UITextField appearance] setBackgroundColor:[UIColor ggaWhiteColor]];
        [[UITextField appearance] setBorderStyle:UITextBorderStyleRoundedRect];
#ifdef IOS_VERESION_7
        [[UITextView appearance] setBackgroundColor:[UIColor ggaWhiteColor]];
#endif
}

- (void)configureEmoticon
{
    ARR_EMOJI = [NSMutableArray new];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F625], @"`A`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F60F], @"`B`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F614], @"`C`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F601], @"`D`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F609], @"`E`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F623], @"`F`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F616], @"`G`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F62A], @"`H`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F61D], @"`I`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F60C], @"`J`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F628], @"`K`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F637], @"`L`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F633], @"`M`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F612], @"`N`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F630], @"`O`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F635], @"`P`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F62D], @"`Q`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F602], @"`R`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F622], @"`S`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F60A], @"`T`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F604], @"`U`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F621], @"`V`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F61A], @"`W`", nil]];
    [ARR_EMOJI addObject:[NSArray arrayWithObjects:[self emojiWithCode:0x1F618], @"`X`", nil]];
}

- (NSString *)emojiWithCode:(int)code
{
    int sym = EMOJI_CODE_TO_SYMBOL(code);
    return [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
}

#pragma MHTabBarController
- (BOOL)mh_tabBarController:(MHTabBarController *) tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
    if (![NetworkManager sharedInstance].internetActive)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"network_invalid")];
        return NO;
    }
    
    return YES;
}

#pragma MHTabBarController
- (void)mh_tabBarController:(MHTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
    
}

- (void)showLoginVC
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.title = LANGUAGE(@"title");
    
    ggaNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    ggaNav.navigationBarHidden = YES;
    ggaNav.navigationItem.title = LANGUAGE(@"title");

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = ggaNav;
    [self.window makeKeyAndVisible];
}

- (void)showBody:(BOOL)animated
{    
    /** //TODO DELETE
    [APService setAlias:sUID
       callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                 object:self];
    **/
    
    sec = 0;
    
    [Chat sharedInstance];
    [Sqlite3Manager sharedInstance];
    
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(runtimeDetailLogic:) userInfo:nil repeats:YES];
    
    battleVC = [[ChallengePlayViewController alloc] init];
    discussVC = [[DiscussListViewController alloc] init];
    researchVC = [[ResearchViewController alloc] init];
    clublistVC = [[ClubListViewController alloc] init];
    
    battleVC.title = LANGUAGE(@"challenge");
    discussVC.title = LANGUAGE(@"discuss");
    researchVC.title = LANGUAGE(@"research");
    clublistVC.title = LANGUAGE(@"club");
    
    battleVC.tabBarItem.image = IMAGE(@"challenge_normal");
    discussVC.tabBarItem.image = IMAGE(@"discuss_normal");
    researchVC.tabBarItem.image = IMAGE(@"search_normal");
    clublistVC.tabBarItem.image = IMAGE(@"club_normal");
    
    NSArray *viewControllers = @[battleVC, discussVC, clublistVC, researchVC];
    tabBC = [[MHTabBarController alloc] init];
    tabBC.viewControllers = viewControllers;
    tabBC.tabButtonTitleColor = [UIColor ggaTextColor];
    tabBC.tabButtonSelTitleColor = [UIColor ggaThemeColor];
    tabBC.tabButtonBackgroundColor = [UIColor whiteColor];
    tabBC.tabButtonSelBackgroundColor = [UIColor whiteColor];
    
    tabBC.tabButtonFontSize = 13.0f;
    tabBC.tabBarHeight = 48.0f;
    [tabBC addDelegate:self];
    
    UIView *plusButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    
    UIButton *plusViewButton = [[UIButton alloc] initWithFrame:CGRectMake(45, -5, 37, 37)];
    [plusViewButton setImage:IMAGE(@"plus_view") forState:UIControlStateNormal];
    plusViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [plusViewButton addTarget:self action:@selector(onMoreViewClick:) forControlEvents:UIControlEventTouchDown];
    [plusButtonView addSubview:plusViewButton];
    
    UIButton *referViewButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, 30, 30)];
    [referViewButton setImage:IMAGE(@"discuss_ico") forState:UIControlStateNormal];
    [referViewButton addTarget:self action:@selector(onReferViewClick:) forControlEvents:UIControlEventTouchDown];
    [plusButtonView addSubview:referViewButton];
    
    //Modified By Boss.2015/05/15
    referLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 19, 14, 14)];
    referLabel.textColor = [UIColor whiteColor];
    referLabel.textAlignment = NSTextAlignmentCenter;
    referLabel.font = BOLDFONT(12.f);
    referLabel.textAlignment = NSTextAlignmentCenter;
    referLabel.layer.cornerRadius = 7;
    referLabel.backgroundColor = [UIColor redColor];
    referLabel.layer.masksToBounds = YES;
    [plusButtonView addSubview:referLabel];
    [self referLabelRefresh];
    
    
    tabBC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:plusButtonView];
    [tabBC setSelectedIndex:2];
    
    menuItems = [NSArray arrayWithObjects:
                 [KxMenuItem menuItem:LANGUAGE(@"general_menu_first")
                                image:[UIImage imageNamed:@"move_next"]
                               target:self
                               action:@selector(makingChallengeClicked:)],
                 [KxMenuItem menuItem:LANGUAGE(@"general_menu_second")
                                image:[UIImage imageNamed:@"move_next"]
                               target:self
                               action:@selector(creatingClubClicked:)],
                 
                 [KxMenuItem menuItem:LANGUAGE(@"general_menu_third")
                                image:[UIImage imageNamed:@"move_next"]
                               target:self
                               action:@selector(personalSettingsClicked:)],
                 
                 nil];
    for (KxMenuItem *item in menuItems)
        item.alignment = NSTextAlignmentCenter;

    [KxMenu setTitleFont:[UIFont systemFontOfSize:16]];
    
    if (ggaNav)
    {
        [ggaNav pushViewController:tabBC animated:animated];
        ggaNav.navigationBarHidden = NO;
        return;
    }
    
    ggaNav = [[UINavigationController alloc] initWithRootViewController:tabBC];
    ggaNav.navigationBarHidden = NO;
    ggaNav.navigationItem.title = LANGUAGE(@"title");

    tabBC.title = LANGUAGE(@"title");
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = ggaNav;
    [self.window makeKeyAndVisible];
}

- (void) onMoreViewClick: (UIButton *)item
{
    [KxMenu showMenuInView:tabBC.view
                  fromRect:CGRectMake(SCREEN_WIDTH - 28, 0, 10, 1)
                 menuItems:menuItems];
}

- (void)onReferViewClick:(id)sender
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[ConferenceController sharedInstance] animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
    NSLog(@"JPush ResultCode%d", iResCode);
}
- (void)loginSuccessed
{
    [self showBody:YES];
}

- (void)makingChallengeClicked:(id)sender
{
    if (ADMINCLUBCOUNT == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no admin club belongs to you")];
        return;
    }
    
    ggaAppDelegate *AppDelegate = APP_DELEGATE;
    UIViewController *vc = [[MakingChallengeController alloc] initWithChallengeTeam];
    if (vc)
        [AppDelegate.ggaNav pushViewController:vc animated:YES];
}

- (void)creatingClubClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ESTABLISH_DAY"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"WorkDays"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ACTIVE_ZONE"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STADIUM_ZONE"];

    ggaAppDelegate *AppDelegate = APP_DELEGATE;
    UIViewController *vc = [[CreatingClubController alloc] init];
    if (vc)
        [AppDelegate.ggaNav pushViewController:vc animated:YES];
    
}

- (void)personalSettingsClicked:(id)sender
{
    ggaAppDelegate *AppDelegate = APP_DELEGATE;
    UIViewController *vc = [[SettingsViewController alloc] init];
    if (vc)
        [AppDelegate.ggaNav pushViewController:vc animated:YES];
}


- (void)runtimeDetailLogic:(NSTimer *)timer
{
    if ((NSInteger)UID == NSNotFound)
        return;

    NSDate *curDate = [DateManager DateFromString:curSystemTimeStr];
    curDate = [curDate dateByAddingTimeInterval:1];
    curSystemTimeStr = [DateManager StringDateWithFormat:@"yyyy-MM-dd HH:mm:ss" date:curDate];
    
    sec = (sec + 1) % 5;
    if (sec != 0)
        return;
    
    NSString *club = @"";
    NSString *date = @"";
    for (NSDictionary *item in CLUBS) {
        if ([club isEqualToString:@""])
            club = [NSString stringWithFormat:@"%d", [[item valueForKey:@"club_id"] intValue]];
        else
            club = [NSString stringWithFormat:@"%@,%d", club, [[item valueForKey:@"club_id"] intValue]];
        
        if ([date isEqualToString:@""])
            date = [NSString stringWithFormat:@"%@", lastUpdateTime];
        else
            date = [NSString stringWithFormat:@"%@,%@", date, lastUpdateTime];
    }

    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:UID],
                      club,
                      date,
                      nil];
    [[RunTimeHttpManager sharedInstance] getRuntimeDetailWithDelegate:self data:array];
    
    [[Chat sharedInstance] tryConnection];
    
    if (CHATENABLE)
    {
        NSArray *chatArray = [ChatMessage getUnsendMessage];
        
        if (chatArray.count > 0)
            sentAllUnsendMsg = YES;
        
        for (ChatMessage *chats in chatArray) {
            NSLog(@"runtime send %lu messages", chatArray.count);
            [[Chat sharedInstance] sendChatMessage:chats withDelegate:nil];
        }
    }
    
}

#pragma HttpManagerDelegate
- (void)getRuntimeDetailResultWithErrorCode:(int)errorcode
{
    if (errorcode > 0)
        return;
    
    [self performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:YES];
    
}

- (void)refresh
{
    [clublistVC refreshTableView];
}

/*
 기능: 읽지 않은 메쎄지개수를 갱신하는 함수
 파람: roomID 채팅방아이디
 */
- (void)refreshCountView:(int)roomID
{
    if ([[ClubManager sharedInstance] checkMyClub:roomID])
        [clublistVC refreshUnreadCount];
    else
    {
        [self referLabelRefresh];
        [[ConferenceController sharedInstance] refreshTableView];
    }
}

- (void)referLabelRefresh
{
    int nNews = [[DiscussRoomManager sharedInstance] unreadCountAll];
    
    //Modified By Boss.2015/05/15
    if (nNews >= 10) {
        referLabel.frame = CGRectMake(referLabel.frame.origin.x, referLabel.frame.origin.y, 16, 16);
        referLabel.font = BOLDFONT(11.f);
        referLabel.layer.cornerRadius = 8 ;
    } else {
        referLabel.frame = CGRectMake(referLabel.frame.origin.x, referLabel.frame.origin.y, 14, 14);
        referLabel.layer.cornerRadius = 7 ;
    }
    
    if (nNews == 0)
        referLabel.hidden = YES;
    else
    {
        referLabel.hidden = NO;
        referLabel.text = [NSString stringWithFormat:@"%d", nNews];
    }
}

- (void)selectedIndex:(int)index
{
    [tabBC setSelectedIndex:index];
}

#pragma INotificationManager
- (void)tapNotificaionMessage:(NSString *)fromPN
{
}

- (void)notificationWillShow:(NSString *)message
{
}

/*
 *
 * Check remote notification.
 *
 * @author Boss
 * @since  2015/05/28
 */
-(void)checkNotification:(NSDictionary *)options
{
    ProcessRemoteNotification *processRemoteObj = [[ProcessRemoteNotification alloc] init];
    [processRemoteObj initWithDelegate];
    [processRemoteObj setRemoteNotification:options];
    
    int nMsgType = [processRemoteObj getNotificationType];
    
#ifdef DEMO_MODE
    [FileManager WriteErrorData:[NSString stringWithFormat:@"%@, 노티히케션을 체크합니다. 노티히케션정보 = %@ nMsgType = %d\r\n", LOGTAG, options, nMsgType]];
#endif
    
    switch (nMsgType) {
        case INVITE_REQUEST: //초청요청(2player)
            [processRemoteObj gotoInvitation];
            break;
    
        case TEMP_INVITE_REQUEST:
            [processRemoteObj gotoTempInvitation];
            break;
            
        case CHATTING_MESSAGE: //Chatting Remote
        case ACCEPT_INVITE_REQUEST:
        case ACCEPT_TEMP_INVITE_REQUEST:
        case ACCEPT_JOIN_REQUEST:
            [processRemoteObj gotoChat];
            break;
            
        case ADD_PROCLAIM_REQUEST:
        case CREATE_DISCUSS_CHATROOM_REQUEST:
            [processRemoteObj gotoNewsAlarm];
            
        case REGISTER_USER2CLUB_REQUEST:
            [processRemoteObj gotoRegisterRequest];
            break;
            
        case RESIGN_GAME_REQUEST:
        case AGREE_GAME_REQUEST:
            [processRemoteObj gotoSchedule];
            break;
            
        case DELETE_CHALLEANGE_REQUEST:
            [processRemoteObj gotoDeleteChallenge];
            break;
            
        case SET_GAME_RESULT_REQUEST:
            [processRemoteObj gotoSetGameResult]; //TODO MODIFY
            break;
            
        case DISMISS_CLUB_REQUEST:
        case BREAK_CLUB_REQUEST:
        case SET_MEMBER_POSITION_REQUEST:
            [processRemoteObj gotoDismissClub];
            break;
            
        case BEFORE_GAME_START_FOUR:
        case BEFORE_GAME_START_TWELVE:
        case BEFORE_GAME_START_TWENTYFOUR:            
            break;
            
        default:
            break;
    }
    
    //iOS의 NotificationCentre에서 알림삭제
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    savedNotification = nil;
}

/**
 -(void) processForChatRemoteNotification
{
    if (uidForRemoteNotification == -1)
        return;

    if (uidForRemoteNotification != UID)
    {
        ChatMessage *message = [ChatMessage new];
        
        message.senderId = uidForRemoteNotification;
        message.senderName = nameForRemoteNotification;
        message.sendTime = timeForRemoteNotification;
        message.roomId = roomIDForRemoteNotification;
        message.userPhoto = userPhotoForRemoteNotification;
        message.msg = msgForRemoteNotification;
        message.type = MESSAGE_TYPE_TEXT;
        message.sendState = 1;

        [ChatMessage addChatMessage:message];
    }
}

-(void) setForChatRemoteNotification:(NSDictionary*)remoteInfo
{
#ifdef REMOTE_NOTIFICATION_DEMO
    uidForRemoteNotification = 1;
#else
    uidForRemoteNotification = -1;
    if (remoteInfo == nil || remoteInfo.count == 0)
        return;
    
    NSDictionary *senderInfo = [remoteInfo objectForKey:@"sender"];
    if (remoteInfo == nil || remoteInfo.count == 0)
        return;
    
    uidForRemoteNotification = [[senderInfo objectForKey:@"sender_id"] intValue];
    roomIDForRemoteNotification = [[senderInfo objectForKey:@"chat_room_id"] intValue];
    nameForRemoteNotification= [senderInfo objectForKey:@"sender_name"];
    
    //TODO DELETE
    msgForRemoteNotification = [senderInfo objectForKey:@"content"];
    userPhotoForRemoteNotification = [senderInfo objectForKey:@"sender_photo"];
    timeForRemoteNotification = [senderInfo objectForKey:@"sendertime"];
#endif
}
**/

@end
