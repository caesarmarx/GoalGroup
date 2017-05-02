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
#import "Common.h"

@interface CreatingClubController ()
{
    UIImagePickerController *thumbImagePicker;
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

    return gCreatingClubController;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self layoutComponents];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self layoutComponents];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    _activeDayLabels.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"WorkDays"];
    
    NSString *zoneStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACTIVE_ZONE"];
    _zoneText.text = zoneStr;
    
    NSArray *zones = [zoneStr componentsSeparatedByString:@","];
    
    for (NSDictionary *item in [[DistrictManager sharedInstance] districtsWithCityIndex:_cityID]) {
        
        if ([[zones objectAtIndex:0] isEqual:[item objectForKey:@"district"]])
        {
            _zoneID = [[item objectForKey:@"id"] intValue];
        }
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutComponents
{
    self.title = @"俱乐部创建";
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    backButton.titleLabel.font = FONT(14.f);
    [backButton addTarget:self action:@selector(backToPage:) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    
    UIScrollView *scrollView;
    
    if (IOS_VERSION >= 7.0)
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height - 70)];
    else
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height -90)];
    
    scrollView.backgroundColor = [UIColor ggaGrayBackColor];
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 500);
    [self.view addSubview:scrollView];
    
    NSUInteger gapHeight = 10;
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
    [scrollView addSubview:thumbView];
    
    UITapGestureRecognizer *singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbImagePicker:)];
    [thumbView addGestureRecognizer:singleFinterTap];
    
    _clubImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_clubImage setImage:IMAGE(@"club_default")];
    [thumbView addSubview:_clubImage];
    
    _nameTField = [[UITextField alloc] initWithFrame:CGRectMake(fieldStart, 30, fieldWith, conHeight)];
    _nameTField.borderStyle = UITextBorderStyleRoundedRect;
    _nameTField.autocorrectionType = UITextAutocorrectionTypeNo;
    _nameTField.placeholder = @"俱乐部名称";
    _nameTField.returnKeyType = UIReturnKeyDone;
    _nameTField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameTField.delegate = self;
    [scrollView addSubview:_nameTField];
    
    height = height + 50 + gapHeight + gapHeight;
    
    UIImageView *itemBack = [[UIImageView alloc] initWithImage:IMAGE(@"item2back")];
    itemBack.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight) * 2 );
    [scrollView addSubview:itemBack];
    
    height += 5;
    
    UIView *establishView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH, conHeight)];
    _establishDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_establishDayLabel setFont:FONT(14.f)];
    [_establishDayLabel setTextAlignment:NSTextAlignmentRight];
    _establishDayLabel.text = @"成立时间:";
    [establishView addSubview:_establishDayLabel];
    
    _establishDayText = [[UILabel alloc] initWithFrame:CGRectMake(fieldStart - 10, 0, fieldWith, conHeight)];
    [_establishDayText setFont:FONT(14.f)];
    [_establishDayText setTextAlignment:NSTextAlignmentLeft];
    [establishView addSubview:_establishDayText];
    [scrollView addSubview:establishView];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(establishDayClicked:)];
    [establishView addGestureRecognizer:singleFinterTap];
    
    height = height + conHeight + gapHeight;
    UIView *cityView = [[UIView alloc] initWithFrame:CGRectMake(10, height, SCREEN_WIDTH -  20, conHeight)];
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cityClick:)];
    [cityView addGestureRecognizer:singleFinterTap];
    _cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_cityLabel setFont:FONT(14.f)];
    [_cityLabel setTextAlignment:NSTextAlignmentRight];
    _cityLabel.text = @"所属城市:";
    [cityView addSubview:_cityLabel];
    
    _cityText = [[UILabel alloc] initWithFrame:CGRectMake(fieldStart - 10, 0, fieldWith, conHeight)];
    _cityText.font = FONT(14.f);
    _cityText.textAlignment = NSTextAlignmentLeft;
    [cityView addSubview:_cityText];
    [scrollView addSubview:cityView];
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithImage:IMAGE(@"arrow")];
    arrowImage.frame  = CGRectMake(fieldStart + fieldWith + 15, height, 10, conHeight);
    [scrollView addSubview:arrowImage];
    
    height = height + conHeight + gapHeight * 2;
    itemBack = [[UIImageView alloc] initWithImage:IMAGE(@"item3back")];
    itemBack.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + gapHeight )* 3);
    [scrollView addSubview:itemBack];
    
    height += 5;
    UIView *activeView = [[UIView alloc] initWithFrame:CGRectMake(15, height, SCREEN_WIDTH - 30, conHeight)];
    activeView.backgroundColor = [UIColor whiteColor];
    _activeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_activeLabel setFont:FONT(14.f)];
    [_activeLabel setTextAlignment:NSTextAlignmentRight];
    _activeLabel.text = @"活动时间:";
    [activeView addSubview:_activeLabel];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(activeDayPress:)];
    [activeView addGestureRecognizer:singleFinterTap];
    
    _activeDayLabels = [[UILabel alloc] initWithFrame:CGRectMake(fieldStart - 10, 0, fieldWith, conHeight)];
    [_activeDayLabels setFont:FONT(14.f)];
    [_activeDayLabels setTextAlignment:NSTextAlignmentLeft];
    [activeView addSubview:_activeDayLabels];
    [scrollView addSubview:activeView];
    
    arrowImage = [[UIImageView alloc] initWithImage:IMAGE(@"arrow")];
    arrowImage.frame  = CGRectMake(fieldStart + fieldWith + 15, height, 10, conHeight);
    [scrollView addSubview:arrowImage];
    
    height = height + conHeight + gapHeight;
    
    UIView *zoneView = [[UIView alloc] initWithFrame:CGRectMake(15, height, SCREEN_WIDTH - 30, conHeight)];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zonePress:)];
    [zoneView addGestureRecognizer:singleFinterTap];
    
    _zoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_zoneLabel setFont:FONT(14.f)];
    [_zoneLabel setTextAlignment:NSTextAlignmentRight];
    _zoneLabel.text = @"活动区域:";
    [zoneView addSubview:_zoneLabel];
    
    _zoneText = [[UILabel alloc] initWithFrame:CGRectMake(fieldStart - 10, 0, fieldWith, conHeight)];
    _zoneText.font = FONT(14.f);
    _zoneText.textAlignment = NSTextAlignmentLeft;
    [zoneView addSubview:_zoneText];
    [scrollView addSubview:zoneView];
    
    arrowImage = [[UIImageView alloc] initWithImage:IMAGE(@"arrow")];
    arrowImage.frame  = CGRectMake(fieldStart + fieldWith + 15, height, 10, conHeight);
    [scrollView addSubview:arrowImage];
    
    height = height + conHeight + gapHeight;
    UIView *stadiumView = [[UIView alloc] initWithFrame:CGRectMake(15, height, SCREEN_WIDTH - 30, conHeight)];
    
    singleFinterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stadiumPress:)];
    [stadiumView addGestureRecognizer:singleFinterTap];

    _stadiumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, conHeight)];
    [_stadiumLabel setFont:FONT(14.f)];
    [_stadiumLabel setTextAlignment:NSTextAlignmentRight];
    _stadiumLabel.text = @"主场:";
    [stadiumView addSubview:_stadiumLabel];
    
    _stadiumText = [[UILabel alloc] initWithFrame:CGRectMake(fieldStart - 10, 0, fieldWith, conHeight)];
    _stadiumText.font = FONT(14.f);
    _stadiumText.textAlignment = NSTextAlignmentLeft;
    [stadiumView addSubview:_stadiumText];
    [scrollView addSubview:stadiumView];
    
    arrowImage = [[UIImageView alloc] initWithImage:IMAGE(@"arrow")];
    arrowImage.frame  = CGRectMake(fieldStart + fieldWith + 15, height, 10, conHeight);
    [scrollView addSubview:arrowImage];
    
     height = height + conHeight + gapHeight * 2;
    itemBack = [[UIImageView alloc] initWithImage:IMAGE(@"item2back")];
    itemBack.frame = CGRectMake(10, height, SCREEN_WIDTH - 20, (conHeight + 5) * 2 + gapHeight);
    [scrollView addSubview:itemBack];
    
    height += 5;
     _sponsorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, labelWidth, conHeight)];
     [_sponsorLabel setFont:FONT(14.f)];
     [_sponsorLabel setTextAlignment:NSTextAlignmentRight];
     _sponsorLabel.text = @"赞助商:";
     [scrollView addSubview:_sponsorLabel];
    
    _sponsorField = [[UITextField alloc] initWithFrame:CGRectMake(fieldStart, height, fieldWith + 30, conHeight)];
    _sponsorField.borderStyle = UITextBorderStyleRoundedRect;
    _sponsorField.autocorrectionType = UITextAutocorrectionTypeNo;
    _sponsorField.placeholder = @"";
    _sponsorField.returnKeyType = UIReturnKeyDone;
    _sponsorField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _sponsorField.font = FONT(14.f);
    _sponsorField.delegate = self;
    [scrollView addSubview:_sponsorField];
    
    height = height + conHeight + gapHeight;
    _noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, labelWidth, conHeight)];
    [_noteLabel setFont:FONT(14.f)];
    [_noteLabel setTextAlignment:NSTextAlignmentRight];
    _noteLabel.text = @"简介:";
    [scrollView addSubview:_noteLabel];
    
    _noteField = [[UITextField alloc] initWithFrame:CGRectMake(fieldStart, height, fieldWith + 30, conHeight)];
    _noteField.borderStyle = UITextBorderStyleRoundedRect;
    _noteField.autocorrectionType = UITextAutocorrectionTypeNo;
    _noteField.returnKeyType = UIReturnKeyDone;
    _noteField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _noteField.font = FONT(14.f);
    _noteField.delegate = self;
    [scrollView addSubview:_noteField];
    
    
    height = height + 100 + gapHeight;
    _createButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_createButton setBackgroundColor:[UIColor ggaThemeColor]];
    [_createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _createButton.frame = CGRectMake(gapWidth, height, SCREEN_WIDTH - gapWidth * 2, 48);
    if (IOS_VERSION >= 7.0)
    {
        _createButton.layer.cornerRadius = 8;
    }
    [_createButton addTarget:self action:@selector(createButtonPressed) forControlEvents:UIControlEventTouchDown];
    [_createButton setTitle:@"创建俱乐部" forState:UIControlStateNormal];
    [scrollView addSubview:_createButton];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma Events
- (void)backToPage:(id)sender
{
    ggaAppDelegate *app = APP_DELEGATE;
    [app.ggaNav popViewControllerAnimated:YES];
}

#pragma Events
- (void)activeDayPress:(UITapGestureRecognizer *)recognizer
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[WeekSelectController  sharedInstance] animated:YES];
}

