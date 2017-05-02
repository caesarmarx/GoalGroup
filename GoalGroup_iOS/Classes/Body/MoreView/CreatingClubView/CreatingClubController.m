//
//  CreatingClubController.m
//  GoalGroup
//
//  Created by KCHN on 2/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "CreatingClubController.h"
#import "WeekSelectController.h"
#import "ZoneSelectController.h"
#import "DistrictManager.h"
#import "DateManager.h"
#import "Common.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Utils.h"
#import "JSON.h"

@interface CreatingClubController ()
{
    UIImagePickerController *thumbImagePicker;
    NSString *savedFilePath;
    NSArray *creatingData;
    BOOL keyboardVisible;
}

@end

@implementation CreatingClubController

+ (CreatingClubController *)sharedInstance
{
    @synchronized(self)
    {
        if (gCreatingClubController == nil) {
            gCreatingClubController = [[CreatingClubController alloc] init];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"WorkDays"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ACTIVE_ZONE"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STADIUM_ZONE"];

    return gCreatingClubController;
}

- (id)init
{
    self = [super init];
    if (self) {
        //[self layoutComponents];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self layoutComponents];
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    _activeDayLabels.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"WorkDays"];
    _establishDayText.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"ESTABLISH_DAY"];
    
    _establishDayText.text = (_establishDayText.text == nil || [_establishDayText.text compare:@""] == NSOrderedSame)?[DateManager StringDateWithFormat:@"YYYY-MM-dd" date:[NSDate date]] : _establishDayText.text;
    NSString *zoneStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACTIVE_ZONE"];
    _zoneText.text = zoneStr;
    

    NSString *stadiumAreaStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"STADIUM_ZONE"];
    _stadiumAreaText.text = stadiumAreaStr;
    
    for (NSDictionary *item in [[DistrictManager sharedInstance] districtsWithAllIndex]) {
        
        if ([stadiumAreaStr isEqualToString:[item objectForKey:@"district"]])
        {
            _stadiumAreaID = [[item objectForKey:@"id"] intValue];
        }
        
    }

    [self refreshControls];
    keyboardVisible = NO;
}
-(void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) keyboardDidShow: (NSNotification *)notif {
    // 키보드의 크기를 읽어옵니다.
    // NSNotification 객체는 userInfo 필드에 자세한 이벤트 정보를 담고 있습니다.
    NSDictionary* info = [notif userInfo];
    // 딕셔너리에서 키보드 크기를 얻어옵니다.
    //NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey]; // deprecated
    NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    NSValue* bValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize akeyboardSize = [aValue CGRectValue].size;
    CGSize bkeyboardSize = [bValue CGRectValue].size;
    
    
    // 이전에 키보드가 안보이는 상태였는지 확인합니다.
    if (keyboardVisible && (bkeyboardSize.height - akeyboardSize.height > 0))
    {
        CGRect viewFrame = _scrollView.frame;
        viewFrame.size.height -= (bkeyboardSize.height - akeyboardSize.height);
        
        _scrollView.frame = viewFrame;
        keyboardVisible = YES;
        return;
    }
    
    if (keyboardVisible) {
        return;
    }
    
    // 키보드의 크기만큼 스크롤 뷰의 크기를 줄입니다.
    CGRect viewFrame = _scrollView.frame;
    viewFrame.size.height -= akeyboardSize.height;
    
    _scrollView.frame = viewFrame;
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
    CGRect viewFrame = _scrollView.frame;
    viewFrame.size.height += keyboardSize.height;
    
    _scrollView.frame = viewFrame;
    keyboardVisible = NO;
}

