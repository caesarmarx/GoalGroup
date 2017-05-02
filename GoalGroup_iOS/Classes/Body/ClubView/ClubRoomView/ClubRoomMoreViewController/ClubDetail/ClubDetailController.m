//
//  ClubDetailController.m
//  GoalGroup
//
//  Created by KCHN on 2/12/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubDetailController.h"
#import "WeekSelectController.h"
#import "ClubMemberController.h"
#import "ClubMarksDetailController.h"
#import "DiscussRoomManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Common.h"
#import "Utils.h"
#import "HttpRequest.h"
#import "JSON.h"

@interface ClubDetailController ()
{
    NSInteger height;
    UIButton *changeButton;
    UIButton *joinButton;
    UIButton *breakButton;
    UIView *changeButtonRegion;
    UIScrollView *scrollView;
    BOOL imageChanged;
    NSString *savedFilePath;
    BOOL keyboardVisible;
}
@end


@implementation ClubDetailController

+ (ClubDetailController *)sharedInstance
{
    @synchronized(self)
    {
        if (gClubDetailController == nil)
            gClubDetailController = [[ClubDetailController alloc] init];
    }
    return gClubDetailController;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self layoutComponents];
        
        NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:UID],
                          [NSNumber numberWithInt:nClubID],
                          nil];
        [[HttpManager sharedInstance] browseClubDataWithDelegate:self data:array];
        [AlertManager WaitingWithMessage];

    }
    return self;
}

- (id)initWithClub:(int)club fromClubCenter:(BOOL)center
{
    nClubID = club;
    fromClubCenter = center;

    self = [super init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor ggaGrayBackColor];

#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

-(void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    _activeTimeText.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"WorkDays"];
    
    NSString *zoneStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACTIVE_ZONE"];
    _zoneText.text = zoneStr;

    NSString *stadiumAreaStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"STADIUM_ZONE"];
    _stadiumAreaText.text = stadiumAreaStr;
    for (NSDictionary *item in [[DistrictManager sharedInstance] districtsWithCityIndex:cityID])
    {
        if ([stadiumAreaStr isEqual:[item objectForKey:@"district"]])
            stadiumAreaID = [[item objectForKey:@"id"] intValue];
    }
    
    keyboardVisible = NO;
    [self refreshControls];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma Users
