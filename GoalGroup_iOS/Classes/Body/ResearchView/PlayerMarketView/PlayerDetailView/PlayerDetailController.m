//
//  PlayerDetailController.m
//  GoalGroup
//
//  Created by KCHN on 2/26/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "PlayerDetailController.h"
#import "NSPosition.h"
#import "NSWeek.h"
#import "PositionSelectController.h"
#import "DistrictManager.h"
#import "Common.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utils.h"
#import "JSON.h"
#import "Constants.h"
#import "HttpRequest.h"

@interface PlayerDetailController ()
{
    UIImagePickerController *imagePicker;
    
    int nPlayerID;
    UIImageView *playerIcon;
    UITextField *nameTextField;
    UITextField *heightTextField;
    UITextField *weightTextField;
    UITextField *footballAgeTextField;
    UILabel *phoneText;
    UILabel *sexText;
    UILabel *birthdayText;
    UILabel *positionText;
    UILabel *cityText;
    UILabel *timeText;
    UILabel *areaText;
    UIDatePicker *datepicker;
    UIToolbar *toolbar;
    
    UIButton *changeButton;
    UIButton *inviteButton;
    
    NSString *name;
    NSString *phone;
    NSString *sex;
    NSString *birthday;
    NSString *height;
    NSString *weight;
    NSString *age;
    NSString *pos;
    NSString *time;
    NSString *city;
    NSString *area;
    
    BOOL receivedHttp;
    BOOL imageChanged;
    BOOL keyboardVisible;
    
    NSString *savedFilePath;
    UIScrollView *scrollView;
    
    NSString *savedImageUrl;
}
@end

@implementation PlayerDetailController
{
    BOOL showButton;
}

- (id)initWithPlayerID:(int)pid showInviteButton:(BOOL)show
{
    nPlayerID = pid;
    showButton = show;
    receivedHttp = YES;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PLAYERDETAIL_POSITION"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"WorkDays"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ACTIVE_ZONE"];
    return [self init];
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

- (void)viewWillAppear:(BOOL)animated
{
    
    keyboardVisible = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    if (receivedHttp)
    {
        receivedHttp = NO;
        return;
    }
    
    NSString *position = [[NSUserDefaults standardUserDefaults] objectForKey:@"PLAYERDETAIL_POSITION"];
    positionText.text = [NSPosition formattedStringFromPLAYERDETAIL_POSITION:position];
    timeText.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"WorkDays"];
    NSString *areaTemp = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACTIVE_ZONE"];
    areaText.text = areaTemp;

    [self reControlLabel];
    [self.view endEditing:YES];
}

- (void) resignFirstAllControls
{
    [heightTextField resignFirstResponder];
    [weightTextField resignFirstResponder];
    [footballAgeTextField resignFirstResponder];
    
    [self keyboardDidHide:nil];
    [self viewWillAppear:YES];
}

