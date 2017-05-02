//
//  BattleResultInputController.m
//  GoalGroup
//
//  Created by MacMini on 4/6/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "BattleResultInputController.h"
#import "Common.h"

@interface BattleResultInputController ()
{
    NSString *strFirstSendMark;
    NSString *strFirstRecvMark;
    NSString *strSecondSendMark;
    NSString *strSecondRecvMark;
    NSString *strGameResult;
    
    int nSendClub;
    int nRecvClub;
    int nMatchResult;
    
    BOOL isKeyboardShow;
    
    UIButton *confirmButton;
    UIScrollView *scrollView;
}

@end

@implementation BattleResultInputController

+ (BattleResultInputController *)sharedInstance
{
    @synchronized(self)
    {
        if (gBattleResultInputController == nil)
            gBattleResultInputController = [[BattleResultInputController alloc] init];
    }
    return gBattleResultInputController;
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
    [super viewDidLoad];
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    [self layoutComponents];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    strFirstSendMark = @"0";
    strFirstRecvMark = @"0";
    strSecondSendMark = @"0";
    strSecondRecvMark = @"0";
    
    sendClubLabel.text = @"";
    recvClubLabel.text = @"";
    strGameResult = @"0 - 0";
    
    [AlertManager WaitingWithMessage];
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:nGameID], nil];
    [[HttpManager sharedInstance] getGameResultWithDelegate:self data:array];

    firstSendMark.text = strFirstSendMark;
    firstRecvMark.text = strFirstRecvMark;
    secondSendMark.text = strSecondSendMark;
    secondRecvMark.text = strSecondRecvMark;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

    isKeyboardShow = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UserDefine