- (void)layoutComponents
{
    self.title = LANGUAGE(@"club_menu_second");
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    
    changeButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 35)];
    changeButton = [[UIButton alloc] initWithFrame:CGRectMake(11, 0, 23, 20)];
    [changeButton setImage: [UIImage imageNamed:@"edit_ico"] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [changeButtonRegion addSubview:changeButton];
    
    UIButton *lblButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 25, 15)];
    [lblButton setTitle:LANGUAGE(@"lbl_club_detail_save") forState:UIControlStateNormal];
    lblButton.titleLabel.textColor = [UIColor whiteColor];
    lblButton.titleLabel.font = FONT(12.f);
    [lblButton addTarget:self action:@selector(changeButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [changeButtonRegion addSubview:lblButton];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height - 50)];
    
    scrollView.backgroundColor = [UIColor ggaGrayBackColor];
    [self.view addSubview:scrollView];
    
    NSUInteger gapHeight = 15;
    NSUInteger conHeight = 25;
    height = gapHeight;
    NSUInteger labelWidth = 80;
    NSUInteger gapWidth = 10;
    NSUInteger secondStart = 10 + labelWidth + gapWidth;
    NSUInteger iconSize = conHeight;
    NSUInteger secondWidth = SCREEN_WIDTH - secondStart - 30 - iconSize;
    
    _clubImage = [[UIImageView alloc] initWithFrame:CGRectMake(25, height, 50, 50)];
    [_clubImage setImage:IMAGE(@"club_default")];
    _clubImage.userInteractionEnabled = NO;
    [scrollView addSubview:_clubImage];
    
    UITapGestureRecognizer *imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbImagePicker:)];
    [_clubImage addGestureRecognizer:imageTapRecognizer];
    
    _clubNameField = [[UITextField alloc] initWithFrame:CGRectMake(secondStart, height + 14, secondWidth, 20)];
    [_clubNameField setFont:FONT(16.f)];
    [_clubNameField setTextAlignment:NSTextAlignmentLeft];
    _clubNameField.text = LANGUAGE(@"club1");
    _clubNameField.borderStyle = UITextBorderStyleRoundedRect;
    _clubNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    _clubNameField.placeholder = LANGUAGE(@"CLUB NAME");
    _clubNameField.returnKeyType = UIReturnKeyDone;
    _clubNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _clubNameField.delegate = self;
    _clubNameField.enabled = [[ClubManager sharedInstance] checkAdminClub:nClubID];

    [scrollView addSubview:_clubNameField];
    
    _activeLabel = [[UILabel alloc] initWithFrame:CGRectMake(secondStart + 140, height + 40, 100, 12)];
    [_activeLabel setFont:FONT(12.f)];
    [_activeLabel setTextAlignment:NSTextAlignmentLeft];
    _activeLabel.text = LANGUAGE(@"action rate");
    _activeLabel.hidden = [[ClubManager sharedInstance] checkAdminClub:nClubID];
    [scrollView addSubview:_activeLabel];
    
    height = height + conHeight;
    height = height + gapHeight + conHeight;
    NSUInteger itemHeight = (conHeight + gapHeight) * 2;
    
    UIView *itemBack = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight) * 2)];
    itemBack.layer.cornerRadius = 5;
    itemBack.layer.masksToBounds = YES;
    itemBack.backgroundColor = [UIColor ggaThemeGrayColor];
    
    LBorderView *dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2, itemBack.frame.size.width - 30, 0.3f)];
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [itemBack addSubview:dotView];
    [scrollView addSubview:itemBack];
    height += 7;
    
    UIView *establishView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH, conHeight)];
    _establishLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_establishLabel setFont:FONT(14.f)];
    [_establishLabel setTextAlignment:NSTextAlignmentRight];
    _establishLabel.text = LANGUAGE(@"establish date");
    [establishView addSubview:_establishLabel];
    
    _establishText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart - 10, 0, secondWidth, conHeight)];
    [_establishText setFont:FONT(14.f)];
    [_establishText setTextAlignment:NSTextAlignmentLeft];
    [establishView addSubview:_establishText];
    UIImage *img = [UIImage imageNamed:@"create_club_date"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(secondStart - 10 + secondWidth, 3, 20, 20)];
    [establishView addSubview:imgView];
    [scrollView addSubview:establishView];
    
    UITapGestureRecognizer *singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(establishDayClick:)];
    [establishView addGestureRecognizer:singleFinterTap];
    
    height = height + conHeight + gapHeight;
    
    UIView *cityView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH - 20, conHeight)];
    [scrollView addSubview:cityView];
    
    _cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, labelWidth, conHeight)];
    [_cityLabel setFont:FONT(14.f)];
    [_cityLabel setTextAlignment:NSTextAlignmentRight];
    _cityLabel.text = LANGUAGE(@"active city");
    [scrollView addSubview:_cityLabel];
    
    _cityText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart, height, secondWidth, conHeight)];
    _cityText.font = FONT(14.f);
    _cityText.textAlignment = NSTextAlignmentLeft;
    img = [UIImage imageNamed:@"create_club_city"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(secondStart - 10 + secondWidth, 3, 20, 20)];
    [cityView addSubview:imgView];
    [scrollView addSubview:_cityText];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clubDetailCityClick:)];
    [cityView addGestureRecognizer:singleFinterTap];
    
    height = height + itemHeight / 2 + gapHeight - 7;
    
    itemBack = [[UIView alloc] init];
    itemBack.tag = 100;
    itemBack.layer.cornerRadius = 5;
    itemBack.layer.masksToBounds = YES;
    itemBack.backgroundColor = [UIColor ggaThemeGrayColor];
    itemBack.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, itemHeight);
    [scrollView addSubview:itemBack];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2, itemBack.frame.size.width - 30, 0.3f)];
    dotView.tag = 200;
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [itemBack addSubview:dotView];
    height += 7;
    
    UIView *activeTimeView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH, conHeight)];
    activeTimeView.tag = 101;
    _activeTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_activeTimeLabel setFont:FONT(14.f)];
    [_activeTimeLabel setTextAlignment:NSTextAlignmentRight];
    _activeTimeLabel.text = LANGUAGE(@"active time");
    [activeTimeView addSubview:_activeTimeLabel];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(activeTimePress:)];
    [activeTimeView addGestureRecognizer:singleFinterTap];
    
    _activeTimeText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart - 10, 0, secondWidth, conHeight)];
    _activeTimeText.lineBreakMode = NSLineBreakByClipping;
    [_activeTimeText setFont:FONT(14.f)];
    [_activeTimeText setTextAlignment:NSTextAlignmentLeft];
    [activeTimeView addSubview:_activeTimeText];
    img = [UIImage imageNamed:@"create_club_play_day"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(secondStart - 10 + secondWidth, 4, 20, 20)];
    [activeTimeView addSubview:imgView];
    [scrollView addSubview:activeTimeView];
    
    height = height + conHeight + gapHeight;
    
    UIView *zoneview = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH, conHeight)];
    zoneview.tag = 102;
    _zoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_zoneLabel setFont:FONT(14.f)];
    [_zoneLabel setTextAlignment:NSTextAlignmentRight];
    _zoneLabel.text = LANGUAGE(@"active zone");
    [zoneview addSubview:_zoneLabel];
    
    _zoneText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart - 10, 0, secondWidth, conHeight)];
    _zoneText.lineBreakMode = NSLineBreakByClipping;
    _zoneText.font = FONT(14.f);
    _zoneText.textAlignment = NSTextAlignmentLeft;
    [zoneview addSubview:_zoneText];
    
    img = [UIImage imageNamed:@"create_club_play_area"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(secondStart - 10 + secondWidth, 3, 20, 20)];
    [zoneview addSubview:imgView];
    [scrollView addSubview:zoneview];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clubDetailZonePress:)];
    [zoneview addGestureRecognizer:singleFinterTap];
    
    //3rd
    height = height + itemHeight / 2 + gapHeight - 7;
    itemBack = [[UIView alloc] init];
    itemBack.tag = 103;
    itemBack.layer.cornerRadius = 5;
    itemBack.layer.masksToBounds = YES;
    itemBack.backgroundColor = [UIColor ggaThemeGrayColor];
    itemBack.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, itemHeight);
    [scrollView addSubview:itemBack];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2, itemBack.frame.size.width - 30, 0.3f)];
    dotView.tag = 201;
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [itemBack addSubview:dotView];
    
    height += 7;
    UIView *stadiumAreaView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH, conHeight)];
    stadiumAreaView.tag = 104;
    
    _stadiumAreaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_stadiumAreaLabel setFont:FONT(14.f)];
    [_stadiumAreaLabel setTextAlignment:NSTextAlignmentRight];
    _stadiumAreaLabel.text = LANGUAGE(@"main home zone");
    [stadiumAreaView addSubview:_stadiumAreaLabel];
    
    _stadiumAreaText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart- 10, 0, secondWidth, conHeight)];
    _stadiumAreaText.font = FONT(14.f);
    _stadiumAreaText.textAlignment = NSTextAlignmentLeft;
    [stadiumAreaView addSubview:_stadiumAreaText];
    img = [UIImage imageNamed:@"create_club_stadium"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame: CGRectMake(secondStart - 10 + secondWidth, 3, 20, 20)];
    [stadiumAreaView addSubview:imgView];
    [scrollView addSubview:stadiumAreaView];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clubDetailStadiumAreaPress:)];
    [stadiumAreaView addGestureRecognizer:singleFinterTap];

    height = height + conHeight + gapHeight;
    _stadiumAddrLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, labelWidth, conHeight)];
    _stadiumAddrLabel.tag = 105;
    [_stadiumAddrLabel setFont:FONT(14.f)];
    [_stadiumAddrLabel setTextAlignment:NSTextAlignmentRight];
    _stadiumAddrLabel.text = LANGUAGE(@"stadiumAddr");
    [scrollView addSubview:_stadiumAddrLabel];
    
    _stadiumAddrText = [[UITextView alloc] initWithFrame:CGRectMake(secondStart, height - 3, SCREEN_WIDTH - secondStart - iconSize, conHeight + 5)];
    _stadiumAddrText.tag = 106;
    _stadiumAddrText.layer.cornerRadius = 6;
    _stadiumAddrText.autocorrectionType = UITextAutocorrectionTypeNo;
    _stadiumAddrText.font = FONT(14.f);
    _stadiumAddrText.delegate = self;
    _stadiumAddrText.editable = NO;
    _stadiumAddrText.layer.borderColor = [UIColor ggaGrayBorderColor].CGColor;
    _stadiumAddrText.layer.borderWidth = 0.3f;
    
    [scrollView addSubview:_stadiumAddrText];
    
    //4rd group
    if ([[ClubManager sharedInstance] checkMyClub:nClubID])
    {
        height = height + itemHeight / 2 + gapHeight - 7;
        itemBack = [[UIView alloc] init];
        itemBack.tag = 107;
        itemBack.layer.cornerRadius = 5;
        itemBack.layer.masksToBounds = YES;
        itemBack.backgroundColor = [UIColor ggaThemeGrayColor];
        itemBack.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, itemHeight);
        [scrollView addSubview:itemBack];
        
        dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2, itemBack.frame.size.width - 30, 0.3f)];
        dotView.tag = 202;
        dotView.borderType = BorderTypeDashed;
        dotView.borderWidth = 0.3f;
        dotView.borderColor = [UIColor lightGrayColor];
        dotView.dashPattern = 2;
        dotView.spacePattern = 2;
        [itemBack addSubview:dotView];
        height += 7;
        
        UIView *marksView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH, conHeight)];
        marksView.tag = 108;
        
        UILabel *marksLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
        [marksLabel setFont:FONT(14.f)];
        [marksLabel setTextAlignment:NSTextAlignmentRight];
        marksLabel.text = LANGUAGE(@"club_marks");
        [marksView addSubview:marksLabel];
        
        _marksText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart - 10, 0, secondWidth, conHeight)];
        [_marksText setFont:FONT(14.f)];
        [_marksText setTextAlignment:NSTextAlignmentLeft];
        [marksView addSubview:_marksText];
        
        img = [UIImage imageNamed:@"create_club_score"];
        imgView = [[UIImageView alloc] initWithImage:img];
        [imgView setFrame: CGRectMake(secondStart - 10 + secondWidth, 3, 20, 20)];
        [marksView addSubview:imgView];
        [scrollView addSubview:marksView];
        
        singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(marksClick:)];
        [marksView addGestureRecognizer:singleFinterTap];
        
        height = height + conHeight + gapHeight;
        UIView *memberView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH, conHeight)];
        memberView.tag = 109;
        
        _memberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
        [_memberLabel setFont:FONT(14.f)];
        [_memberLabel setTextAlignment:NSTextAlignmentRight];
        _memberLabel.text = LANGUAGE(@"member count");
        [memberView addSubview:_memberLabel];
        
        _memberText = [[UILabel alloc] initWithFrame:CGRectMake(secondStart - 10, 0, secondWidth, conHeight)];
        [_memberText setFont:FONT(14.f)];
        [_memberText setTextAlignment:NSTextAlignmentLeft];
        [memberView addSubview:_memberText];
        
        [scrollView addSubview:memberView];
        
        singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(memberClick:)];
        [memberView addGestureRecognizer:singleFinterTap];
    }
    
    //5rd group
    height = height + itemHeight / 2 + gapHeight - 7;
    itemBack = [[UIView alloc] init];
    itemBack.tag = 110;
    itemBack.layer.cornerRadius = 5;
    itemBack.layer.masksToBounds = YES;
    itemBack.backgroundColor = [UIColor ggaThemeGrayColor];
    itemBack.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, itemHeight - 3);
    [scrollView addSubview:itemBack];
    
    dotView = [[LBorderView alloc]initWithFrame:CGRectMake(15, itemHeight / 2, itemBack.frame.size.width - 30, 0.3f)];
    dotView.tag = 203;
    dotView.borderType = BorderTypeDashed;
    dotView.borderWidth = 0.3f;
    dotView.borderColor = [UIColor lightGrayColor];
    dotView.dashPattern = 2;
    dotView.spacePattern = 2;
    [itemBack addSubview:dotView];
    height += 7;
    
    _sponsorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, labelWidth, conHeight)];
    _sponsorLabel.tag = 111;
    [_sponsorLabel setFont:FONT(14.f)];
    [_sponsorLabel setTextAlignment:NSTextAlignmentRight];
    _sponsorLabel.text = LANGUAGE(@"sponsor");
    [scrollView addSubview:_sponsorLabel];
    
    _sponsorText = [[UITextView alloc] initWithFrame:CGRectMake(secondStart, height - 3, SCREEN_WIDTH - secondStart - iconSize, conHeight + 5)];
    _sponsorText.tag = 112;
    _sponsorText.layer.cornerRadius = 6;
    _sponsorText.autocorrectionType = UITextAutocorrectionTypeNo;
    _sponsorText.font = FONT(14.f);
    _sponsorText.delegate = self;
    _sponsorText.editable = NO;
    _sponsorText.layer.borderColor = [UIColor ggaGrayBorderColor].CGColor;
    _sponsorText.layer.borderWidth = 0.3f;
    
    [scrollView addSubview:_sponsorText];
    
    height = height + conHeight + gapHeight;
    _introLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, labelWidth, conHeight)];
    _introLabel.tag = 113;
    [_introLabel setFont:FONT(14.f)];
    [_introLabel setTextAlignment:NSTextAlignmentRight];
    _introLabel.text = LANGUAGE(@"introduce");
    [scrollView addSubview:_introLabel];
    
    _introText = [[UITextView alloc] initWithFrame:CGRectMake(secondStart, height - 3, SCREEN_WIDTH - secondStart - iconSize, conHeight)];
    _introText.tag = 114;
    _introText.layer.cornerRadius = 6;
    _introText.autocorrectionType = UITextAutocorrectionTypeNo;
    _introText.font = FONT(14.f);
    _introText.delegate = self;
    _introText.editable = NO;
    _introText.layer.borderColor = [UIColor ggaGrayBorderColor].CGColor;
    _introText.layer.borderWidth = 0.3f;
    [scrollView addSubview:_introText];
    
    imageChanged = NO;
    
    height = height + gapHeight + conHeight + 7;
    joinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    joinButton.tag = 115;
    [joinButton setBackgroundColor:[UIColor ggaThemeColor]];
    [joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (IOS_VERSION >= 7.0)
    {
        joinButton.layer.cornerRadius = 17;
    }
    [joinButton addTarget:self action:@selector(joinButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [joinButton setTitle:LANGUAGE(@"join") forState:UIControlStateNormal];
    [scrollView addSubview:joinButton];

    if (!MEMBEROFCLUB(nClubID) && fromClubCenter)
        joinButton.hidden = NO;
    else
        joinButton.hidden = YES;
    
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, height + 70);
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(padClick:)];
    [scrollView addGestureRecognizer:singleFinterTap];
}