- (void) reControlLabel
{
    UIView *group3View = nil;
    for(UIView *view in scrollView.subviews) {
        if (view.tag == 100) {
            group3View = view;
            break;
        }
    }
    
    NSInteger itemAllDiff = 0;
    NSInteger itemDiff = 0;
    CGRect frame;
    CGSize strSize = [positionText.text sizeWithFont:FONT(14.f) constrainedToSize:CGSizeMake(SCREEN_WIDTH - 155, 300)];
    if (strSize.height > 17) {
        frame = positionText.frame;
        frame.size.height = strSize.height + 7;
        itemDiff = frame.size.height - positionText.frame.size.height;
        itemAllDiff += itemDiff;
        positionText.frame = frame;
        for (UIView* view in group3View.subviews) {
            if (view.tag == 101) { //PositionView
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, positionText.frame.size.height + 3);
            }
            if (view.tag < 105) {
                continue;
            }
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + itemDiff, view.frame.size.width, view.frame.size.height);
        }
    } else {
        frame = positionText.frame;
        frame.size.height = 33;
        itemDiff = frame.size.height - positionText.frame.size.height;
        itemAllDiff += itemDiff;
        positionText.frame = frame;
        for (UIView* view in group3View.subviews) {
            if (view.tag == 101) { //PositionView
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, positionText.frame.size.height + 3);
            }
            if (view.tag < 105) {
                continue;
            }
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + itemDiff, view.frame.size.width, view.frame.size.height);
        }
    }
    
    //TimeText
    strSize = [timeText.text sizeWithFont:FONT(14.f)];
    if (strSize.width > (SCREEN_WIDTH - 155)) {
        frame = timeText.frame;
        frame.size.height = strSize.height + 15 + strSize.height;
        itemDiff = frame.size.height - timeText.frame.size.height;
        itemAllDiff += itemDiff;
        timeText.frame = frame;
        
        for (UIView* view in group3View.subviews) {
            if (view.tag == 120) { //PositionView
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, timeText.frame.size.height + 3);
            }
            if (view.tag < 124) {
                continue;
            }
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + itemDiff, view.frame.size.width, view.frame.size.height);
        }
    } else {
        frame = timeText.frame;
        frame.size.height = 33;
        NSInteger itemDiff = frame.size.height - timeText.frame.size.height;
        itemAllDiff += itemDiff;
        timeText.frame = frame;
        
        for (UIView* view in group3View.subviews) {
            if (view.tag == 120) { //PositionView
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, timeText.frame.size.height + 3);
            }
            if (view.tag < 124) {
                continue;
            }
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + itemDiff, view.frame.size.width, view.frame.size.height);
        }
    }
    
    //ActiveAreaText
    strSize = [areaText.text sizeWithFont:FONT(14.f)];
    if (strSize.width > (SCREEN_WIDTH - 155)) {
        frame = areaText.frame;
        frame.size.height = strSize.height + 15 + strSize.height;
        itemDiff = frame.size.height - areaText.frame.size.height;
        itemAllDiff += itemDiff;
        areaText.frame = frame;
        
        for (UIView* view in group3View.subviews) {
            if (view.tag == 130) { //AreaView
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, areaText.frame.size.height + 3);
            }
            if (view.tag < 134) {
                continue;
            }
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + itemDiff, view.frame.size.width, view.frame.size.height);
        }
    } else {
        frame = areaText.frame;
        frame.size.height = 33;
        itemDiff = frame.size.height - areaText.frame.size.height;
        itemAllDiff += itemDiff;
        areaText.frame = frame;
        
        for (UIView* view in group3View.subviews) {
            if (view.tag == 130) { //AreaView
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, areaText.frame.size.height + 3);
            }
            if (view.tag < 134) {
                continue;
            }
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + itemDiff, view.frame.size.width, view.frame.size.height);
        }
    }
    
    for (UIView* view in group3View.subviews) {
        if (view.tag == 124) {
            frame = group3View.frame;
            frame.size.height = view.frame.origin.y + areaText.frame.size.height + 3;
            group3View.frame = frame;
            break;
        }
    }
    
    inviteButton.frame = CGRectMake(inviteButton.frame.origin.x, inviteButton.frame.origin.y + itemAllDiff - 20, inviteButton.frame.size.width, inviteButton.frame.size.height);
    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + itemAllDiff);
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSPosition getPLAYERDETAIL_POSITIONFromFormattedString:positionText.text] forKey:@"PLAYERDETAIL_POSITION"];
    [[NSUserDefaults standardUserDefaults] setObject:timeText.text forKey:@"WorkDays"];
    [[NSUserDefaults standardUserDefaults] setObject:areaText.text forKey:@"ACTIVE_ZONE"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.view endEditing:NO];
    [scrollView endEditing:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
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
    
    
    // 이전에 키보드가 안보이는 상태였는지 확인합니다.
    if (keyboardVisible && (keyboardSizeAfter.height > keyboardSize.height))
    {
        CGRect viewFrame = self.view.frame;
        viewFrame.size.height -= (keyboardSizeAfter.height - keyboardSize.height);
        
        scrollView.frame = viewFrame;
        keyboardVisible = YES;
        return;
    }
    
    if (keyboardVisible) {
        return;
    }
    
    // 키보드의 크기만큼 스크롤 뷰의 크기를 줄입니다.
    CGRect viewFrame = self.view.frame;
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

- (void)layoutComponents
{
    self.title = LANGUAGE(@"PlayerDetailController Title");
    
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    UIView * changeButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 35)];
    changeButton = [[UIButton alloc] initWithFrame:CGRectMake(11, 0, 23, 20)];
    [changeButton setImage: [UIImage imageNamed:@"edit_ico"] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeButtonClick:) forControlEvents:UIControlEventTouchDown];
    [changeButtonRegion addSubview:changeButton];

    UIButton *lblButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 25, 15)];
    [lblButton setTitle:LANGUAGE(@"lbl_club_detail_save") forState:UIControlStateNormal];
    lblButton.titleLabel.textColor = [UIColor whiteColor];
    lblButton.titleLabel.font = FONT(12.f);
    [lblButton addTarget:self action:@selector(changeButtonClick:) forControlEvents:UIControlEventTouchDown];
    [changeButtonRegion addSubview:lblButton];
    
    NSInteger UID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LOGIN_DATA_UID" ] integerValue];
    if (nPlayerID == (int)UID ) { //Login User
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:changeButtonRegion];
    } else { //Not Login User
        self.title = LANGUAGE(@"PlayerDetailController Title 2");
    }
    
    self.view.backgroundColor = [UIColor ggaGrayBackColor];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    scrollView.backgroundColor = [UIColor ggaGrayBackColor];
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:scrollView];
    
    UIView *iconBack = [[UIView alloc] initWithFrame:CGRectMake(25, 5, 50, 50)];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerIconClick:)];
    [iconBack addGestureRecognizer:singleTap];
    
    playerIcon = [[UIImageView alloc] initWithFrame:iconBack.frame];
    
    [scrollView addSubview:iconBack];
    [scrollView addSubview:playerIcon];
    
    nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(98, 16, SCREEN_WIDTH - 150, 28)];
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    nameTextField.returnKeyType = UIReturnKeyDone;
    nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTextField.delegate = self;
    nameTextField.font = FONT(14.f);
    if (nPlayerID != UID) nameTextField.enabled = NO;
    
    [scrollView addSubview:nameTextField];

    UIFont *font = FONT(14.f);
    UIColor *backColor = [UIColor ggaThemeGrayColor];

    UIView *group1View = [[UIView alloc] initWithFrame:CGRectMake(10, 70, SCREEN_WIDTH - 20, 35)];
    group1View.backgroundColor = backColor;
    group1View.layer.cornerRadius = 6.f;
    [scrollView addSubview:group1View];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 80, 33)];
    label.text =[NSString stringWithFormat:@"%@ :",LANGUAGE(@"phone_number")];
    label.textAlignment = NSTextAlignmentRight;
    label.font = font;
    [group1View addSubview:label];
    
    phoneText = [[UILabel alloc] initWithFrame:CGRectMake(90, 1, SCREEN_WIDTH - 120, 33)];
    phoneText.font = font;
    [group1View addSubview:phoneText];
    
    UIView *group2View = [[UIView alloc] initWithFrame:CGRectMake(10, 127, SCREEN_WIDTH - 20, 35 * 5)];
    group2View.backgroundColor = backColor;
    group2View.layer.cornerRadius = 6.f;
    [scrollView addSubview:group2View];
    
    //Sex
    UIView *sexView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, 35)];
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sexViewClick:)];
    [sexView addGestureRecognizer:singleTap];
    [group2View addSubview:sexView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 80, 33)];
    label.text = [NSString stringWithFormat:@"%@ :",LANGUAGE(@"SEX")];
    label.textAlignment = NSTextAlignmentRight;
    label.font = font;
    [sexView addSubview:label];
    
    sexText = [[UILabel alloc] initWithFrame:CGRectMake(90, 1, SCREEN_WIDTH - 140, 33)];
    sexText.font = font;
    [sexView addSubview:sexText];
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 47, 10, 15, 15)];
    arrowImage.image = IMAGE(@"player_sex_black");
    //if (nPlayerID != UID) arrowImage.hidden = YES;
    [sexView addSubview:arrowImage];
    
    LBorderView *dotView = [[LBorderView alloc]initWithFrame:CGRectMake(10, 34, SCREEN_WIDTH - 40, 0.5f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [sexView addSubview:dotView];
    
    //Birthday
    UIView *birthdayView = [[UIView alloc] initWithFrame:CGRectMake(0, 35, SCREEN_WIDTH - 20, 35)];
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(birthdayViewClick:)];
    [birthdayView addGestureRecognizer:singleTap];
    [group2View addSubview:birthdayView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 80, 33)];
    label.text =[NSString stringWithFormat:@"%@ :",LANGUAGE(@"BIRTHDAY")];
    label.textAlignment = NSTextAlignmentRight;
    label.font = font;
    [birthdayView addSubview:label];
    
    birthdayText = [[UILabel alloc] initWithFrame:CGRectMake(90, 1, SCREEN_WIDTH - 140, 33)];
    birthdayText.font = font;
    [birthdayView addSubview:birthdayText];
    
    arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 48, 7, 18, 18)];
    arrowImage.image = IMAGE(@"create_club_date");
    //if (nPlayerID != UID) arrowImage.hidden = YES;
    [birthdayView addSubview:arrowImage];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(10, 34, SCREEN_WIDTH - 40, 0.5f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [birthdayView addSubview:dotView];
    
    //Height
    UIView *heightView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, SCREEN_WIDTH - 20, 35)];
    [group2View addSubview:heightView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 80, 33)];
    label.text = [NSString stringWithFormat:@"%@ :",LANGUAGE(@"HEIGHT")];
    label.textAlignment = NSTextAlignmentRight;
    label.font = font;
    [heightView addSubview:label];
    
    heightTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 4, SCREEN_WIDTH - 130, 27)];
    heightTextField.borderStyle = UITextBorderStyleRoundedRect;
    heightTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    heightTextField.returnKeyType = UIReturnKeyDone;
    heightTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    heightTextField.delegate = self;
    heightTextField.font = font;
    heightTextField.enabled = NO;
    heightTextField.keyboardType = UIKeyboardTypeNumberPad;
    [heightView addSubview:heightTextField];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(10, 34, SCREEN_WIDTH - 40, 0.5f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [heightView addSubview:dotView];
    
    //Weight
    UIView *weightView = [[UIView alloc] initWithFrame:CGRectMake(0, 105, SCREEN_WIDTH - 20, 35)];
    [group2View addSubview:weightView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 80, 33)];
    label.text = [NSString stringWithFormat:@"%@ :",LANGUAGE(@"MAINWEIGHT")];
    label.textAlignment = NSTextAlignmentRight;
    label.font = font;
    [weightView addSubview:label];
    
    weightTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 4, SCREEN_WIDTH - 130, 27)];
    weightTextField.borderStyle = UITextBorderStyleRoundedRect;
    weightTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    weightTextField.returnKeyType = UIReturnKeyDone;
    weightTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    weightTextField.delegate = self;
    weightTextField.font = font;
    weightTextField.enabled = NO;
    weightTextField.keyboardType = UIKeyboardTypeNumberPad;
    [weightView addSubview:weightTextField];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(10, 34, SCREEN_WIDTH - 40, 0.5f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [weightView addSubview:dotView];
    
    //FootballAge
    UIView *footballView = [[UIView alloc] initWithFrame:CGRectMake(0, 140, SCREEN_WIDTH - 20, 35)];
    [group2View addSubview:footballView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 80, 33)];
    label.text = [NSString stringWithFormat:@"%@ :",LANGUAGE(@"FOOTBALLAGE")];
    label.textAlignment = NSTextAlignmentRight;
    label.font = font;
    [footballView addSubview:label];
    
    footballAgeTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 4, SCREEN_WIDTH - 130, 27)];
    footballAgeTextField.borderStyle = UITextBorderStyleRoundedRect;
    footballAgeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    footballAgeTextField.returnKeyType = UIReturnKeyDone;
    footballAgeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    footballAgeTextField.delegate = self;
    footballAgeTextField.font = font;
    footballAgeTextField.enabled = NO;
    footballAgeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [footballView addSubview:footballAgeTextField];
    
    //group3
    UIView *group3View = [[UIView alloc] initWithFrame:CGRectMake(10, 325, SCREEN_WIDTH - 20, 35 * 4)];
    group3View.tag = 100;
    group3View.backgroundColor = backColor;
    group3View.layer.cornerRadius = 8.f;
    [scrollView addSubview:group3View];
    
    //Position
    UIView *positionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, 35)];
    positionView.tag = 101;
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(positionViewClick:)];
    [positionView addGestureRecognizer:singleTap];
    [group3View addSubview:positionView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 80, 33)];
    label.text = [NSString stringWithFormat:@"%@ :",LANGUAGE(@"POSITION")];
    label.textAlignment = NSTextAlignmentRight;
    label.font = font;
    label.tag = 102;
    [positionView addSubview:label];
    
    positionText = [[UILabel alloc] initWithFrame:CGRectMake(90, 1, SCREEN_WIDTH - 155, 33)];
    positionText.font = font;
    positionText.numberOfLines = 0;
    positionText.lineBreakMode = NSLineBreakByClipping;
    positionText.tag = 103;
    positionText.textAlignment = NSTextAlignmentLeft;
    [positionView addSubview:positionText];
    
    arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 49, 8, 20, 18)];
    arrowImage.image = IMAGE(@"new_chall_player_num");
    arrowImage.tag = 104;
    [positionView addSubview:arrowImage];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(10, positionView.frame.size.height, SCREEN_WIDTH - 40, 0.5f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    dotView.tag = 105;
    [group3View addSubview:dotView];
    
    //City
    UIView *cityView = [[UIView alloc] initWithFrame:CGRectMake(0, 35, SCREEN_WIDTH - 20, 35)];
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cityViewClick:)];
    [cityView addGestureRecognizer:singleTap];
    cityView.tag = 110;
    [group3View addSubview:cityView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 80, 33)];
    label.text = [NSString stringWithFormat:@"%@ :",LANGUAGE(@"LIVING_CITY")];
    label.textAlignment = NSTextAlignmentRight;
    label.font = font;
    label.tag = 111;
    [cityView addSubview:label];
    
    cityText = [[UILabel alloc] initWithFrame:CGRectMake(90, 1, SCREEN_WIDTH - 140, 33)];
    cityText.font = font;
    cityText.tag = 112;
    cityText.text = DEFAULT_CITY_NAME;
    [cityView addSubview:cityText];
    
    arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 48, 8, 18, 18)];
    arrowImage.image = IMAGE(@"create_club_city");
    arrowImage.tag = 113;
    [cityView addSubview:arrowImage];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(10, 34, SCREEN_WIDTH - 40, 0.5f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    dotView.tag = 114;
    [cityView addSubview:dotView];
    
    //ActiveTime
    UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, SCREEN_WIDTH - 20, 35)];
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeViewClick:)];
    [timeView addGestureRecognizer:singleTap];
    timeView.tag = 120;
    [group3View addSubview:timeView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 80, 33)];
    label.text =LANGUAGE(@"active time");
    label.textAlignment = NSTextAlignmentRight;
    label.font = font;
    label.tag = 121;
    [timeView addSubview:label];
    
    timeText = [[UILabel alloc] initWithFrame:CGRectMake(90, 1, SCREEN_WIDTH - 155, 33)];
    timeText.font = font;
    timeText.tag = 122;
    [timeText setNumberOfLines:2];
    [timeText setLineBreakMode:NSLineBreakByClipping];
    [timeView addSubview:timeText];
    
    arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 48, 8, 18, 18)];
    arrowImage.image = IMAGE(@"create_club_play_day");
    arrowImage.tag = 123;
    [timeView addSubview:arrowImage];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(10, timeView.frame.origin.y + timeView.frame.size.height, SCREEN_WIDTH - 40, 0.5f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    dotView.tag = 124;
    [group3View addSubview:dotView];
    
    //area
    UIView *areaView = [[UIView alloc] initWithFrame:CGRectMake(0, 105, SCREEN_WIDTH - 20, 35)];
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(areaViewClick:)];
    [areaView addGestureRecognizer:singleTap];
    areaView.tag = 130;
    [group3View addSubview:areaView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 80, 33)];
    label.text = LANGUAGE(@"active zone");
    label.textAlignment = NSTextAlignmentRight;
    label.font = font;
    label.tag = 131;
    [areaView addSubview:label];
    
    areaText = [[UILabel alloc] initWithFrame:CGRectMake(90, 1, SCREEN_WIDTH - 155, 33)];
    areaText.font = font;
    areaText.tag = 132;
    areaText.numberOfLines = 0.f;
    areaText.lineBreakMode = NSLineBreakByCharWrapping;
    [areaView addSubview:areaText];
    
    arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 48, 8, 18, 18)];
    arrowImage.image = IMAGE(@"create_club_play_area");
    arrowImage.tag = 133;
    [areaView addSubview:arrowImage];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nPlayerID] forKey:@"USERPROFILE_PLAYERID"];
    [AlertManager WaitingWithMessage];
    [[HttpManager sharedInstance] getUserProfileWithDelegate:self];
    
    imageChanged = NO;
    
    inviteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    inviteButton.frame = CGRectMake(10, 520, SCREEN_WIDTH - 20, 35);
    inviteButton.tag = 140;
    [inviteButton setBackgroundColor:[UIColor ggaThemeColor]];
    [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (IOS_VERSION >= 7.0)
    {
        inviteButton.layer.cornerRadius = 17;
    }
    [inviteButton addTarget:self action:@selector(inviteButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [inviteButton setTitle:LANGUAGE(@"invite") forState:UIControlStateNormal];
    [scrollView addSubview:inviteButton];
    
    if (nPlayerID != UID && showButton)
        inviteButton.hidden = NO;
    else
        inviteButton.hidden = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    originalStr = birthdayText.text;
    [textField resignFirstResponder];
    [self cancelPressed];
    
    return YES;
}

#pragma UserDefine
- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

#pragma Events
- (void)playerIconClick:(UITapGestureRecognizer *)recognizer
{
    if (nPlayerID != UID)
        return;
    
    UIActionSheet *mNewActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil
                                                        cancelButtonTitle:LANGUAGE(@"cancel")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:LANGUAGE(@"Take Photo or Video"),
                                      LANGUAGE(@"Choose From Library"), nil];
    
    mNewActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    mNewActionSheet.delegate = self;
    [mNewActionSheet showInView:self.view];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"IMAGEPICKER" forKey:@"PLAYERDETAIL_ACTIONSHEET"];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma Events
- (void)sexViewClick:(UITapGestureRecognizer *)recognizer
{
    if (nPlayerID != UID)
        return;
    
    [self resignFirstAllControls];
    
    receivedHttp = NO;
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    SexSelectController *vc = [[SexSelectController alloc] init];
    vc.delegate = self;
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}

#pragma Events
NSString *originalStr;
- (void)birthdayViewClick:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    if (nPlayerID != UID)
        return;
    
    [self resignFirstAllControls];
    
    //Added By Boss.2015/05/06
    if (datepicker != nil) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSPosition getPLAYERDETAIL_POSITIONFromFormattedString:positionText.text] forKey:@"PLAYERDETAIL_POSITION"];
    [[NSUserDefaults standardUserDefaults] setObject:timeText.text forKey:@"WorkDays"];
    [[NSUserDefaults standardUserDefaults] setObject:areaText.text forKey:@"ACTIVE_ZONE"];

    receivedHttp = NO;
    
    originalStr = [[NSString alloc] init];
    originalStr = birthdayText.text;
    datepicker= [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 230)];
    datepicker.datePickerMode = UIDatePickerModeDate;
    datepicker.backgroundColor = [UIColor whiteColor];
    [datepicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
    datepicker.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:datepicker];
    toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35)];
    toolbar.backgroundColor = [UIColor blackColor];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: LANGUAGE(@"DONE") style: UIBarButtonItemStyleBordered target: self action: @selector(HidePicker:)];
    [doneButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:@"kiloji---B" size:14.0f],UITextAttributeFont,nil] forState:UIControlStateNormal];
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: LANGUAGE(@"cancel") style: UIBarButtonItemStyleBordered target: self action: @selector(cancelPressed)];
    [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:@"kiloji---B" size:14.0f],UITextAttributeFont,nil] forState:UIControlStateNormal];
    toolbar.items = [NSArray arrayWithObjects:cancelButton,flexibleSpace, doneButton, nil];
    [self.view addSubview: toolbar];
    [UIView animateWithDuration:0.5
                     animations:^{
                         datepicker.frame = CGRectMake(0, SCREEN_HEIGHT - 200, SCREEN_WIDTH, 230);
                         toolbar.frame = CGRectMake(0, SCREEN_HEIGHT - 205, SCREEN_WIDTH, 35);
                     } completion:^(BOOL finished) {
                     }];
}

