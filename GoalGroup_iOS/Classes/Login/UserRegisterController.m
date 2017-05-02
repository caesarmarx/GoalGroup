//
//  UserRegisterController.m
//  GoalGroup
//
//  Created by MacMini on 3/11/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "UserRegisterController.h"
#import "Common.h"

@interface UserRegisterController ()
{
    UITextField *userPhone;
    UITextField *userPass;
    UITextField *passAgain;
    UITextField *userNickName;
    UIScrollView *backView;
}
@end

@implementation UserRegisterController

BOOL keyboardVisible;

+ (UserRegisterController *)sharedInstance
{
    @synchronized(self)
    {
        if (gUserRegisterController == nil)
            gUserRegisterController = [[UserRegisterController alloc] init];
    }
    return gUserRegisterController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    [self layoutComponents];
}

- (void)layoutComponents
{
    
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    
    self.title = LANGUAGE(@"register");
    
    backView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    backView.contentSize = self.view.frame.size;
    backView.backgroundColor = [UIColor ggaGrayBackColor];
    self.view.backgroundColor = [UIColor ggaGrayBackColor];

    userNickName = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH - 40, 38)];
    userNickName.borderStyle = UITextBorderStyleRoundedRect;
    userNickName.placeholder = LANGUAGE(@"alias");
    userNickName.returnKeyType = UIReturnKeyDone;
    userNickName.clearButtonMode = UITextFieldViewModeWhileEditing;
    userNickName.delegate = self;
    userNickName.font = FONT(14.f);
    [backView addSubview:userNickName];

    userPhone = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, SCREEN_WIDTH - 40, 38)];
    userPhone.borderStyle = UITextBorderStyleRoundedRect;
    userPhone.placeholder = LANGUAGE(@"phone_number");
    userPhone.keyboardType = UIKeyboardTypeDefault;
    userPhone.returnKeyType = UIReturnKeyDone;
    userPhone.clearButtonMode = UITextFieldViewModeWhileEditing;
    userPhone.delegate = self;
    userPhone.font = FONT(14.f);
    [backView addSubview:userPhone];
    
    userPass = [[UITextField alloc] initWithFrame:CGRectMake(20, 140, SCREEN_WIDTH - 40, 38)];
    userPass.borderStyle = UITextBorderStyleRoundedRect;
    userPass.placeholder = LANGUAGE(@"password");
    userPass.keyboardType = UIKeyboardTypeDefault;
    userPass.returnKeyType = UIReturnKeyDone;
    userPass.clearButtonMode = UITextFieldViewModeWhileEditing;
    userPass.secureTextEntry = YES;
    userPass.delegate = self;
    userPass.font = FONT(14.f);
    [backView addSubview:userPass];
    
    passAgain = [[UITextField alloc] initWithFrame:CGRectMake(20, 200, SCREEN_WIDTH - 40, 38)];
    passAgain.borderStyle = UITextBorderStyleRoundedRect;
    passAgain.placeholder = LANGUAGE(@"password_conf");
    passAgain.keyboardType = UIKeyboardTypeDefault;
    passAgain.returnKeyType = UIReturnKeyDone;
    passAgain.clearButtonMode = UITextFieldViewModeWhileEditing;
    passAgain.secureTextEntry = YES;
    passAgain.delegate = self;
    passAgain.font = FONT(14.f);
    [backView addSubview:passAgain];
    
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    registerButton.frame = CGRectMake(20, SCREEN_HEIGHT - 60 - 20 - self.navigationController.navigationBar.bounds.size.height, SCREEN_WIDTH - 40, 38);
    [registerButton setTitle:LANGUAGE(@"register") forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    registerButton.backgroundColor = [UIColor ggaThemeColor];
    registerButton.layer.cornerRadius = 8;
    registerButton.layer.borderColor = [UIColor whiteColor].CGColor;
    registerButton.layer.borderWidth = 1;
    registerButton.titleLabel.font = FONT(14.f);
    [registerButton addTarget:self action:@selector(registerButtonClick) forControlEvents:UIControlEventTouchDown];
    [backView addSubview:registerButton];
    
    [self.view addSubview:backView];
    
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(padClick:)];
    [backView addGestureRecognizer:singleRecognizer];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    userPhone.text = @"";
    userNickName.text = @"";
    userPass.text = @"";
    passAgain.text = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma textField delegate