- (void)refreshControls
{
    CGRect frame;
    CGFloat itemWidth = _activeTimeText.frame.size.width;
    CGSize strSize = [_activeTimeText.text sizeWithFont:FONT(14.f)];
    NSInteger nCount = round(strSize.width/ itemWidth+ 0.5);
    if (strSize.width > itemWidth) {
        frame = _activeTimeText.frame;
        frame.size.height = nCount * strSize.height ;
        NSInteger itemDiff = frame.size.height - _activeTimeText.frame.size.height;
        _activeTimeText.frame = frame;
        _activeTimeText.numberOfLines = nCount;
        for (int i = 100; i < 116; i ++) {
            if ( i == 100 || i == 101)
            {
                UIView *viewTag = [scrollView viewWithTag:i];
                frame = viewTag.frame;
                frame.size.height = frame.size.height + itemDiff;
                viewTag.frame = frame;
                if (i == 100) {
                    UIView *dotView = [viewTag viewWithTag:200];
                    frame = dotView.frame;
                    frame.origin.y += itemDiff;
                    dotView.frame = frame;
                }
                continue;
            }
        
            UIView *viewTag = [scrollView viewWithTag:i];
            frame = viewTag.frame;
            frame.origin.y = frame.origin.y + itemDiff;
            viewTag.frame = frame;
        }
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + itemDiff);
    } else {
        frame = _activeTimeText.frame;
        frame.size.height = 25;
        NSInteger itemDiff = frame.size.height - _activeTimeText.frame.size.height;
        _activeTimeText.frame = frame;
        _activeTimeText.numberOfLines = nCount;
        for (int i = 100; i < 116; i ++) {
            if ( i == 100 || i == 101)
            {
                UIView *viewTag = [scrollView viewWithTag:i];
                frame = viewTag.frame;
                frame.size.height = frame.size.height + itemDiff;
                viewTag.frame = frame;
                
                if (i == 100) {
                    UIView *dotView = [viewTag viewWithTag:200];
                    frame = dotView.frame;
                    frame.origin.y += itemDiff;
                    dotView.frame = frame;
                }
                continue;
            }
            
            UIView *viewTag = [scrollView viewWithTag:i];
            frame = viewTag.frame;
            frame.origin.y = frame.origin.y + itemDiff;
            viewTag.frame = frame;
        }
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + itemDiff);
    }
    
    itemWidth = _zoneText.frame.size.width;
    strSize = [_zoneText.text sizeWithFont:FONT(14.f)];
    nCount = round(strSize.width/ itemWidth+ 0.5);
    
    if (strSize.width > itemWidth) {
        frame = _zoneText.frame;
        frame.size.height = nCount * strSize.height ;
        NSInteger itemDiff = frame.size.height - _zoneText.frame.size.height;
        _zoneText.frame = frame;
        _zoneText.numberOfLines = nCount;
        for (int i = 100; i < 116; i ++) {
            if (i == 101) {
                continue;
            }
            if ( i == 100 || i == 102)
            {
                UIView *viewTag = [scrollView viewWithTag:i];
                frame = viewTag.frame;
                frame.size.height = frame.size.height + itemDiff;
                viewTag.frame = frame;
                continue;
            }
            
            UIView *viewTag = [scrollView viewWithTag:i];
            frame = viewTag.frame;
            frame.origin.y = frame.origin.y + itemDiff;
            viewTag.frame = frame;
        }
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + itemDiff);
    } else {
        frame = _zoneText.frame;
        frame.size.height = 25;
        NSInteger itemDiff = frame.size.height - _zoneText.frame.size.height;
        _zoneText.frame = frame;
        _zoneText.numberOfLines = nCount;
        for (int i = 100; i < 116; i ++) {
            if (i == 101) {
                continue;
            }
            if ( i == 100 || i == 102 )
            {
                UIView *viewTag = [scrollView viewWithTag:i];
                frame = viewTag.frame;
                frame.size.height = frame.size.height + itemDiff;
                viewTag.frame = frame;
                continue;
            }
            
            UIView *viewTag = [scrollView viewWithTag:i];
            frame = viewTag.frame;
            frame.origin.y = frame.origin.y + itemDiff;
            viewTag.frame = frame;
        }
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + itemDiff);
    }
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
            for (int i = 103; i < 116; i ++) {
                if ( i == 103 )
                {
                    UIView *viewTag = [scrollView viewWithTag:i];
                    frame = viewTag.frame;
                    frame.size.height = frame.size.height + itemDiff;
                    viewTag.frame = frame;
                    continue;
                }
                if (i < 107) {
                    continue;
                }
                UIView *viewTag = [scrollView viewWithTag:i];
                frame = viewTag.frame;
                frame.origin.y = frame.origin.y + itemDiff;
                viewTag.frame = frame;
            }
        } else if (textView == _sponsorText) {
            for (int i = 110; i < 116; i ++) {
                if ( i == 110 )
                {
                    UIView *viewTag = [scrollView viewWithTag:i];
                    frame = viewTag.frame;
                    frame.size.height = frame.size.height + itemDiff;
                    viewTag.frame = frame;
                    
                    UIView *dotViewTag = [viewTag viewWithTag:203];
                    frame = dotViewTag.frame;
                    frame.origin.y = frame.origin.y + itemDiff;
                    dotViewTag.frame = frame;
                    continue;
                }
                if (i < 113) {
                    continue;
                }
                UIView *viewTag = [scrollView viewWithTag:i];
                frame = viewTag.frame;
                frame.origin.y = frame.origin.y + itemDiff;
                viewTag.frame = frame;
            }
        } else if (textView == _introText) {
            UIView *viewTag = [scrollView viewWithTag:110];
            frame = viewTag.frame;
            frame.size.height = frame.size.height + itemDiff;
            viewTag.frame = frame;
            
            viewTag = [scrollView viewWithTag:115];
            frame = viewTag.frame;
            frame.origin.y = frame.origin.y + itemDiff;
            viewTag.frame = frame;
        }
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + itemDiff);
    }
    textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, newSizeH);
}