-(IBAction)HidePicker:(id)sender{
    [[NSUserDefaults standardUserDefaults] setObject:[NSPosition getPLAYERDETAIL_POSITIONFromFormattedString:positionText.text] forKey:@"PLAYERDETAIL_POSITION"];
    [[NSUserDefaults standardUserDefaults] setObject:timeText.text forKey:@"WorkDays"];
    [[NSUserDefaults standardUserDefaults] setObject:areaText.text forKey:@"ACTIVE_ZONE"];

    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    [UIView animateWithDuration:0.5
                     animations:^{
                         datepicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 20);
                         toolbar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35);
                     } completion:^(BOOL finished) {
                         //NSLOG
                         birthdayText.text = [outputFormatter stringFromDate:datepicker.date];
                         [datepicker removeFromSuperview];
                         [toolbar removeFromSuperview];
                         datepicker = nil;
                         toolbar = nil;
                     }];
}

-(IBAction)cancelPressed
{
    birthdayText.text = originalStr;
    [UIView animateWithDuration:0.5
                     animations:^{
                         datepicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 20);
                         toolbar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35);
                     } completion:^(BOOL finished) {
                         [datepicker removeFromSuperview];
                         [toolbar removeFromSuperview];
                         datepicker = nil;
                         toolbar = nil;
                     }];
}