- (void) keyboardDidShow: (NSNotification *)notif {
    
    // 이전에 키보드가 안보이는 상태였는지 확인합니다.
    if (keyboardVisible) {
        return;
    }
    
    // 키보드의 크기를 읽어옵니다.
    // NSNotification 객체는 userInfo 필드에 자세한 이벤트 정보를 담고 있습니다.
    NSDictionary* info = [notif userInfo];
    // 딕셔너리에서 키보드 크기를 얻어옵니다.
    //NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey]; // deprecated
    NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // 키보드의 크기만큼 스크롤 뷰의 크기를 줄입니다.
    CGRect viewFrame = backView.frame;
    viewFrame.size.height -= keyboardSize.height;
    
    backView.frame = viewFrame;
    keyboardVisible = YES;
}

- (void) keyboardDidHide: (NSNotification *)notif {
    
    // 이전에 키보드가 보이는 상태였는지 확인합니다.
    if (!keyboardVisible) {
        return;
    }
    
    // 키보드의 크기를 읽어옵니다.
    NSDictionary* info = [notif userInfo];
    //NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // 키보드의 크기만큼 스크롤 뷰의 높이를 늘여서 원래의 크기로 만듭니다.
    CGRect viewFrame = backView.frame;
    viewFrame.size.height += keyboardSize.height;
    
    backView.frame = viewFrame;
    keyboardVisible = NO;
}

- (void)registerButtonClick
{
    NSString *userStr = userPhone.text;
    NSString *passStr = userPass.text;
    NSString *passAgainStr = passAgain.text;
    NSString *nickStr = userNickName.text;
    
    if ([CustomValidation isEmpty:nickStr])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"register_username_empty")];
        return;
    }

    if ([CustomValidation ValidationLength:nickStr length:10 symbol:LENGTH_GREAT]) {
        [AlertManager AlertWithMessage:LANGUAGE(@"register_username_length_invalid")];
        return;
    }
    
    if ([CustomValidation ValidationEscape:nickStr bEscape:TRUE]) {
        [AlertManager AlertWithMessage:LANGUAGE(@"register_username_input_invalid")];
        return;
    }
    
    if ([CustomValidation isEmpty:userStr])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"register_phonenumber_empty")];
        return;
    }

    if ([CustomValidation ValidateMobile:userStr] == FALSE) {
        [AlertManager AlertWithMessage:LANGUAGE(@"register_phonenumber_invalid")];
        return;
    }
    
    if ([CustomValidation isEmpty:passStr])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"register_password_empty")];
        return;
    }
    
    if ([CustomValidation ValidationLength:passStr length:10 symbol:LENGTH_GREAT]) {
        [AlertManager AlertWithMessage:LANGUAGE(@"register_password_length_invalid")];
        return;
    }
    
    if ([CustomValidation ValidationEscape:passStr bEscape:TRUE]) {
        [AlertManager AlertWithMessage:LANGUAGE(@"register_password_input_invalid")];
        [userPass setText:@""];
        [passAgain setText:@""];
        return;
    }

    if ([CustomValidation isEmpty:passAgainStr])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"register_password_confirm")];
        return;
    }

    if (![passStr isEqualToString:passAgainStr])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"register_password_diff")];
        [userPass setText:@""];
        [passAgain setText:@""];
        return;
    }
    
    userRegisteredSuccessfully = NO;
    NSArray *data = [NSArray arrayWithObjects:userStr, nickStr, passStr, nil];
    
    [AlertManager WaitingWithMessage];
    [[HttpManager sharedInstance] userRegisterWithDelegate:self data:data];
}

- (void)padClick:(UITapGestureRecognizer *)recognizer
{
    [backView endEditing:YES];
}

#pragma HttpManagerDelegate
- (void)userRegisterResultWithErrorCode:(int)errorCode
{
    [AlertManager HideWaiting];
    if (errorCode > 0) {
        switch (errorCode) {
            case 2: //Telephone duplicated
                [AlertManager AlertWithMessage:LANGUAGE(@"register_phone_duplicated")];
                break;
            case 3: //UserName duplicated
                [AlertManager AlertWithMessage:LANGUAGE(@"register_username_duplicated")];
                break;
            default:
                [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorCode])];
                break;

        }
    }
    else
    {
        gWaitingAlertView = nil;
//        [AlertManager AlertWithMessage:LANGUAGE(@"register_user_success")];
        [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(doShowLoginVC) userInfo:nil repeats:NO];
    }
}

- (void)doShowLoginVC
{
    [AlertManager HideWaiting];
    
    userRegisteredSuccessfully = YES;
    
    [[NSUserDefaults standardUserDefaults ] setObject:userPhone.text forKey:@"LOGIN_DATA_USER"];
    [[NSUserDefaults standardUserDefaults] setObject:userPass.text forKey:@"LOGIN_DATA_PASS"];
    
    [APP_DELEGATE showLoginVC];
}

#pragma Events
- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popToRootViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = YES;
}
@end