// Code from apple developer forum - @Steve Krulewitz, @Mark Marszal, @Eric Silverberg
- (CGFloat)measureHeight:(id)sender
{
    UITextView *textView = (UITextView*)sender;
    
    UIFont *font = textView.font;
    NSString *str = textView.text;
    
    UIEdgeInsets insets = textView.textContainerInset;
    
    int w = textView.frame.size.width;
    
    CGSize size = [str sizeWithFont:font constrainedToSize:CGSizeMake(w, 500)];
    return size.height + insets.bottom + insets.top;
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
        CGRect viewFrame = scrollView.frame;
        viewFrame.size.height -= (keyboardSizeAfter.height - keyboardSize.height);
        
        scrollView.frame = viewFrame;
        keyboardVisible = YES;
        return;
    }
    
    if (keyboardVisible) {
        return;
    }
    
    // 키보드의 크기만큼 스크롤 뷰의 크기를 줄입니다.
    CGRect viewFrame = scrollView.frame;
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
    CGRect viewFrame = scrollView.frame;
    viewFrame.size.height += keyboardSize.height;
    
    scrollView.frame = viewFrame;
    keyboardVisible = NO;
}

#pragma Events
- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

#pragma Events
NSString *originalStr;
- (void)establishDayClick:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    return;
    
    if (![[ClubManager sharedInstance] checkAdminClub:nClubID])
        return;
    
    //Added By Boss.2015/05/06
    if (_datepicker != nil) {
        return;
    }
    originalStr = [[NSString alloc] init];
    originalStr = _establishText.text;
    _datepicker= [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 250)];
    _datepicker.datePickerMode = UIDatePickerModeDate;
    _datepicker.backgroundColor = [UIColor whiteColor];
    originalStr = [[NSString alloc] init];
    originalStr = _establishText.text;
    if (originalStr != nil && [originalStr compare:@""] != NSOrderedSame) {
        NSDateFormatter *outformat = [[NSDateFormatter alloc] init];
        [outformat setDateFormat:@"YYYY-MM-dd"];
        NSDate *date = [outformat dateFromString:originalStr];
        [_datepicker setDate:date];
    }
    
    [_datepicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
    _datepicker.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_datepicker];
    _toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35)];
    _toolbar.backgroundColor = [UIColor blackColor];
    _toolbar.barStyle = UIBarStyleBlackOpaque;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:LANGUAGE(@"DONE") style: UIBarButtonItemStyleBordered target: self action: @selector(HidePicker:)];
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