-(void)pickerChanged:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    birthdayText.text = [dateFormatter stringFromDate:[(UIDatePicker*)sender date]];
}

#pragma Events
- (void)positionViewClick:(UITapGestureRecognizer *)recognizer
{
    if (nPlayerID != UID)
        return;
    
    [self resignFirstAllControls];
    
    receivedHttp = NO;
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[PositionSelectController alloc] init] animated:YES];
}

#pragma Events
- (void)cityViewClick:(UITapGestureRecognizer *)recognizer
{
    if (nPlayerID != UID)
        return;
    
    [self resignFirstAllControls];
    
    receivedHttp = NO;
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    CitySelectController *vc = [[CitySelectController alloc] init];
    vc.delegate = self;
    vc.beforeSelected = cityText.text;
    [appDelegate.ggaNav pushViewController:vc animated:YES];

}

#pragma Events
- (void)timeViewClick:(UITapGestureRecognizer *)recognizer
{
    if (nPlayerID != UID)
        return;
    
    [self resignFirstAllControls];
    
    receivedHttp = NO;
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[WeekSelectController alloc] init] animated:YES];

}

#pragma Events
- (void)areaViewClick:(UITapGestureRecognizer *)recognizer
{
    if (nPlayerID != UID)
        return;
    
    [self resignFirstAllControls];
    
    receivedHttp = NO;
    
    int c  = NSNotFound;
    for (NSDictionary *item in CITYS)
    {
        if ([[item valueForKey:@"city"] isEqualToString:cityText.text])
            c = [[item valueForKey:@"id"] intValue];
    }
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [[NSUserDefaults standardUserDefaults] setObject:@"ACTIVE_ZONE" forKey:@"ZONE_SELECT_FOR_WHAT"];
    [appDelegate.ggaNav pushViewController:[[ZoneSelectController alloc] initWithCityIndex: c] animated:YES];
}