- (void)layoutComponents
{
    self.title = LANGUAGE(@"general_menu_second");
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage:) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    
    UIView *createButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 38)];
    
    UIButton *createButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 25, 23)];
    [createButton setImage: [UIImage imageNamed:@"create_club_ico"] forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(createButtonPressed) forControlEvents:UIControlEventTouchDown];
    [createButtonRegion addSubview:createButton];
    createButton.showsTouchWhenHighlighted = YES; //Added By Boss.2015/05/06
    
    UIButton *lblButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 23, 25, 15)];
    [lblButton setTitle:LANGUAGE(@"lbl_make_challenge_save") forState:UIControlStateNormal];
    lblButton.titleLabel.textColor = [UIColor whiteColor];
    lblButton.titleLabel.font = FONT(12.f);
    [lblButton addTarget:self action:@selector(createButtonPressed) forControlEvents:UIControlEventTouchDown];
    [createButtonRegion addSubview:lblButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:createButtonRegion];
    
    if (IOS_VERSION >= 7.0)
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height - 70)];
    else
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height -90)];
    
    _scrollView.backgroundColor = [UIColor ggaGrayBackColor];
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 500);
    [self.view addSubview: _scrollView];
    
    NSUInteger gapHeight = 15;
    NSUInteger conHeight = 25;
    NSUInteger navHeight = 0; //self.navigationController.navigationBar.bounds.size.height;
    NSUInteger height = navHeight + gapHeight;
    NSUInteger labelWidth = 80;
    NSUInteger gapWidth = 20;
    NSUInteger fieldStart = + labelWidth + gapWidth;
    NSUInteger iconSize = conHeight;
    NSUInteger fieldWith = SCREEN_WIDTH - fieldStart - iconSize  - 30;
    
    thumbImagePicker = [[UIImagePickerController alloc] init];
    
    UIView *thumbView = [[UIView alloc] initWithFrame:CGRectMake(25, height, 50, 50)];
    [_scrollView addSubview:thumbView];
    
    UITapGestureRecognizer *singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbImagePicker:)];
    [thumbView addGestureRecognizer:singleFinterTap];
    
    _clubImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_clubImage setImage:IMAGE(@"club_default")];
    [thumbView addSubview:_clubImage];
    
    _nameTField = [[UITextField alloc] initWithFrame:CGRectMake(fieldStart, 27, fieldWith, conHeight)];
    _nameTField.borderStyle = UITextBorderStyleRoundedRect;
    _nameTField.autocorrectionType = UITextAutocorrectionTypeNo;
    _nameTField.placeholder = LANGUAGE(@"CLUB NAME");
    _nameTField.returnKeyType = UIReturnKeyDone;
    _nameTField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameTField.delegate = self;
    [_scrollView addSubview:_nameTField];
    
    height = height + 40 + gapHeight + gapHeight;
    NSUInteger itemHeight = (conHeight + gapHeight) * 2;
    
    UIView *itemBack = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight) * 2 + 8)];
    itemBack.layer.cornerRadius = 5;
    itemBack.layer.masksToBounds = YES;
    itemBack.backgroundColor = [UIColor ggaThemeGrayColor];
    LBorderView *dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2 + 5, itemBack.frame.size.width - 30, 0.3f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [itemBack addSubview:dotView];
    [_scrollView addSubview:itemBack];
    
    height += 8;
    UIFont *font = FONT(15.f);
    
    UIView *establishView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH, conHeight)];
    _establishDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, labelWidth, conHeight)];
    [_establishDayLabel setFont:font];
    [_establishDayLabel setTextAlignment:NSTextAlignmentRight];
    _establishDayLabel.text =LANGUAGE(@"establish date");
    [establishView addSubview:_establishDayLabel];
    
    _establishDayText = [[UILabel alloc] initWithFrame:CGRectMake(fieldStart - 10, 1, fieldWith, conHeight)];
    [_establishDayText setFont:font];
    [_establishDayText setTextAlignment:NSTextAlignmentLeft];
    [establishView addSubview:_establishDayText];
    UIImage *img = [UIImage imageNamed:@"create_club_date"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(fieldStart - 10 + fieldWith, 3, 20, 20)];
    [establishView addSubview:imgView];
    [_scrollView addSubview:establishView];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(establishDayClicked:)];
    [establishView addGestureRecognizer:singleFinterTap];
    
    height = height + itemHeight / 2;
    UIView *cityView = [[UIView alloc] initWithFrame:CGRectMake(10, height+ 3, SCREEN_WIDTH -  20, conHeight)];
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cityClick:)];
    [cityView addGestureRecognizer:singleFinterTap];
    _cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_cityLabel setFont:font];
    [_cityLabel setTextAlignment:NSTextAlignmentRight];
    _cityLabel.text =LANGUAGE(@"active city");
    [cityView addSubview:_cityLabel];
    
    _cityText = [[UILabel alloc] initWithFrame:CGRectMake(fieldStart - 10, 0, fieldWith, conHeight)];
    _cityText.font = FONT(14.f);
    _cityText.textAlignment = NSTextAlignmentLeft;
    _cityText.text = DEFAULT_CITY_NAME;
    _cityID = DEFAULT_CITY_ID;
    [cityView addSubview:_cityText];
    img = [UIImage imageNamed:@"create_club_city"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(fieldStart - 10 + fieldWith, 3, 20, 20)];
    [cityView addSubview:imgView];
    [_scrollView addSubview:cityView];
    
    
    height = height + itemHeight / 2 + gapHeight;
    itemBack = [[UIView alloc] init];
    itemBack.layer.cornerRadius = 5;
    itemBack.layer.masksToBounds = YES;
    itemBack.tag = 100;
    itemBack.backgroundColor = [UIColor ggaThemeGrayColor];
    itemBack.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight )* 2 + 8);
    [_scrollView addSubview:itemBack];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2 + 5, itemBack.frame.size.width - 30, 0.3f)];
    dotView.borderType = BorderTypeDashed;
    dotView.tag = 300;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [itemBack addSubview:dotView];
    height += 8;
    UIView *activeView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH - 30, conHeight)];
    _activeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, labelWidth, conHeight)];
    [_activeLabel setFont:FONT(14.f)];
    [_activeLabel setTextAlignment:NSTextAlignmentRight];
    _activeLabel.text =LANGUAGE(@"active time");
    [activeView addSubview:_activeLabel];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(activeDayPress:)];
    [activeView addGestureRecognizer:singleFinterTap];
    
    _activeDayLabels = [[UILabel alloc] initWithFrame:CGRectMake(fieldStart - 10, 1, fieldWith, conHeight)];
    [_activeDayLabels setFont:FONT(14.f)];
    [_activeDayLabels setTextAlignment:NSTextAlignmentLeft];
    [activeView addSubview:_activeDayLabels];
    img = [UIImage imageNamed:@"create_club_play_day"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(fieldStart - 10 + fieldWith, 4, 20, 20)];
    [activeView addSubview:imgView];
    [_scrollView addSubview:activeView];
    
    
    height = height + conHeight + gapHeight;
    
    UIView *zoneView = [[UIView alloc] initWithFrame:CGRectMake(10, height + 5, SCREEN_WIDTH - 30, conHeight)];
    zoneView.tag = 101;
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zonePress:)];
    [zoneView addGestureRecognizer:singleFinterTap];
    
    _zoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_zoneLabel setFont:FONT(14.f)];
    [_zoneLabel setTextAlignment:NSTextAlignmentRight];
    _zoneLabel.text = LANGUAGE(@"active zone");
    [zoneView addSubview:_zoneLabel];
    
    _zoneText = [[UILabel alloc] initWithFrame:CGRectMake(fieldStart - 10, 0, fieldWith, conHeight)];
    _zoneText.font = FONT(14.f);
    _zoneText.textAlignment = NSTextAlignmentLeft;
    _zoneText.tag = 102;
    _zoneText.lineBreakMode = NSLineBreakByClipping;
    [zoneView addSubview:_zoneText];
    img = [UIImage imageNamed:@"create_club_play_area"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(fieldStart - 10 + fieldWith, 3, 20, 20)];
    [zoneView addSubview:imgView];
    [_scrollView addSubview:zoneView];
    
    
    height = height + itemHeight / 2 + gapHeight;
    itemBack = [[UIView alloc] init];
    itemBack.layer.cornerRadius = 5;
    itemBack.layer.masksToBounds = YES;
    itemBack.backgroundColor = [UIColor ggaThemeGrayColor];
    itemBack.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight )* 2 + 8);
    itemBack.tag = 103;
    [_scrollView addSubview:itemBack];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2 + 2, itemBack.frame.size.width - 30, 0.3f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [itemBack addSubview:dotView];
    height += 8;
    UIView *stadiumView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH - 30, conHeight)];
    stadiumView.tag = 104;
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stadiumAreaPress:)];
    [stadiumView addGestureRecognizer:singleFinterTap];
    
    _stadiumAreaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_stadiumAreaLabel setFont:FONT(14.f)];
    [_stadiumAreaLabel setTextAlignment:NSTextAlignmentRight];
    _stadiumAreaLabel.text = LANGUAGE(@"main home zone");
    [stadiumView addSubview:_stadiumAreaLabel];
    
    _stadiumAreaText = [[UILabel alloc] initWithFrame:CGRectMake(fieldStart - 10, 0, fieldWith, conHeight)];
    _stadiumAreaText.font = FONT(14.f);
    _stadiumAreaText.textAlignment = NSTextAlignmentLeft;
    [stadiumView addSubview:_stadiumAreaText];
    img = [UIImage imageNamed:@"create_club_stadium"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(fieldStart - 10 + fieldWith, 3, 20, 20)];
    [stadiumView addSubview:imgView];
    [_scrollView addSubview:stadiumView];
    

    height = height + conHeight + gapHeight;
    
    _stadiumAddrLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height + 5, labelWidth, conHeight)];
    [_stadiumAddrLabel setFont:FONT(14.f)];
    [_stadiumAddrLabel setTextAlignment:NSTextAlignmentRight];
    _stadiumAddrLabel.text = LANGUAGE(@"stadiumAddr");
    _stadiumAddrLabel.tag = 105;
    [_scrollView addSubview:_stadiumAddrLabel];
    
    _stadiumAddrText = [[UITextView alloc] initWithFrame:CGRectMake(fieldStart, height + 2, fieldWith + 30, 29.f)];
    _stadiumAddrText.layer.cornerRadius = 6;
    _stadiumAddrText.autocorrectionType = UITextAutocorrectionTypeNo;
    _stadiumAddrText.returnKeyType = UIReturnKeyDone;
    _stadiumAddrText.font = FONT(14.f);
    _stadiumAddrText.delegate = self;
    _stadiumAddrText.layer.borderColor = [UIColor ggaGrayBorderColor].CGColor;
    _stadiumAddrText.layer.borderWidth = 0.3f;
    _stadiumAddrText.tag = 106;
    [_scrollView addSubview:_stadiumAddrText];

    height = height + itemHeight / 2 + gapHeight;
    itemBack = [[UIView alloc] init];
    itemBack.layer.cornerRadius = 5;
    itemBack.layer.masksToBounds = YES;
    itemBack.tag = 107;
    itemBack.backgroundColor = [UIColor ggaThemeGrayColor];
    itemBack.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight )* 2 + 8);
    [_scrollView addSubview:itemBack];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2 + 5, itemBack.frame.size.width - 30, 0.3f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    dotView.tag = 200;
    [itemBack addSubview:dotView];
    height += 8;
     _sponsorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height + 2, labelWidth, conHeight)];
     [_sponsorLabel setFont:FONT(14.f)];
     [_sponsorLabel setTextAlignment:NSTextAlignmentRight];
     _sponsorLabel.text = LANGUAGE(@"sponsor");
    _sponsorLabel.tag = 108;
     [_scrollView addSubview:_sponsorLabel];
    
    _sponsorField = [[UITextView alloc] initWithFrame:CGRectMake(fieldStart, height, fieldWith + 30, 29.f)];
    _sponsorField.layer.cornerRadius = 6;
    _sponsorField.autocorrectionType = UITextAutocorrectionTypeNo;
    _sponsorField.font = FONT(14.f);
    _sponsorField.delegate = self;
    _sponsorField.layer.borderColor = [UIColor ggaGrayBorderColor].CGColor;
    _sponsorField.layer.borderWidth = 0.3f;
    _sponsorField.tag = 109;
    [_scrollView addSubview:_sponsorField];
    
    height = height + conHeight + gapHeight;
    _noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height + 6, labelWidth, conHeight)];
    [_noteLabel setFont:FONT(14.f)];
    [_noteLabel setTextAlignment:NSTextAlignmentRight];
    _noteLabel.text = LANGUAGE(@"introduce");
    _noteLabel.tag = 110;
    [_scrollView addSubview:_noteLabel];
    
    _noteField = [[UITextView alloc] initWithFrame:CGRectMake(fieldStart, height + 3, fieldWith + 30, 29.f)];
    _noteField.layer.cornerRadius = 6.f;
    _noteField.autocorrectionType = UITextAutocorrectionTypeNo;
    _noteField.font = FONT(14.f);
    _noteField.delegate = self;
    _noteField.layer.borderColor = [UIColor ggaGrayBorderColor].CGColor;
    _noteField.layer.borderWidth = 0.3f;
    _noteField.tag = 111;
    [_scrollView addSubview:_noteField];
    viewHeight = SCREEN_HEIGHT;
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(padClick:)];
    [self.scrollView addGestureRecognizer:singleFinterTap];
}
- (void)refreshControls
{
    CGRect frame, frameDay;
    CGFloat itemWidth = _zoneText.frame.size.width - 10;
    
    CGSize strSize = [_zoneText.text sizeWithFont:FONT(14.f)];
    NSInteger nCount = round(strSize.width/ itemWidth+ 0.5);
    
    if (strSize.width > itemWidth) {
        frame = _zoneText.frame;
        frame.size.height = nCount * strSize.height + strSize.height - 10;
        NSInteger itemDiff = frame.size.height - _zoneText.frame.size.height;
        _zoneText.frame = frame;
        _zoneText.numberOfLines = nCount;
        for (int i = 100; i < 112; i ++) {
            if ( i == 102) continue;
            
            if ( i < 102 )
            {
                UIView *viewTag = [_scrollView viewWithTag:i];
                frame = viewTag.frame;
                frame.size.height = frame.size.height + itemDiff;
                viewTag.frame = frame;
                continue;
            }
            
            UIView *viewTag = [_scrollView viewWithTag:i];
            frame = viewTag.frame;
            frame.origin.y = frame.origin.y + itemDiff;
            viewTag.frame = frame;
        }
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height + itemDiff);
    } else {
        frame = _zoneText.frame;
        frame.size.height = 25;
        NSInteger itemDiff = frame.size.height - _zoneText.frame.size.height;
        _zoneText.frame = frame;
        
        for (int i = 100; i < 112; i ++) {
            if ( i == 102) continue;
            
            if ( i < 102 )
            {
                UIView *viewTag = [_scrollView viewWithTag:i];
                frame = viewTag.frame;
                frame.size.height = frame.size.height + itemDiff;
                viewTag.frame = frame;
                continue;
            }
            
            UIView *viewTag = [_scrollView viewWithTag:i];
            frame = viewTag.frame;
            frame.origin.y = frame.origin.y + itemDiff;
            viewTag.frame = frame;
        }
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height + itemDiff);
    }
    
    itemWidth = _activeDayLabels.frame.size.width;
    strSize = [_activeDayLabels.text sizeWithFont:FONT(14.f)];
    nCount = round(strSize.width/ itemWidth+ 0.5);
    
    if (strSize.width > itemWidth) {
        frameDay = _activeDayLabels.frame;
        frameDay.size.height = nCount * strSize.height + strSize.height - 15;
        NSInteger itemDiff = frameDay.size.height - _activeDayLabels.frame.size.height;
        _activeDayLabels.frame = frameDay;
        _activeDayLabels.numberOfLines = nCount;
        for (int i = 100; i < 112; i ++) {
            if ( i == 100 )
            {
                UIView *viewTag = [_scrollView viewWithTag:i];
                frameDay = viewTag.frame;
                frameDay.size.height = frameDay.size.height + itemDiff;
                viewTag.frame = frameDay;
                
                UIView *dotView = [viewTag viewWithTag:300];
                frameDay = dotView.frame;
                frameDay.origin.y += itemDiff;
                dotView.frame = frameDay;
                continue;
            }
            if (i == 102) {
                continue;
            }
            UIView *viewTag = [_scrollView viewWithTag:i];
            frameDay = viewTag.frame;
            frameDay.origin.y = frameDay.origin.y + itemDiff;
            viewTag.frame = frameDay;
        }
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height + itemDiff);
    } else {
        frameDay = _activeDayLabels.frame;
        frameDay.size.height = 25;
        NSInteger itemDiff = frameDay.size.height - _activeDayLabels.frame.size.height;
        _activeDayLabels.frame = frameDay;
        
        for (int i = 100; i < 112; i ++) {
            if ( i == 100 )
            {
                UIView *viewTag = [_scrollView viewWithTag:i];
                frameDay = viewTag.frame;
                frameDay.size.height = frameDay.size.height + itemDiff;
                viewTag.frame = frameDay;
                
                UIView *dotView = [viewTag viewWithTag:300];
                frameDay = dotView.frame;
                frameDay.origin.y += itemDiff;
                dotView.frame = frameDay;
                continue;
            }
            if (i == 102) {
                continue;
            }
            UIView *viewTag = [_scrollView viewWithTag:i];
            frameDay = viewTag.frame;
            frameDay.origin.y = frameDay.origin.y + itemDiff;
            viewTag.frame = frameDay;
        }
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height + itemDiff);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma Events:TextView
- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshHeight:textView];
}
- (void)refreshHeight:(UITextView*)textView
{
    //size of content, so we can set the frame of self
    NSInteger newSizeH = [self measureHeight:textView];
    CGRect frame;
    if (newSizeH != textView.frame.size.height) {
        NSInteger itemDiff = newSizeH - textView.frame.size.height;
        
        if (textView == _stadiumAddrText) {
            for (int i = 103; i < 112; i ++) {
                if ( i == 103 )
                {
                    UIView *viewTag = [_scrollView viewWithTag:i];
                    frame = viewTag.frame;
                    frame.size.height = frame.size.height + itemDiff;
                    viewTag.frame = frame;
                    continue;
                }
                if (i < 107) {
                    continue;
                }
                UIView *viewTag = [_scrollView viewWithTag:i];
                frame = viewTag.frame;
                frame.origin.y = frame.origin.y + itemDiff;
                viewTag.frame = frame;
            }
        } else if (textView == _sponsorField) {
            for (int i = 107; i < 112; i ++) {
                if ( i == 107 )
                {
                    UIView *viewTag = [_scrollView viewWithTag:i];
                    frame = viewTag.frame;
                    frame.size.height = frame.size.height + itemDiff;
                    viewTag.frame = frame;
                    
                    UIView *dotViewTag = [viewTag viewWithTag:200];
                    frame = dotViewTag.frame;
                    frame.origin.y = frame.origin.y + itemDiff;
                    dotViewTag.frame = frame;
                    continue;
                }
                if (i < 110) {
                    continue;
                }
                UIView *viewTag = [_scrollView viewWithTag:i];
                frame = viewTag.frame;
                frame.origin.y = frame.origin.y + itemDiff;
                viewTag.frame = frame;
            }
        } else if (textView == _noteField) {
            UIView *viewTag = [_scrollView viewWithTag:107];
            frame = viewTag.frame;
            frame.size.height = frame.size.height + itemDiff;
            viewTag.frame = frame;
        }
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height + itemDiff);
    }
    textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, newSizeH);
}