#pragma Events
- (void)clubDetailCityClick:(UITapGestureRecognizer *)recognizer
{
    [self cancelPressed];
    [self.view endEditing:YES];
    
    if ((nUserType & CLUB_USER_POST_CAPTAIN) != CLUB_USER_POST_CAPTAIN)
        return;
    
    [[NSUserDefaults standardUserDefaults] setObject:_stadiumAreaText.text forKey:@"STADIUM_ZONE"];
    [[NSUserDefaults standardUserDefaults] setObject:_zoneText.text forKey:@"ACTIVE_ZONE"];
    
    CitySelectController *vc = [[CitySelectController alloc] init];
    vc.delegate = self;
    vc.beforeSelected = _cityText.text;
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    
    [appDelegate.ggaNav pushViewController:vc animated:YES];
}


- (void)activeTimePress:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    [self cancelPressed];
    
    if ((nUserType & CLUB_USER_POST_CAPTAIN) != CLUB_USER_POST_CAPTAIN)
        return;
    
    [[NSUserDefaults standardUserDefaults] setObject:_zoneText.text forKey:@"ACTIVE_ZONE"];
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[WeekSelectController alloc] init] animated:YES];
}

#pragma Events
- (void)clubDetailZonePress:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    
    originalStr = _establishText.text;
    [self cancelPressed];
    
    if ((nUserType & CLUB_USER_POST_CAPTAIN) != CLUB_USER_POST_CAPTAIN)
        return;
    if (cityID == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"city is not selected")];
        return;
    }
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [[NSUserDefaults standardUserDefaults] setObject:_zoneText.text forKey:@"ACTIVE_ZONE"];
    [[NSUserDefaults standardUserDefaults] setObject:@"ACTIVE_ZONE" forKey:@"ZONE_SELECT_FOR_WHAT"];
    [appDelegate.ggaNav pushViewController:[[ZoneSelectController alloc] initWithCityIndex:cityID]animated:YES];
}

