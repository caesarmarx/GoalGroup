//
//  ReportController.m
//  GoalGroup
//
//  Created by KCHN on 3/6/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ReportController.h"
#import "Common.h"

@interface ReportController ()
{
    UITextView *tvReport;
    BOOL isReport;
}
@end

@implementation ReportController

- (id)initWithTitle:(NSString *)title
{
    self.title = title;
    if ([self.title isEqual:LANGUAGE(@"SUGGEST")])
        isReport = NO;//의견제출
    else
        isReport = YES;//구락부마당->신고
    return [self init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])//iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    [self layoutComponents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutComponents
{
    self.view.backgroundColor = [UIColor ggaGrayBackColor];
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    
    UIView *finishButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 37)];
    UIButton *finishButton = [[UIButton alloc] initWithFrame:CGRectMake(18, 0, 24, 22)];
    [finishButton setImage:IMAGE(@"save_ico") forState:UIControlStateNormal];
    finishButton.titleLabel.font = FONT(14.f);
    [finishButton addTarget:self action:@selector(finishEditing) forControlEvents:UIControlEventTouchDown];
    [finishButtonRegion addSubview:finishButton];
    
    UIButton *lblButton = [[UIButton alloc] initWithFrame:CGRectMake(18, 23, 24, 15)];
    [lblButton setTitle:LANGUAGE(@"lbl_setting_report_save") forState:UIControlStateNormal];
    lblButton.titleLabel.textColor = [UIColor whiteColor];
    lblButton.titleLabel.font = FONT(12.f);
    [lblButton addTarget:self action:@selector(finishEditing) forControlEvents:UIControlEventTouchDown];
    [finishButtonRegion addSubview:lblButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:finishButtonRegion];
    
    
    tvReport = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH - 40, SCREEN_HEIGHT - 20 - 40 - self.navigationController.navigationBar.bounds.size.height)];
    tvReport.delegate = self;
    tvReport.autocorrectionType = UITextAutocorrectionTypeNo;
    tvReport.returnKeyType = UIReturnKeyDefault;
    tvReport.layer.borderWidth = 0.5f;
    tvReport.layer.cornerRadius = 2;
    tvReport.font = FONT(14.f);
    tvReport.text = @"";
    [self.view addSubview:tvReport];
}



#pragma UITextViewDelegate
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self resignFirstResponder];
    return YES;
}



#pragma Events
- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

- (void)finishEditing
{
    [tvReport endEditing:YES];
    [self reportButtonPressed];
}

- (void)reportButtonPressed
{
    [AlertManager WaitingWithMessage];
    NSString *reportStr = tvReport.text;
    if ([reportStr isEqual:@""])
    {
        [AlertManager AlertWithMessage:@"can not empty"];
        return;
    }
    
//    if (isReport)
//        [[HttpManager sharedInstance] clubReportWithDelegate:self data:reportStr];
//    else
    [[HttpManager sharedInstance] adviseOpinionWithDelegate:self data:reportStr];
}



#pragma HttpManagerDelegate
- (void)clubReportResultWithErrorCode:(int)errorCode
{
    [AlertManager HideWaiting];
    
    if (errorCode == ProtocolErrorTypeNone)
        [AlertManager AlertWithMessage:LANGUAGE(@"ClubReport Success")];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"Report failed")];
}

- (void)adviseOpinionResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"PersonReport Success")];
}

@end