// Code from apple developer forum - @Steve Krulewitz, @Mark Marszal, @Eric Silverberg
- (CGFloat)measureHeight:(id)sender
{
    UITextView *textView = (UITextView*)sender;
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    }
    else {
        return textView.contentSize.height;
    }
}

#pragma Events
- (void)backToPage:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"WorkDays"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ACTIVE_ZONE"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STADIUM_ZONE"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ZONE_SELECT_FOR_WHAT"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ESTABLISH_DAY"];
    ggaAppDelegate *app = APP_DELEGATE;
    [app.ggaNav popViewControllerAnimated:YES];
}

#pragma Events
NSString *originalStr;
- (void)establishDayClicked:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    //Added By Boss.2015/05/06
    if (_datepicker != nil) {
        return;
    }
    originalStr = [[NSString alloc] init];
    originalStr = _establishDayText.text;
    
    _datepicker= [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 250)];
    _datepicker.datePickerMode = UIDatePickerModeDate;
    _datepicker.backgroundColor = [UIColor whiteColor];
    [_datepicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
    
    if (originalStr != nil && [originalStr compare:@""] != NSOrderedSame) {
        NSDateFormatter *outformat = [[NSDateFormatter alloc] init];
        [outformat setDateFormat:@"YYYY-MM-dd"];
        NSDate *date = [outformat dateFromString:originalStr];
        [_datepicker setDate:date];
    }
    
    _datepicker.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_datepicker];
    
    _toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35)];
    _toolbar.backgroundColor = [UIColor blackColor];
    _toolbar.barStyle = UIBarStyleBlackOpaque;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: LANGUAGE(@"DONE") style: UIBarButtonItemStyleBordered target: self action: @selector(HidePicker:)];
    [doneButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:@"kiloji---B" size:14.0f],UITextAttributeFont,nil] forState:UIControlStateNormal];
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: LANGUAGE(@"cancel") style: UIBarButtonItemStyleBordered target: self action: @selector(cancelPressed)];
    [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,[UIFont fontWithName:@"kiloji---B" size:14.0f],UITextAttributeFont,nil] forState:UIControlStateNormal];
    _toolbar.items = [NSArray arrayWithObjects:cancelButton,flexibleSpace, doneButton, nil];
    [self.view addSubview: _toolbar];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _datepicker.frame = CGRectMake(0, SCREEN_HEIGHT - 250, SCREEN_WIDTH, 250);
                         _toolbar.frame = CGRectMake(0, SCREEN_HEIGHT - 255, SCREEN_WIDTH, 35);
                     } completion:^(BOOL finished) {
                     }];
}