#pragma Events
- (void)clubDetailStadiumAreaPress:(UITapGestureRecognizer *)recongizer
{
    [self.view endEditing:YES];
    [self cancelPressed];
    
    if ((nUserType & CLUB_USER_POST_CAPTAIN) != CLUB_USER_POST_CAPTAIN)
        return;
    if (cityID == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"city is not selected")];
        return;
    }
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [[NSUserDefaults standardUserDefaults] setObject:@"STADIUM_ZONE" forKey:@"ZONE_SELECT_FOR_WHAT"];
    [[NSUserDefaults standardUserDefaults] setObject:_zoneText.text forKey:@"ACTIVE_ZONE"];
    [appDelegate.ggaNav pushViewController:[[ZoneSelectController alloc] initWithCityIndex:cityID] animated:YES];
}

- (void)memberClick:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    [self cancelPressed];
    
    if (![[ClubManager sharedInstance] checkMyClub:nClubID])
        return;
	
    [[NSUserDefaults standardUserDefaults] setObject:_stadiumAreaText.text forKey:@"STADIUM_ZONE"];
    [[NSUserDefaults standardUserDefaults] setObject:_zoneText.text forKey:@"ACTIVE_ZONE"];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    ClubMemberController *cmVC = [[ClubMemberController alloc] initWithClubID:nClubID];
    [appDelegate.ggaNav pushViewController:cmVC animated:YES];
}

