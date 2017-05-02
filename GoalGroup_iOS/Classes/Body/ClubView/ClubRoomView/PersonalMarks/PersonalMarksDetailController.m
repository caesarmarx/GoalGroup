//
//  PersonalMarksDetailController.m
//  GoalGroup
//
//  Created by KCHN on 2/21/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "PersonalMarksDetailController.h"
#import "PersonalMarksItemView.h"
#import "Common.h"

@interface PersonalMarksDetailController ()
{
    NSArray *marks;
    PersonalMarksItemView *marksView;
}
@end

@implementation PersonalMarksDetailController

+ (PersonalMarksDetailController *)sharedInstance
{
    @synchronized(self)
    {
        if (gPersonalMarksDetailController == nil)
            gPersonalMarksDetailController = [[PersonalMarksDetailController alloc] init];
    }
    return gPersonalMarksDetailController;
}

- (id)initWithClub:(int)club
{
    self = [self init];
    if (self)
    {
        nClubID = club;
        self.title = [NSString stringWithFormat:@"%@-%@", [[ClubManager sharedInstance] stringClubNameWithID:nClubID], LANGUAGE(@"PersonalMarkDetailController Title")];

    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
        [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

        [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
        [backButtonRegion addSubview:backButton];
         self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    self.view.backgroundColor = self.view.backgroundColor = [UIColor colorWithRed:116.f/255.f green:203.f/255.f blue:156.f/255.f alpha:1.0f];;
    
    marksView = [[PersonalMarksItemView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 8)];
    marksView.backgroundColor = [UIColor colorWithRed:52.f/255.f green:140.f/255.f blue:92.f/255.f alpha:1.0f];
    [self.view addSubview:marksView];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSNumber *number = [NSNumber numberWithInt:nClubID];
    
    [[HttpManager sharedInstance] browsePlayerMarkWithDelegate:self club:number];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

#pragma HttpManagerDelegate
- (void)browsePlayerMarkResultwithErrorCode:(int)errorCode data:(NSArray *)data
{
    if (errorCode > 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorCode])];
    }
    else
    {
        marks = [NSArray arrayWithArray:data];
        [marksView drawPersonalMarks:marks];
    }
}
@end