- (void)cityClick:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    [self cancelPressed];
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    CitySelectController *vc = [[CitySelectController alloc] init];
    vc.delegate = self;
    vc.beforeSelected = _cityText.text;
    [appDelegate.ggaNav pushViewController:vc animated:YES];
    
}

- (void)activeDayPress:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    originalStr = _establishDayText.text;
    [self cancelPressed];
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[WeekSelectController  sharedInstance] animated:YES];
}

- (void)zonePress:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    
    originalStr = _establishDayText.text;
    [self cancelPressed];
    if (_cityText.text == nil || [_cityText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"city is not selected")];
        return;
    }
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [[NSUserDefaults standardUserDefaults] setObject:@"ACTIVE_ZONE" forKey:@"ZONE_SELECT_FOR_WHAT"];
    [appDelegate.ggaNav pushViewController:[[ZoneSelectController alloc] initWithCityIndex:_cityID] animated:YES];
}

- (void)stadiumAreaPress:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    originalStr = _establishDayText.text;
    [self cancelPressed];
    if (_cityText.text == nil || [_cityText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"city is not selected")];
        return;
    }

    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [[NSUserDefaults standardUserDefaults] setObject:@"STADIUM_ZONE" forKey:@"ZONE_SELECT_FOR_WHAT"];
    [appDelegate.ggaNav pushViewController:[[ZoneSelectController alloc] initWithCityIndex:_cityID] animated:YES];
}