#pragma Events
- (void)changeButtonClick:(id)sender
{
    [self.view endEditing:YES];
    
    if (nameTextField.text == nil || [nameTextField.text isEqualToString:@""]) {
        [AlertManager AlertWithMessage:LANGUAGE(@"name is empty") tag:1100 delegate:self];
        return;
    }
    
    if (sexText.text == nil || [sexText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"sex is empty") tag:1101 delegate:self];
        return;
    }
    
    if (birthdayText.text == nil || [birthdayText.text isEqualToString:@""]){
        [AlertManager AlertWithMessage:LANGUAGE(@"birthday is empty") tag:1102 delegate:self];
        return;
    }
    
    if (heightTextField.text == nil || [heightTextField.text isEqualToString:@""] || [heightTextField.text isEqualToString:@"0"])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"height is empty") tag:1108 delegate:self];
        return;
    }
    
    if (weightTextField.text == nil || [weightTextField.text isEqualToString:@""] || [weightTextField.text isEqualToString:@"0"])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"weightTextField is empty") tag:1107 delegate:self];
        return;
    }
    
    if (footballAgeTextField.text == nil || [footballAgeTextField.text isEqualToString:@""]  || [footballAgeTextField.text isEqualToString:@"0"])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"footballage is empty") tag:1109 delegate:self];
        return;
    }
    
    if (positionText.text == nil || [positionText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"position is empty") tag:1103 delegate:self];
        return;
    }

    if (timeText.text == nil || [timeText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"time is empty") tag:1105 delegate:self];
        return;
    }

    if (cityText.text == nil || [cityText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"city is empty") tag:1104 delegate:self];
        return;
    }
    
    if (areaText.text == nil || [areaText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"area is empty") tag:1106 delegate:self];
        return;
    }

    
    NSString *nHeight = heightTextField.text;
    NSString *nWeight = weightTextField.text;
    NSString *nFootballAge = footballAgeTextField.text;
    
    if ([nHeight intValue] < 100 || [nHeight intValue] > 250)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"height is too long")];
        return;
    }
    
    if ([nWeight intValue] <= 0 || [nWeight intValue] > 999)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"weight is too much")];
        return;
    }
    
    if ([nFootballAge intValue] <= 0 || [nFootballAge intValue] > 99)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"footballAge is too old")];
        return;
    }
    

    
    if (!imageChanged)
        [self edituserProfileWithImageUrl:@""];
    else
    {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:playerIcon.image forKey:@"image"];
        
        [self loadImage:param];

    }
}

