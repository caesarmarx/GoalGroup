//
//  AppDetailController.m
//  GoalGroup
//
//  Created by MacMini on 3/9/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "AppDetailController.h"
#import "Common.h"

@interface AppDetailController ()
{
    UIImageView *markView;
    UILabel *versionLabel;
    NSString *version;
    NSString *date;
    NSString *appUrl;
    BOOL exist;
}
@end

@implementation AppDetailController

+ (AppDetailController *)sharedInstance
{
    @synchronized(self)
    {
        if (gAppDetaiController == nil)
            gAppDetaiController = [[AppDetailController alloc] init];
    }
    return gAppDetaiController;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self layoutComponents];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    backImage.image = IMAGE(@"LaunchImage");
    [self.view addSubview:backImage];
    
    versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT - 180 - self.navigationController.navigationBar.bounds.size.height, SCREEN_WIDTH - 20, 40)];
    versionLabel.font = FONT(30.f);
    versionLabel.text = [NSString stringWithFormat:@"Ver %@", APPVERSION];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:versionLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutComponents
{
    self.title = LANGUAGE(@"app_info");
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
}

#pragma HttpManagerDelegate
- (void)updateVersionResultWithErrorCode:(int)error_code data:(NSArray *)data
{
    [AlertManager HideWaiting];
    
    version = [data objectAtIndex:0];
    date = [data objectAtIndex:1];
    appUrl = [data objectAtIndex:2];
    
    if (error_code > 0 || [APPVERSION isEqual:version] || !appUrl || [appUrl isEqual:@""])
        [AlertManager AlertWithMessage:LANGUAGE(@"no exist")];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"exist")];
}

#pragma UserDefined
- (void)updateButtonClick
{
    NSArray *array = [NSArray arrayWithObjects:[Common appNameAndVersionNumberDisplayString], nil];
    [AlertManager WaitingWithMessage];
    [[HttpManager sharedInstance] updateVersionWithDelegate:self data:array];
}

- (void)backToPage
{
    ggaAppDelegate *app = APP_DELEGATE;
    [app.ggaNav popViewControllerAnimated:YES];
}
@end
