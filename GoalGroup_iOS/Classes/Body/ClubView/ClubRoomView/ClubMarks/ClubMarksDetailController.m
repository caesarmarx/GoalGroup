//
//  ClubMarksDetailController.m
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubMarksDetailController.h"
#import "ClubMarksItemView.h"
#import "Common.h"

@interface ClubMarksDetailController ()
{
    NSArray *marks;
}
@end

@implementation ClubMarksDetailController

- (id)initWithClubID:(int)clubid
{
    self = [super init];
    if (self)
    {
        nClubID = clubid;
        self.title = [NSString stringWithFormat:@"%@-%@", [[ClubManager sharedInstance] stringClubNameWithID:nClubID], LANGUAGE(@"Club_Mark_Result")];

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
    // Do any additional setup after loading the view.
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
      
    self.view.backgroundColor = [UIColor colorWithRed:116.f/255.f green:203.f/255.f blue:156.f/255.f alpha:1.0f];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[HttpManager sharedInstance] browseClubMarkWithDelegate:self club:[NSNumber numberWithInt:nClubID]];
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
- (void)browseClubMarkResultWithErrorCode:(int)errorCode data:(NSArray *)data
{
    if (errorCode > 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorCode])];
    }
    else
    {
        marks = [NSArray arrayWithArray:data];
        [self drawClubMarks];
    }
}

#pragma UserDefind
- (void)drawClubMarks
{
    NSInteger w = SCREEN_WIDTH;
    NSInteger h = w / 8;
  
    ClubMarksItemView *marksView = [[ClubMarksItemView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    marksView.backgroundColor = [UIColor colorWithRed:52.f/255.f green:140.f/255.f blue:92.f/255.f alpha:1.0f];
    [marksView drawClubMarks:marks];
    
    [self.view addSubview:marksView];
}
@end