- (void)inviteButtonPressed:(id)butotn
{
    if (ADMINCLUBCOUNT == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
        return;
    }
    
    if (ADMINCLUBCOUNT == 1)
    {
        int nAdminClub = [[[ADMINCLUBS objectAtIndex:0] valueForKey:@"club_id"] intValue];
        [self multiTeamSelected:[NSArray arrayWithObjects:[NSNumber numberWithInt:nAdminClub], nil]];
        return;
    }
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[TeamSelectController alloc] initAdminMutliSelectModeWithDelegate:self] animated:YES];
}

- (void)edituserProfileWithImageUrl:(NSString *)imageUrl
{
    savedImageUrl = imageUrl;
    
    NSString *newName = nameTextField.text;
    
    if ([nameTextField.text isEqualToString:name])
        newName = @"";
    
    NSString *newphoto_url = imageUrl;
    
    NSString *newsex = [sexText.text isEqualToString:LANGUAGE(@"MALE")]? @"1": @"2";
    NSString *newbirthday = birthdayText.text;
    NSString *newHeight = heightTextField.text;
    NSString *newWeight = weightTextField.text;
    NSString *newAge = footballAgeTextField.text;
    NSString *newCity = @"";
    NSString *newPosition = [NSString stringWithFormat:@"%ld", [NSPosition intDetailWithStringPosition:[NSPosition
                        getPLAYERDETAIL_POSITIONFromFormattedString:positionText.text]]];
    NSString *newArea = @"";
    
    int cityTemp = 0;
    for (NSDictionary *item in CITYS) {
        if ([[item valueForKey:@"city"] isEqualToString:cityText.text])
            cityTemp = [[item valueForKey:@"id"] intValue];
    }
    
    newArea = [[DistrictManager sharedInstance] stringAreaIDsArrayOfAreas:areaText.text InCity:cityTemp];
    
    newCity = [NSString stringWithFormat:@"%d", cityTemp];
    
    
    NSString *newTime = [NSString stringWithFormat:@"%ld", [NSWeek intWithStringWeek:timeText.text]];
    
    NSArray *data = [NSArray arrayWithObjects:name,
                     newName, newphoto_url, newsex, newbirthday, newHeight, newWeight, newAge, newCity, newPosition, newArea, newTime, nil];
    
    [AlertManager WaitingWithMessage];
    [[HttpManager sharedInstance] editUserProfileWithDelegate:self data:data];
}