- (void)layoutComponents
{
    self.view.backgroundColor = [UIColor ggaGrayBackColor];
    
    overlayView = [[DAOverlayView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    overlayView.backgroundColor = [UIColor clearColor];
    overlayView.delegate = self;
    
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];

    self.title = LANGUAGE(@"score");
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 70)];
    scrollView.backgroundColor = [UIColor ggaGrayBackColor];
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - self.navigationController.navigationBar.bounds.size.height - 20);
    [scrollView addSubview:overlayView];
    
    UIImageView *topBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 130)];
    [topBackground setImage: IMAGE(@"game_result_bg")];
    sendClubImage = [[UIImageView alloc] initWithFrame:CGRectMake(35, 15, 60, 60)];
    recvClubImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 95, 15, 60, 60)];
    
    sendClubLabel = [[UILabel alloc] initWithFrame:CGRectMake(-15, 80, SCREEN_WIDTH / 2, 40)];
    [sendClubLabel setTextAlignment:NSTextAlignmentCenter];
    [sendClubLabel setFont:FONT(14.f)];
    [sendClubLabel setTextColor:[UIColor whiteColor]];
    
    UILabel *vsLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 10, 80, 40, 40)];
    [vsLabel setText:@"VS"];
    [vsLabel setFont:FONT(16.f)];
    [vsLabel setTextColor:[UIColor whiteColor]];
                        
    recvClubLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 15, 80, SCREEN_WIDTH / 2, 40)];
    [recvClubLabel setTextAlignment:NSTextAlignmentCenter];
    [recvClubLabel setFont:FONT(14.f)];
    [recvClubLabel setTextColor:[UIColor whiteColor]];
    
    UIView *grayBack1 = [[UIView alloc] initWithFrame: CGRectMake(10, 150, SCREEN_WIDTH - 20, 50)];
    [grayBack1 setBackgroundColor: [UIColor colorWithRed:242.f/255.f green:242.f/255.f blue:242.f/255.f alpha:1.f]];
    
    UIView *grayBack2 = [[UIView alloc] initWithFrame: CGRectMake(10, 220, SCREEN_WIDTH - 20, 50)];
    [grayBack2 setBackgroundColor: [UIColor colorWithRed:242.f/255.f green:242.f/255.f blue:242.f/255.f alpha:1.f]];
    
    gameResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 50, 15, 100, 60)];
    gameResultLabel.textColor = [UIColor blackColor];
    gameResultLabel.textAlignment = NSTextAlignmentCenter;
    gameResultLabel.text = strGameResult;
    gameResultLabel.font = FONT(30.f);
    
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 30, 150, 60, 50)];
    [firstLabel setTextAlignment:NSTextAlignmentCenter];
    [firstLabel setFont:FONT(15.f)];
    [firstLabel setText:LANGUAGE(@"first_half")];
    [firstLabel setTextColor:[UIColor whiteColor]];
    
    firstSendMark = [[UITextField alloc] initWithFrame:CGRectMake(20, 150, SCREEN_WIDTH / 2 - 60, 50)];
    firstSendMark.borderStyle = UITextBorderStyleNone;
    firstSendMark.backgroundColor = [UIColor colorWithRed:242.f/255.f green:242.f/255.f blue:242.f/255.f alpha:1.f];
    firstSendMark.keyboardType = UIKeyboardTypeNumberPad;
    firstSendMark.returnKeyType = UIReturnKeyDone;
    firstSendMark.clearButtonMode = UITextFieldViewModeWhileEditing;
    firstSendMark.textAlignment = NSTextAlignmentCenter;
    firstSendMark.delegate = self;
    
    UIImageView *halfResult1 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, 150, 80, 50)];
    [halfResult1 setImage: IMAGE(@"half_result_bg")];
    
    firstRecvMark = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 40, 150, SCREEN_WIDTH / 2 - 60, 50)];
    firstRecvMark.borderStyle = UITextBorderStyleNone;
    firstRecvMark.backgroundColor = [UIColor colorWithRed:242.f/255.f green:242.f/255.f blue:242.f/255.f alpha:1.f];
    firstRecvMark.keyboardType = UIKeyboardTypeNumberPad;
    firstRecvMark.returnKeyType = UIReturnKeyDone;
    firstRecvMark.clearButtonMode = UITextFieldViewModeWhileEditing;
    firstRecvMark.textAlignment = NSTextAlignmentCenter;
    firstRecvMark.delegate = self;
    
    
    UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 30, 220, 60, 50)];
    [secondLabel setTextAlignment:NSTextAlignmentCenter];
    [secondLabel setFont:FONT(15.f)];
    [secondLabel setText:LANGUAGE(@"second_half")];
    [secondLabel setTextColor: [UIColor whiteColor]];

    secondSendMark = [[UITextField alloc] initWithFrame:CGRectMake(20, 220, SCREEN_WIDTH / 2 - 60, 50)];
    secondSendMark.borderStyle = UITextBorderStyleNone;
    secondSendMark.backgroundColor = [UIColor colorWithRed:242.f/255.f green:242.f/255.f blue:242.f/255.f alpha:1.f];
    secondSendMark.keyboardType = UIKeyboardTypeNumberPad;
    secondSendMark.returnKeyType = UIReturnKeyDone;
    secondSendMark.clearButtonMode = UITextFieldViewModeWhileEditing;
    secondSendMark.textAlignment = NSTextAlignmentCenter;
    secondSendMark.delegate = self;
    
    UIImageView *halfResult2 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, 220, 80, 50)];
    [halfResult2 setImage: IMAGE(@"half_result_bg")];
    
    secondRecvMark = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 40, 220, SCREEN_WIDTH / 2 - 60, 50)];
    secondRecvMark.borderStyle = UITextBorderStyleNone;
    secondRecvMark.backgroundColor = [UIColor colorWithRed:242.f/255.f green:242.f/255.f blue:242.f/255.f alpha:1.f];
    secondRecvMark.keyboardType = UIKeyboardTypeNumberPad;
    secondRecvMark.returnKeyType = UIReturnKeyDone;
    secondRecvMark.clearButtonMode = UITextFieldViewModeWhileEditing;
    secondRecvMark.textAlignment = NSTextAlignmentCenter;
    secondRecvMark.delegate = self;
    confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setFrame:CGRectMake(10, 300, SCREEN_WIDTH - 20, 45)];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setBackgroundColor:[UIColor ggaThemeColor]];
    [confirmButton setTitle:LANGUAGE(@"confirm") forState:UIControlStateNormal];
    confirmButton.layer.cornerRadius = 5.f;
    [confirmButton addTarget:self action:@selector(clickConfirmButton) forControlEvents:UIControlEventTouchDown];
    
    [scrollView addSubview:topBackground];
    [scrollView addSubview:sendClubImage];
    [scrollView addSubview:recvClubImage];
    [scrollView addSubview:sendClubLabel];
    [scrollView addSubview:vsLabel];
    [scrollView addSubview:recvClubLabel];
    [scrollView addSubview:grayBack1];
    [scrollView addSubview:grayBack2];
    [scrollView addSubview:gameResultLabel];
    
    
    [scrollView addSubview:firstSendMark];
    [scrollView addSubview:halfResult1];
    [scrollView addSubview:firstLabel];
    [scrollView addSubview:firstRecvMark];
    
    [scrollView addSubview:secondRecvMark];
    [scrollView addSubview:halfResult2];
    [scrollView addSubview:secondLabel];
    [scrollView addSubview:secondSendMark];
    [scrollView addSubview:confirmButton];
    [self.view addSubview:scrollView];
    
}