- (void)zonePress:(UITapGestureRecognizer *)recognizer
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[ZoneSelectController alloc] initWithCityIndex:_cityID] animated:YES];
}

- (void)stadiumPress:(UITapGestureRecognizer *)recognizer
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[[StadiumSelectController alloc] initWithDelegate:self] animated:YES];
}

- (void)cityClick:(UITapGestureRecognizer *)recognizer
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav pushViewController:[CitySelectController sharedInstanceWithDelegate:self] animated:YES];

}

- (void)thumbImagePicker:(UITapGestureRecognizer *)recognizer
{
    if (![NetworkManager sharedInstance].internetActive)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"NETWORK_INVALID")];
        return;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        [AlertManager AlertWithMessage:@"不能转送相机照片"];
        return;
    }
    thumbImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    thumbImagePicker.delegate = (id)self;
    //    imagePicker.allowsEditing = YES;
    [self presentViewController:thumbImagePicker animated:YES completion:nil];
}

#pragma UIImagePickerController
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:@"public.image"])
    {
        UIImage *image = picker.allowsEditing ?
        [info objectForKey:UIImagePickerControllerEditedImage] :
        [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
        [[NSUserDefaults standardUserDefaults] setValue:imageData forKey:@"UPLOADFILE_DATA"];
//        [[NSUserDefaults standardUserDefaults] setValue:record.dingdanno forKeyPath:@"UPLOADFILE_DID"];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma Events
- (void)createButtonPressed
{
    _nameStr = _nameTField.text;
    _establishDayStr = _establishDayText.text;
    _sponsorStr = _sponsorField.text;
    _noteStr = _noteField.text;
    _activeTimeStr= _activeLabel.text;
    
//    if (_establishDayStr == nil || [_establishDayStr isEqual:@""])
//    {
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        formatter.dateFormat = @"MM/DD/YYYY";
//        _establishDayStr = [formatter stringFromDate:[NSDate ]
//    }
    
    if ([_nameStr isEqual:@""]){
        [AlertManager AlertWithMessage:@"name invalid"];
        return;
    }
    if ([_establishDayStr isEqual:@""]){
        [AlertManager AlertWithMessage:@"day invalid"];
        return;
    }
    if ([_cityText.text isEqual:@""]){
        [AlertManager AlertWithMessage:@"city invalid"];
        return;
    }
    if ([_activeLabel.text isEqual:@""]){
        [AlertManager AlertWithMessage:@"activeTime invalid"];
        return;
    }
    if ([_stadiumText.text isEqual:@""]){
        [AlertManager AlertWithMessage:@"stadium invalid"];
        return;
    }
    if ([_zoneText.text isEqual:@""]){
        [AlertManager AlertWithMessage:@"zone invalid"];
        return;
    }
    
    ClubListRecord *record = [[ClubListRecord alloc] initWithClubName:_nameStr imageUrl:nil city:_cityID money:0 sponsor:_sponsorStr introduction:_noteStr activeWeeks:[NSWeek intWithStringWeek:_activeTimeStr] activeArea:_zoneID stadium:_stadiumID createTime:_establishDayStr];
    
    [[HttpManager sharedInstance] createClubWithDelegate:self clubData:record];
    
}

#pragma textField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _sponsorField) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y - 75), self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }
    else if (textField == _noteField) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y - 125), self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == _sponsorField) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y + 75), self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }
    else if (textField == _noteField) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y + 125), self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }	
}