- (void)padClick:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    originalStr = _establishDayText.text;
    [self cancelPressed];
}

- (void)thumbImagePicker:(UITapGestureRecognizer *)recognizer
{
    UIActionSheet *mNewActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil
                                                        cancelButtonTitle:LANGUAGE(@"cancel")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:LANGUAGE(@"Take Photo or Video"),
                                      LANGUAGE(@"Choose From Library"), nil];
    
    mNewActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    mNewActionSheet.delegate = self;
    [mNewActionSheet showInView:self.view];
    [[NSUserDefaults standardUserDefaults] setObject:@"IMAGEPICKER" forKey:@"CREATINGCLUB_ACTIONSHEET"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma Events
- (void)createButtonPressed
{
    [self.view endEditing:YES];
    originalStr = _establishDayText.text;
    [self cancelPressed];
    _nameStr = _nameTField.text;
    _establishDayStr = _establishDayText.text;
    _sponsorStr = _sponsorField.text;
    _noteStr = _noteField.text;
    _activeTimeStr = _activeDayLabels.text;
    _stadiumAddrStr = _stadiumAddrText.text;
    
    if (_sponsorStr == nil) _sponsorStr = @"";
    if (_noteStr == nil) _noteStr = @"";
    
    
    if (_nameStr == nil || [_nameStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0){
        [AlertManager AlertWithMessage:LANGUAGE(@"create club name invalid")];
        return;
    }
    if (_establishDayStr == nil || [_establishDayStr isEqualToString:@""]){
        [AlertManager AlertWithMessage:LANGUAGE(@"create club day invalid")];
        return;
    }
    if (_cityText.text == nil || [_cityText.text isEqualToString:@""]){
        [AlertManager AlertWithMessage:LANGUAGE(@"create club city invalid")];
        return;
    }
    if (_activeTimeStr == nil || [_activeTimeStr isEqualToString:@""]){
        [AlertManager AlertWithMessage:LANGUAGE(@"create club activeTime invalid")];
        return;
    }
    if (_stadiumAreaText.text == nil || [_stadiumAreaText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"create club stadiumArea invalid")];
        return;
    }
    if (_zoneText.text == nil || [_zoneText.text isEqualToString:@""]){
        [AlertManager AlertWithMessage:LANGUAGE(@"create club zone invalid")];
        return;
    }
    if (_stadiumAddrStr == nil || [_stadiumAddrStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"create club stadiumAddr invalid")];
        return;
    }
    if (_sponsorStr.length > 100)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"sponsor is not more than 10 char")];
        return;
    }
    
    _zoneIDs = [[DistrictManager sharedInstance] stringAreaIDsArrayOfAreas:_zoneText.text InCity:-1];
    
    if ([_clubImage.image isEqual:IMAGE(@"club_default")])
    {
        [AlertManager WaitingWithMessage];
        creatingData = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", UID],
                        @"",
                        _nameStr,
                        @"",
                        [NSString stringWithFormat:@"%ld", _cityID],
                        @"0",
                        _sponsorStr,
                        _noteStr,
                        [NSString stringWithFormat:@"%ld", [NSWeek intWithStringWeek:_activeTimeStr]],
                        [NSString stringWithFormat:@"%@", _zoneIDs],
                        [NSString stringWithFormat:@"%ld", _stadiumAreaID],
                        _stadiumAddrStr,
                        _establishDayStr,
                        @"0",
                        nil];
        
        [[HttpManager sharedInstance] createClubWithDelegate:self data:creatingData];
    }
    else
    {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:_clubImage.image forKey:@"image"];
        [AlertManager WaitingWithMessage];
        [self loadImage:param];
    }

}