#pragma HttpManagerDelegate
- (void)getUserProfileResultWithErrorCode:(int)errorcode data:(PlayerListRecord *)record
{
    [AlertManager HideWaiting];
    receivedHttp = YES;
    
    if (errorcode > 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
        return;
    }
    
    name = nameTextField.text = [record stringWithPlayerName];
    phone = phoneText.text = [record stringWithPhone];
    sex =sexText.text = [record intWithSex] == 1? LANGUAGE(@"MALE"):LANGUAGE(@"FEMALE");
    birthday = birthdayText.text = [record stringWithBirthday];
    height = heightTextField.text = [NSString stringWithFormat:@"%d", [record valueWithHeight]];
    weight = weightTextField.text = [NSString stringWithFormat:@"%d", [record valueWithWeight]];
    age = footballAgeTextField.text = [NSString stringWithFormat:@"%d", [record valueWithFootballAge]];
   
    NSString *position = [NSPosition stringDetailWithIntegerPosition:[record intWithPosition]];
    pos = positionText.text = [NSPosition formattedStringFromPLAYERDETAIL_POSITION:position];
    
    city = cityText.text = [record stringWithCity];
    time = timeText.text = [NSWeek stringWithIntegerWeek:[record intWithWeek]];
    area = areaText.text = [[DistrictManager sharedInstance] stringAreaNamesArrayOfAreaIDs:[record stringWithArea] InCity:city];
        
    if (nPlayerID == UID) {
        changeButton.hidden = NO;
        weightTextField.enabled = YES;
        heightTextField.enabled = YES;
        footballAgeTextField.enabled =YES;
    }
    
    NSString *imageUrl = [record imageUrlWithPlayerImage];
    if (imageUrl && ![imageUrl isEqualToString:@""])
    {
        playerIcon.image = [CacheManager GetCacheImageWithURL:imageUrl];
        if (!playerIcon.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:imageUrl];
                     playerIcon.image = [image circleImageWithSize:playerIcon.frame.size.width];
                 }
                 else
                 {
                     playerIcon.image = [IMAGE(@"man_default") circleImageWithSize:playerIcon.frame.size.width];
                 }
                 return ;
             }
             ];
        }
        else
            playerIcon.image = [[CacheManager GetCacheImageWithURL:imageUrl] circleImageWithSize:playerIcon.frame.size.width];
    }
    else
        playerIcon.image = [IMAGE(@"man_default") circleImageWithSize:playerIcon.frame.size.width];

    [self reControlLabel];
}