#pragma UserDefined
- (void)clickConfirmButton
{
    BOOL sendGame = NO;
    if ([[ClubManager sharedInstance] checkAdminClub:nSendClub])
        sendGame = YES;
    else
        sendGame = NO;
    
    if (sendGame)
    {
        [AlertManager WaitingWithMessage];
        
        strFirstSendMark = firstSendMark.text;
        strFirstRecvMark = firstRecvMark.text;
        strSecondSendMark = secondSendMark.text;
        strSecondRecvMark = secondRecvMark.text;
        
        strFirstSendMark = [strFirstSendMark isEqualToString:@""]? @"0" : strFirstSendMark;
        strFirstRecvMark = [strFirstRecvMark isEqualToString:@""]? @"0" : strFirstRecvMark;
        strSecondSendMark = [strSecondSendMark isEqualToString:@""]? @"0" : strSecondSendMark;
        strSecondRecvMark = [strSecondRecvMark isEqualToString:@""]? @"0" : strSecondRecvMark;
        
        strFirstSendMark = [NSString stringWithFormat:@"%d", [strFirstSendMark intValue]];
        strFirstRecvMark = [NSString stringWithFormat:@"%d", [strFirstRecvMark intValue]];
        strSecondSendMark = [NSString stringWithFormat:@"%d", [strSecondSendMark intValue]];
        strSecondRecvMark = [NSString stringWithFormat:@"%d", [strSecondRecvMark intValue]];
        
        NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:nClubID],
                         [NSNumber numberWithInt:nGameID],
                         strFirstSendMark,
                         strSecondSendMark,
                         strFirstRecvMark,
                         strSecondRecvMark,
                         [NSNumber numberWithInt:nMatchResult],
                         nil];
        
        [[HttpManager sharedInstance] setGameResultWithDelegate:self data:data];
    }
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"cannot input game score")];
}

#pragma UserDefined
- (void)setClubID:(int)clubID gameID:(int)gameID
{
    nClubID = clubID;
    nGameID = gameID;
    
}

#pragma UserDefined
- (void)loadClubImage:(NSString *)imageUrl WithImageView:(UIImageView *)imageView
{
    if (imageUrl && ![imageUrl isEqualToString:@""])
    {
        imageView.image = [CacheManager GetCacheImageWithURL:imageUrl];
        if (!imageView.image)
        {
            [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
             {
                 if (image)
                 {
                     [CacheManager CacheWithImage:image filename:imageUrl];
                     imageView.image = [image circleImageWithSize:imageView.frame.size.width];
                 }
                 else
                 {
                     imageView.image = [IMAGE(@"club_icon") circleImageWithSize:imageView.frame.size.width];
                 }
                 [self.view setNeedsDisplay];
                 return ;
             }
             ];
        }
        else
            imageView.image = [[CacheManager GetCacheImageWithURL:imageUrl] circleImageWithSize:imageView.frame.size.width];
    }
    else
        imageView.image = [IMAGE(@"club_icon") circleImageWithSize:imageView.frame.size.width];
    [self.view setNeedsDisplay];
}

#pragma UserDefined
- (void)backToPage
{
    [Common BackToPage];
}