- (void)marksClick:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    [self cancelPressed];
    
    if (![[ClubManager sharedInstance] checkMyClub:nClubID])
        return;
    
    
    [[NSUserDefaults standardUserDefaults] setObject:_stadiumAreaText.text forKey:@"STADIUM_ZONE"];
    [[NSUserDefaults standardUserDefaults] setObject:_zoneText.text forKey:@"ACTIVE_ZONE"];
    
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ClubMarksDetailController alloc] initWithClubID:nClubID] animated:YES];
}

#pragma Events
- (void)breakButtonPressed:(UITapGestureRecognizer *)recognizer
{
    [AlertManager WaitingWithMessage];
    NSArray *data = [NSArray arrayWithObjects:
                     [NSNumber numberWithInt:UID],
                     [NSNumber numberWithInt:nClubID],
                     nil];
    [[HttpManager sharedInstance] breakDownClubWithDelegate:self data:data];
}

#pragma Events
- (void)joinButtonPressed:(UITapGestureRecognizer *)recognizer
{
    [AlertManager WaitingWithMessage];
    NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:UID],
                     [NSNumber numberWithInt:nClubID], nil];
    [[HttpManager sharedInstance] registerUserToClubWithDelegate:self data:data];
}

#pragma Events
- (void)changeButtonPressed:(id)sender
{
    stadiumAddrStr = _stadiumAddrText.text;
    zoneIDs = [[DistrictManager sharedInstance] stringAreaIDsArrayOfAreas:_zoneText.text InCity:cityID];

    NSString *stadiumAreaStr = _stadiumAreaText.text;
    for (NSDictionary *item in [[DistrictManager sharedInstance] districtsWithCityIndex:cityID])
    {
        if ([stadiumAreaStr isEqual:[item objectForKey:@"district"]])
            stadiumAreaID = [[item objectForKey:@"id"] intValue];
    }
    
    if (_clubNameField.text == nil || [_clubNameField.text compare:@""] == NSOrderedSame)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"create club name invalid")];
        return;
    }
    
    if (_establishText.text == nil || [_establishText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"create club establish invalid")];
        return;
    }
    if (_cityText.text == nil || [_cityText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"create club city invalid")];
        return;
    }
    if (_activeTimeText.text == nil || [_activeTimeText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"create club activeTime invalid")];
        return;
    }
    if (_stadiumAddrText.text == nil || [_stadiumAreaText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"create club stadiumArea invalid")];
        return;
    }
    if (_zoneText.text == nil || [_zoneText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"create club zone invalid")];
        return;
    }
    if (_stadiumAddrText.text == nil || [_stadiumAddrText.text isEqualToString:@""])
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"create club stadiumAddr invalid")];
        return;
    }
    
    if (!imageChanged)
    {
        [AlertManager WaitingWithMessage];
        NSArray *data = [NSArray arrayWithObjects:
                         [NSString stringWithFormat:@"%d", UID],
                         [NSString stringWithFormat:@"%d", nClubID],
                         _clubNameField.text,
                         @"",
                         [NSString stringWithFormat:@"%d", cityID],
                         @"10",
                         _sponsorText.text,
                         _introText.text,
                         [NSString stringWithFormat:@"%ld", (long)[NSWeek intWithStringWeek:_activeTimeText.text]],
                         [NSString stringWithFormat:@"%@", zoneIDs],
                         [NSString stringWithFormat:@"%d", stadiumAreaID],
                         stadiumAddrStr,
                         _establishText.text,
                         @"1",
                         nil];
        
        [[HttpManager sharedInstance] createClubWithDelegate:self data:data];
    }
    else
    {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:_clubImage.image forKey:@"image"];
        [AlertManager WaitingWithMessage];
        [self loadImage:param];
    }
}

- (void)padClick:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    [self cancelPressed];
}

#pragma Events
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)HidePicker:(id)sender{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _datepicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 20);
                         _toolbar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 35);
                     } completion:^(BOOL finished) {
                         //NSLOG
                         _establishText.text = [outputFormatter stringFromDate:self.datepicker.date];
                         [_datepicker removeFromSuperview];
                         [_toolbar removeFromSuperview];
                         _datepicker = nil;
                         _toolbar = nil;
                     }];
}

-(IBAction)cancelPressed
{
//    _establishText.text = originalStr;
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
    _establishText.text = [dateFormatter stringFromDate:[(UIDatePicker*)sender date]];
}