/*
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
//        CGRect frame = textInputView.frame;
//        frame.origin.y -= kbSize.height;
//        textInputView.frame = frame;
//        
//        frame = bubbleTable.frame;
//        frame.size.height -= kbSize.height;
//        bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
//        CGRect frame = textInputView.frame;
//        frame.origin.y += kbSize.height;
//        textInputView.frame = frame;
//        
//        frame = bubbleTable.frame;
//        frame.size.height += kbSize.height;
//        bubbleTable.frame = frame;
    }];
}*/

#pragma Events
- (void)establishDayClicked:(UITapGestureRecognizer *)recognizer
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Confirm", nil];
    [actionSheet showInView:self.view];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.tag = 103;
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    [actionSheet addSubview:datePicker];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:103];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    formatter.dateFormat = @"MM/dd/YYYY";
    _establishDayText.text = [formatter stringFromDate:datePicker.date];
    
}

#pragma StadiumSelectControllerDelegate
- (void)selectedStadiumWithIndex:(int)index
{
    [Common BackToPage];
    _stadiumText.text = [[STADIUMS objectAtIndex:index] objectForKey:@"stadium_name"];
    _stadiumID = [[[STADIUMS objectAtIndex:index] valueForKey:@"stadium_id"] intValue];
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
    if (error_code > 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:error_code])];
    }else
    {
        [AlertManager AlertWithMessage:@"OK"];
        [CLUBS addObject:club];
        [ADMINCLUBS addObject:club];
    }
    
}
    
@end