- (void)editingEnd
{
    [firstSendMark endEditing:YES];
    [firstRecvMark endEditing:YES];
    [secondSendMark endEditing:YES];
    [secondRecvMark endEditing:YES];
}

#pragma HttpManagerDelegate
- (void)setGameResultResultWithErrorCode:(int)errorcode
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
        
        firstSendMark.userInteractionEnabled = NO;
        firstRecvMark.userInteractionEnabled = NO;
        secondRecvMark.userInteractionEnabled = NO;
        secondSendMark.userInteractionEnabled = NO;
        confirmButton.hidden = YES;
        
        gameResultLabel.text = [NSString stringWithFormat:@"%d - %d", [strFirstSendMark intValue] + [strSecondSendMark intValue], [strFirstRecvMark intValue] + [strSecondRecvMark intValue]];
    }
}

#pragma HttpManagerDelegate
- (void)getGameResultResultWithErrorCode:(int)errorcode data:(NSArray *)array
{
    [AlertManager HideWaiting];
    
    if (errorcode > 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
        return;
    }
    
    nSendClub = [[array objectAtIndex:0] intValue];
    sendClubLabel.text = [array objectAtIndex:1];
    strFirstSendMark = [array objectAtIndex:3];
    strSecondSendMark = [array objectAtIndex:4];
    nRecvClub = [[array objectAtIndex:5] intValue];
    recvClubLabel.text = [array objectAtIndex:6];
    strFirstRecvMark = [array objectAtIndex:8];
    strSecondRecvMark = [array objectAtIndex:9];
    nMatchResult = [[array objectAtIndex:10] intValue];
    
    firstSendMark.text = strFirstSendMark;
    firstRecvMark.text = strFirstRecvMark;
    secondSendMark.text = strSecondSendMark;
    secondRecvMark.text = strSecondRecvMark;
    
    [self loadClubImage:[array objectAtIndex:2] WithImageView:sendClubImage];
    [self loadClubImage:[array objectAtIndex:7] WithImageView:recvClubImage];

    BOOL sendGame = NO;
    if ([[ClubManager sharedInstance] checkAdminClub:nSendClub])
        sendGame = YES;
    else
        sendGame = NO;

    firstSendMark.userInteractionEnabled = sendGame && nMatchResult != 0 && nMatchResult != 1 && nMatchResult != 2? YES : NO;
    firstRecvMark.userInteractionEnabled = sendGame && nMatchResult != 0 && nMatchResult != 1 && nMatchResult != 2? YES : NO;
    secondRecvMark.userInteractionEnabled = sendGame && nMatchResult != 0 && nMatchResult != 1 && nMatchResult != 2? YES : NO;
    secondSendMark.userInteractionEnabled = sendGame && nMatchResult != 0 && nMatchResult != 1 && nMatchResult != 2? YES : NO;
    confirmButton.hidden = sendGame && nMatchResult != 0 && nMatchResult != 1 && nMatchResult != 2? NO : YES;
    
    gameResultLabel.text = [NSString stringWithFormat:@"%d-%d", [strFirstSendMark intValue] + [strSecondSendMark intValue], [strFirstRecvMark intValue] + [strSecondRecvMark intValue]];

    [self.view setNeedsDisplay];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (isKeyboardShow )
        return;
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect viewFrame = scrollView.frame;
    viewFrame.size.height -= kbSize.height;
    scrollView.frame = viewFrame;
    isKeyboardShow = YES;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (!isKeyboardShow )
        return;
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect viewFrame = scrollView.frame;
    viewFrame.size.height += kbSize.height;
    scrollView.frame = viewFrame;
    isKeyboardShow = NO;
}

- (UIView *)overlayView:(DAOverlayView *)view didHitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    /*
    BOOL shouldIterceptTouches = CGRectContainsPoint([self.view convertRect:self.swipedCell.frame toView:self.view],
                                                     [self.view convertPoint:point fromView:view]);
    if (!shouldIterceptTouches) {
        [self hideMenuOptionsAnimated:YES];
    }
    return (shouldIterceptTouches) ? [self.swipedCell hitTest:point withEvent:event] : view;
     */
    [self.view endEditing:YES];
    return nil;
}

@end
