//
//  LoginViewController.m
//
//  Created by JinYongHao on 9/25/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import "LoginViewController.h"
#import "UserRegisterController.h"
#import "Common.h"



@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize scrollView;
BOOL keyboardVisible;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dnv = nil;
    [self layoutComponents];
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    self.navigationController.navigationBarHidden = YES;
    
    if (userRegisteredSuccessfully || [LoginManager checkIsAlreadyLogin])
    {
        usTextField.text = [[NSUserDefaults standardUserDefaults ] objectForKey:@"LOGIN_DATA_USER"];
        pwTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"LOGIN_DATA_PASS"];
        
        [self tryLogin:YES];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    //Scroll View
    CGRect viewFrame = scrollView.frame;
    viewFrame.size.height = SCREEN_HEIGHT;
    scrollView.frame = viewFrame;
    keyboardVisible = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma HttpManagerDelegate
- (void)loginResultWithErrorCode:(int)errorCode
{
    if (dnv)
    {
        [dnv hide:YES];
        dnv = nil;
    }
    if (errorCode > 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorCode])];
        return;
    }

    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"LOGIN_DATA_USER"];
    NSString *pass = [[NSUserDefaults standardUserDefaults] objectForKey:@"LOGIN_DATA_PASS"];
    UID = (int)[[[NSUserDefaults standardUserDefaults] objectForKey:@"LOGIN_DATA_UID" ] integerValue];
    
    [[LoginManager sharedInstance] setIsAlreadyLoginWithNickname:user password:pass uid:UID];
    [[UIApplication sharedApplication] delegate];
    [APP_DELEGATE loginSuccessed];
}



#pragma Event
- (void)loginPressed:(id)sender
{
    if (![NetworkManager sharedInstance].internetActive)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"network_invalid")];
        return;
    }
    [self tryLogin:YES];
}



#pragma UserDefinded
- (void)tryLogin:(BOOL)uiValidation
{
    if (uiValidation == YES)
    {
        if (usTextField.text == nil || [usTextField.text isEqualToString:@""])
        {
            [AlertManager AlertWithMessage:LANGUAGE(@"register_phonenumber_empty")];
            return;
        }
        if (pwTextField.text == nil || [pwTextField.text isEqualToString:@""])
        {
            [AlertManager AlertWithMessage:LANGUAGE(@"register_password_empty")];
            return;
        }
        [self.view endEditing:YES];
        
        if (dnv)
            return;
        dnv  = [AlertManager DiscreetNotificationWithView:self.view message:LANGUAGE(@"registering...")];
    }
    
    NSArray *array = [NSArray arrayWithObjects:usTextField.text, pwTextField.text, nil];
    [[HttpManager sharedInstance] loginWithDelegate:self data:array];
}


#pragma UserDefined
- (void)registerPressed:(id)sender
{
    [self.view endEditing:YES];
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[UserRegisterController alloc] init] animated:YES];
    appDelegate.ggaNav.navigationBarHidden = NO;
}

- (void)padClick:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

- (void)layoutComponents
{
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.contentSize = self.view.frame.size;
    self.view = scrollView;
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    backImage.image = IMAGE(@"loginbackground");
    [self.view addSubview:backImage];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT / 3 + 30, SCREEN_WIDTH, 100)];
    backView.tag = 100;
    
    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, SCREEN_WIDTH - 100, 30)];
    userView.backgroundColor = [UIColor ggaUserLoginFieldColor];
    userView.layer.cornerRadius = 15.f;
    userView.layer.masksToBounds = YES;
    
    UIImageView *userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 15, 20)];
    userIcon.image = IMAGE(@"log_in_user_name_icon");
    
    usTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 0, SCREEN_WIDTH - 170, 30)];
    usTextField.borderStyle = UITextBorderStyleNone;
    usTextField.placeholder =LANGUAGE(@"login_placeholder_phonenumber");
    usTextField.keyboardType = UIKeyboardTypeDefault;
    usTextField.returnKeyType = UIReturnKeyDone;
#ifdef IOS_VERSION_7
    usTextField.backgroundColor = [UIColor clearColor];
#endif
    usTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    usTextField.font = FONT(13.f);
    usTextField.delegate = self;

    [userView addSubview:userIcon];
    [userView addSubview:usTextField];
    
    [backView addSubview:userView];
    
    UIView *passView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, SCREEN_WIDTH - 100, 30)];
    passView.backgroundColor = [UIColor ggaUserLoginFieldColor];
    passView.layer.cornerRadius = 15.f;
    passView.layer.masksToBounds = YES;
    
    UIImageView *passIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 15, 20)];
    passIcon.image = IMAGE(@"log_in_key_icon");

    pwTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 0, SCREEN_WIDTH - 170, 30)];
    pwTextField.borderStyle = UITextBorderStyleNone;
    pwTextField.placeholder = LANGUAGE(@"login_placeholder_password");
    pwTextField.keyboardType = UIKeyboardTypeDefault;
    pwTextField.returnKeyType = UIReturnKeyDone;
    pwTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    pwTextField.delegate = self;
#ifdef IOS_VERSION_7
    pwTextField.backgroundColor = [UIColor clearColor];
#endif
    pwTextField.font = FONT(13.f);
    pwTextField.secureTextEntry = YES;
    
    [passView addSubview:passIcon];
    [passView addSubview:pwTextField];
    
    [backView addSubview:passView];
    
    [self.view addSubview:backView];
    
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setBackgroundColor:[UIColor whiteColor]];
    [loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(50, SCREEN_HEIGHT / 3 + 130 + 20, SCREEN_WIDTH - 100, 30);
    [loginButton setTitle:LANGUAGE(@"login") forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginPressed:) forControlEvents:UIControlEventTouchDown];
    [loginButton setTitleColor:[UIColor ggaUserLoginFieldColor] forState:UIControlStateNormal];
    if (IOS_VERSION >= 7.0)
    {
        loginButton.layer.cornerRadius = 15;
    }
    
    [self.view addSubview:loginButton];
    
    registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registerButton.frame = CGRectMake(100, SCREEN_HEIGHT - 60, SCREEN_WIDTH - 200, 30);
    [registerButton setTintColor:[UIColor whiteColor]];

    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (IOS_VERSION >= 7.0)
    {
        registerButton.layer.borderWidth = 1;
        registerButton.layer.cornerRadius = 15;
        registerButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    }
    [registerButton setTitle:LANGUAGE(@"register") forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerPressed:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:registerButton];
    
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(padClick:)];
    [self.view addGestureRecognizer:singleRecognizer];
    
}

#pragma textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void) keyboardDidShow: (NSNotification *)notif {
    
    // 키보드의 크기를 읽어옵니다.
    // NSNotification 객체는 userInfo 필드에 자세한 이벤트 정보를 담고 있습니다.
    NSDictionary* info = [notif userInfo];
    // 딕셔너리에서 키보드 크기를 얻어옵니다.
    //NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey]; // deprecated
    NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    CGSize keyboardSizeAfter = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    // 키보드의 크기만큼 스크롤 뷰의 크기를 줄입니다.
    CGRect viewFrame = self.view.frame;
    if (keyboardVisible)
        viewFrame.size.height -= (keyboardSizeAfter.height - keyboardSize.height);
    else
        viewFrame.size.height -= keyboardSize.height;
    
    scrollView.frame = viewFrame;
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
    CGRect viewFrame = self.view.frame;
    viewFrame.size.height += keyboardSize.height;
    
    scrollView.frame = viewFrame;
    keyboardVisible = NO;
}

@end