#pragma Events
-(IBAction)HidePicker:(id)sender{
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _datepicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 20);
                         _toolbar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35);
                     } completion:^(BOOL finished) {
                         //NSLOG
                         _establishDayText.text = [outputFormatter stringFromDate:self.datepicker.date];
                         [[NSUserDefaults standardUserDefaults] setObject:_establishDayText.text forKey:@"ESTABLISH_DAY"];
                         [_datepicker removeFromSuperview];
                         [_toolbar removeFromSuperview];
                         _datepicker = nil;
                         _toolbar = nil;
                     }];
    }

-(IBAction)cancelPressed
{
    _establishDayText.text = originalStr;
    [UIView animateWithDuration:0.5
                     animations:^{
                         _datepicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 20);
                         _toolbar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35);
                     } completion:^(BOOL finished) {
                         [_datepicker removeFromSuperview];
                         [_toolbar removeFromSuperview];
                         _datepicker = nil;
                         _toolbar = nil;
                     }];
        }

-(void)pickerChanged:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    _establishDayText.text = [dateFormatter stringFromDate:[(UIDatePicker*)sender date]];
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
    [self presentViewController:libraryController animated:YES completion:nil];
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
        
        _clubImage.image = [photoImage circleImageWithSize:_clubImage.frame.size.width];
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
    
    NSString *strUrl = [NSString stringWithFormat:FILE_UPLOAD_URL,SERVER_IP_ADDRESS, _PORT];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSLog(@"imageUpload_URL: %@", url);
    
    ggaAppDelegate *appDelegate = (ggaAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.httpClientForUpload.delegate = self;
    HttpRequest *httpRequest = [[HttpRequest alloc] init];
    httpRequest.type = 1;
    httpRequest.addImg = savedFilePath;
    [httpRequest requestUploadContent:0];
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

- (void)requestSucceeded:(NSString *)data
{
#ifdef DEMO_MODE
    NSLog(@"requestSucceeded: %@", data);
#endif
    
    NSDictionary *jsonValues = [data JSONValue];
    NSInteger success = [[jsonValues objectForKey:PARAM_KEY_SUCCESS] integerValue];
    NSString *img_name = [jsonValues objectForKey:PARAM_KEY_SERVER_FILE_PATH];
    
    if(success == 0)
    {
        [AlertManager HideWaiting];
        [AlertManager AlertWithMessage:LANGUAGE(@"image upload failed")];
        return;
    }
    
    creatingData = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", UID],
                    @"",
                    _nameStr,
                    img_name,
                    [NSString stringWithFormat:@"%d", _cityID],
                    @"0",
                    _sponsorStr,
                    _noteStr,
                    [NSString stringWithFormat:@"%d", [NSWeek intWithStringWeek:_activeTimeStr]],
                    [NSString stringWithFormat:@"%@", _zoneIDs],
                    [NSString stringWithFormat:@"%d", _stadiumAreaID],
                    _stadiumAddrStr,
                    _establishDayStr,
                    @"0",
                    nil];

    [[HttpManager sharedInstance] createClubWithDelegate:self data:creatingData];
}


#pragma StadiumSelectControllerDelegate
- (void)selectedStadiumWithIndex:(int)index
{
    [self.view endEditing:YES];
    [Common BackToPage];
    _stadiumAreaID = [[[STADIUMS objectAtIndex:index] valueForKey:@"stadium_id"] intValue];
}

#pragma CitySelectControllerDelegate
- (void)selectedCityWithIndex:(int)index
{
    [Common BackToPage];
    _cityText.text = [[CITYS objectAtIndex:index] objectForKey:@"city"];
    _cityID = [[[CITYS objectAtIndex:index] valueForKey:@"id"] intValue];
}

#pragma HttpManagerDelegate
- (void)createClubResultWithErrorCode:(int)error_code data:(NSDictionary *)club
{
    [AlertManager HideWaiting];
    
    if (error_code > 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:error_code])];
    }
    else
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"create_club_success") tag:1001 delegate:self];
        [[ClubManager sharedInstance] addAdminClub:club];
        [[ClubManager sharedInstance] addClubs:club];
    }
    
}



#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
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

#pragma UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        ggaAppDelegate *appDelegate = APP_DELEGATE;
        [appDelegate selectedIndex:2];
        [Common BackToPage];
    }
}

@end