#pragma HttpManagerDelegate
- (void)browseClubDetailResultWithErrorCode:(int)errorCode clubdata:(ClubListRecord *)data
{
    [AlertManager HideWaiting];
    
    nUserType = [data intWithUserType];
    
    _clubNameField.text = [data stringWithClubName];
    _establishText.text = [data stringWithFoundDate];
    originalStr = _establishText.text;
    _cityText.text = [data stringWithCity];
    cityID = [data intWithCity];
    _activeLabel.text = [NSString stringWithFormat:@"%@ : %ld",LANGUAGE(@"action rate"), [data valueWithActiveRate]];
    
    NSString *tmp = [NSWeek stringWithIntegerWeek:[data intWithActiveWeeks]];

#ifdef DEMO_MODE
    NSLog(@"%@, %d", tmp, [data intWithActiveWeeks]);
#endif
    
    [[NSUserDefaults standardUserDefaults] setObject:tmp forKey:@"WorkDays"];
    _activeTimeText.text = tmp;
    _sponsorText.text = [data stringWithSponsor];
    _zoneText.text = [[DistrictManager sharedInstance] stringAreaNamesArrayOfAreaIDs:[data stringWithActiveArea] InCity:_cityText.text];
    _stadiumAreaText.text = [data stringWithStadiumArea];
    _stadiumAddrText.text = [data stringWithStadiumAddr];
    _introText.text = [data stringWithIntroduction];
    _marksText.text = [NSString stringWithFormat:@"%d%@ %d%@ %d%@", [data intWithVictoies],LANGUAGE(@"ClubDetail_All"), [data intWithDraw], LANGUAGE(@"ClubDetail_Draw"),[data intWithLoss],LANGUAGE(@"ClubDetail_Loss")];
    _memberText.text = [NSString stringWithFormat:@"%ld%@", [data valueWithMembers],LANGUAGE(@"PLAYER")];
    
    NSString *imageUrl = [data stringWithClubImageUrl];
    if (imageUrl && ![imageUrl isEqualToString:@""])
    {
        _clubImage.image = [CacheManager GetCacheImageWithURL:imageUrl];
        if (!_clubImage.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:imageUrl];
                     _clubImage.image = [image circleImageWithSize:_clubImage.frame.size.width];
                 }
                 else
                 {
                     _clubImage.image = [IMAGE(@"club_default") circleImageWithSize:_clubImage.frame.size.width];
                 }
             }];
        }
        else
            _clubImage.image = [[CacheManager GetCacheImageWithURL:imageUrl] circleImageWithSize:_clubImage.frame.size.width];
    }
    else
        _clubImage.image = [IMAGE(@"club_default") circleImageWithSize:_clubImage.frame.size.width];

    [self refreshControls];
    
    [[NSUserDefaults standardUserDefaults] setObject:_zoneText.text forKey:@"ACTIVE_ZONE"];
    [[NSUserDefaults standardUserDefaults] setObject:_stadiumAreaText.text forKey:@"STADIUM_ZONE"];
    
    [self performSelector:@selector(textViewDidChange:) withObject:_stadiumAddrText];
    [self performSelector:@selector(textViewDidChange:) withObject:_sponsorText];
    [self performSelector:@selector(textViewDidChange:) withObject:_introText];
    
    [self refreshHeight:_stadiumAddrText];
    [self refreshHeight:_sponsorText];
    [self refreshHeight:_introText];
    
    if ((nUserType & CLUB_USER_POST_CAPTAIN) == CLUB_USER_POST_CAPTAIN)
    {
        _clubImage.userInteractionEnabled = YES;
        _sponsorText.editable = YES;
        _introText.editable = YES;
        _stadiumAddrText.editable = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:changeButtonRegion];
        return;
    }
    else
    {
        joinButton.frame = CGRectMake(10, _introText.frame.origin.y + _introText.frame.size.height + 20, SCREEN_WIDTH - 20, 35);
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
}

#pragma HttpManagerDelegate
- (void)createClubResultWithErrorCode:(int)error_code data:(NSDictionary *)club
{
    [AlertManager HideWaiting];
    if (error_code > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:error_code])];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
}

#pragma HttpManagerDelegate
- (void)breakDownClubResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
        [[ClubManager sharedInstance] removeAdminClub:nClubID];
        [[ClubManager sharedInstance] removeClub:nClubID];
        [[DiscussRoomManager sharedInstance] removeChatRoomsWithClubID:nClubID];
    }
    
}

#pragma HttpManagerDelegate
- (void)registerUserToClubResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"register UserToClub success")];
}

#pragma CitySelectControllerDelegate
- (void)selectedCityWithIndex:(int)index
{
    [Common BackToPage];
    _cityText.text = [[CITYS objectAtIndex:index] objectForKey:@"city"];
    cityID = [[[CITYS objectAtIndex:index] valueForKey:@"id"] intValue];
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
    
    NSString *strUrl = [NSString stringWithFormat:FILE_UPLOAD_URL,SERVER_IP_ADDRESS, _PORT];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSLog(@"imageUpload_URL: %@", url);
    
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

/*
 기능: 구락부쌈브화상을 앞로드한 다음 결과를 받는 함수
 성공이면 구락부자료변경통신을 진행한다.
 */
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
    
    [AlertManager WaitingWithMessage];
    NSArray *array = [NSArray arrayWithObjects:
                     [NSString stringWithFormat:@"%d", UID],
                     [NSString stringWithFormat:@"%d", nClubID],
                     _clubNameField.text,
                     img_name,
                     [NSString stringWithFormat:@"%d", cityID],
                     @"10",
                     _sponsorText.text,
                     _introText.text,
                     [NSString stringWithFormat:@"%ld", (long)[NSWeek intWithStringWeek:_activeTimeText.text]],
                     [NSString stringWithFormat:@"%@", zoneIDs],
                     [NSString stringWithFormat:@"%d", stadiumAreaID],
                     stadiumAddrStr,
                     _establishText.text,
                     @"1",
                     nil];
    
    [[HttpManager sharedInstance] createClubWithDelegate:self data:array];
}


@end
