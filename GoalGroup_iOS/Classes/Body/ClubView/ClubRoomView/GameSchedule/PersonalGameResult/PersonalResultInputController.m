//
//  PersonalResultInputController.m
//  GoalGroup
//
//  Created by MacMini on 4/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "PersonalResultInputController.h"
#import "Common.h"

@interface PersonalResultInputController ()

@end

@implementation PersonalResultInputController

+ (PersonalResultInputController *)sharedInstance
{
    @synchronized(self)
    {
        if (gPersonalResultInputController == nil)
            gPersonalResultInputController = [[PersonalResultInputController alloc] init];
    }
    return gPersonalResultInputController;
}

- (void)setGoal:(int)goal assist:(int)assist point:(int)point title:(NSString *)title
{
    goalTextField.text = [NSString stringWithFormat:@"%d", goal];
    assistTextField.text = [NSString stringWithFormat:@"%d", assist];
    pointTextField.text = [NSString stringWithFormat:@"%d", point];
    self.title = title;
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
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    // Do any additional setup after loading the view.
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

    goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 30)];
    [goalLabel setFont:FONT(14.f)];
    [goalLabel setTextAlignment:NSTextAlignmentRight];
    [goalLabel setText:[NSString stringWithFormat:@"%@:",LANGUAGE(@"ClubMarkItem_Title_5")]];
    
    goalTextField = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, SCREEN_WIDTH - 130, 30)];
    goalTextField.borderStyle = UITextBorderStyleRoundedRect;
    goalTextField.keyboardType = UIKeyboardTypeNumberPad;
    goalTextField.returnKeyType = UIReturnKeyDone;
    goalTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [goalTextField setFont:FONT(14.f)];
    goalTextField.delegate = self;
    [goalTextField setText:@"0"];

    assistLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 30)];
    [assistLabel setFont:FONT(14.f)];
    [assistLabel setTextAlignment:NSTextAlignmentRight];
    [assistLabel setText:[NSString stringWithFormat:@"%@:",LANGUAGE(@"HELP ATTACK")]];
    
    assistTextField = [[UITextField alloc] initWithFrame:CGRectMake(120, 60, SCREEN_WIDTH - 130, 30)];
    assistTextField.borderStyle = UITextBorderStyleRoundedRect;
    assistTextField.keyboardType = UIKeyboardTypeNumberPad;
    assistTextField.returnKeyType = UIReturnKeyDone;
    assistTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [assistTextField setFont:FONT(14.f)];
    assistTextField.delegate = self;
    [assistTextField setText:@"0"];

    pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, 100, 30)];
    [pointLabel setFont:FONT(14.f)];
    [pointLabel setTextAlignment:NSTextAlignmentRight];
    [pointLabel setText:[NSString stringWithFormat:@"%@:",LANGUAGE(@"Game Point Avg")]];
    
    pointTextField = [[UITextField alloc] initWithFrame:CGRectMake(120, 110, SCREEN_WIDTH - 130, 30)];
    pointTextField.borderStyle = UITextBorderStyleRoundedRect;
    pointTextField.keyboardType = UIKeyboardTypeNumberPad;
    pointTextField.returnKeyType = UIReturnKeyDone;
    pointTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [pointTextField setFont:FONT(14.f)];
    pointTextField.delegate = self;
    [pointTextField setText:@"0"];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(padClick:)];
    [self.view addGestureRecognizer:recognizer];
    
    [self.view addSubview: goalLabel];
    [self.view addSubview: assistLabel];
    [self.view addSubview:pointLabel];
    [self.view addSubview: goalTextField];
    [self.view addSubview: assistTextField];
    [self.view addSubview: pointTextField];
}

- (void)backToPage
{
    int goal = [goalTextField.text intValue];
    int assist = [assistTextField.text intValue];
    int point = [pointTextField.text intValue];
    
    if (goal > 99 || assist > 99 || point > 99)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"available number small than 99")];
        return;
    }
    
    [self.delegate inputFinished:goal assist:assist point:point];
    [Common BackToPage];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)padClick:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