#pragma HttpManagerDelegate
- (void)editUserProfileResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"update_playerdetail_success")];
        if (savedImageUrl != nil && ![savedImageUrl isEqualToString:@""])
            USERPHOTO = [NSString stringWithString:savedImageUrl];
    }
    
    [self.view endEditing:NO];
}

#pragma HttpManagerDelegate
- (void)sendInvRequestResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
    
}

#pragma SexSelectControllerDelegate
- (void)sexSelected:(int)index
{
    [Common BackToPage];
    sexText.text = index == 0? LANGUAGE(@"MALE"):LANGUAGE(@"FEMALE");
}


#pragma CitySelectControllerDelegate
- (void)selectedCityWithIndex:(int)index
{
    [Common BackToPage];
    cityText.text = [[CITYS objectAtIndex:index] valueForKey:@"city"];
}

#pragma mark Select Photo Functions
- (void) takeFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"cannot use camera")];
        return;
    }
    
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    cameraController.delegate = self;
    cameraController.allowsEditing = NO;
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraController.mediaTypes = [NSArray arrayWithObjects:
                                   (NSString *) kUTTypeImage,
                                   nil];
    
    [self.navigationController presentViewController:cameraController animated:YES completion:nil];
    
}

- (void) chooseFromLibrary
{
    
    UIImagePickerController *libraryController = [[UIImagePickerController alloc] init];
    libraryController.delegate = self;
    libraryController.allowsEditing = NO;
    libraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    libraryController.mediaTypes = [NSArray arrayWithObjects:
                                    (NSString *) kUTTypeImage,
                                    nil];
    
    [self.navigationController presentViewController:libraryController animated:YES completion:nil];
    
}

- (void)dismissImagePickerView:(UIImagePickerController *)picker
{
    //[photoFrameImageView setHidden:NO];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if ([type isEqualToString:(NSString *)kUTTypeImage])
    {
        
        UIImage *photoImage = picker.allowsEditing? [info objectForKey:UIImagePickerControllerEditedImage]:[info objectForKey:UIImagePickerControllerOriginalImage];
        if(photoImage == nil)
            return;
        
        playerIcon.image = [photoImage circleImageWithSize:playerIcon.frame.size.width];
        imageChanged = YES;
    }
}

- (void) loadImage:(NSMutableDictionary *)param
{
    if(param == nil)
        return;
    
    UIImage *image = [param objectForKey:@"image"];
    if(image == nil)
        return;

    image = [Utils rotateImage:image];
    if([self savePhoto:image] == NO)
        return;
    
    NSString *strUrl = [NSString stringWithFormat:FILE_UPLOAD_URL, SERVER_IP_ADDRESS, _PORT];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    ggaAppDelegate *appDelegate = (ggaAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.httpClientForUpload.delegate = self;
    HttpRequest *httpRequest = [[HttpRequest alloc] init];
    httpRequest.type = 1;
    httpRequest.addImg = savedFilePath;
    [httpRequest requestUploadContent : 0];
}



#pragma mark UIImagePickerControllerDelegate
- (BOOL) savePhoto:(UIImage *)image
{
    NSString *fileName = [Utils uuid];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *filePath = [FileManager GetImageFilePath:fileName];
    savedFilePath = filePath;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    
    if([imageData writeToFile:filePath atomically:YES] == NO)
        return NO;
    
    return YES;
}

- (void)requestSucceeded:(NSString *)data {
    
    NSDictionary *jsonValues = [data JSONValue];
    NSInteger success = [[jsonValues objectForKey:PARAM_KEY_SUCCESS] integerValue];
    NSString *img_name = [jsonValues objectForKey:PARAM_KEY_SERVER_FILE_PATH];
    
    if(success == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"image upload failed")];
        return;
    }
    
    [self edituserProfileWithImageUrl:img_name];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self takeFromCamera];
            break;
        case 1:
            [self chooseFromLibrary];
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag >= 1100 && alertView.tag < 1110)
    {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self.view endEditing:NO];
        [scrollView endEditing:NO];
    }
}


#pragma TeamSelectControllerDelegate
- (void)multiTeamSelected:(NSArray *)teams
{
    [AlertManager WaitingWithMessage];
    
    NSString *tmp = @"";
    for (int i = 0; i < teams.count; i ++) {
        if ([tmp isEqualToString:@""])
            tmp = [NSString stringWithFormat:@"%@", [teams objectAtIndex:i]];
        else
            tmp = [NSString stringWithFormat:@"%@,%@", tmp, [teams objectAtIndex:i]];
    }
        
    NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:nPlayerID],
                    tmp,
                    nil];
    [[HttpManager sharedInstance] sendInvRequestWithDelegate:self data:data];
}

@end
