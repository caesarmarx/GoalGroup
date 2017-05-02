//
//  PlayerSearchConditionController.m
//  GoalGroup
//
//  Created by MacMini on 4/27/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "PlayerSearchConditionController.h"
#import "NSPosition.h"
#import "DistrictManager.h"
#import "Common.h"

@interface PlayerSearchConditionController ()
{
    NSArray *ageLabels;
    NSArray *positionLabels;
    NSArray *weekLabels;
    NSMutableArray *areaLabels;
    
    NSArray *searchLabels;
    NSArray *searchKeyLabels;
}
@end

@implementation PlayerSearchConditionController

+ (id)sharedInstance
{
    @synchronized(self)
    {
        if (gPlayerSearchConditionController == nil)
            gPlayerSearchConditionController = [[PlayerSearchConditionController alloc] init];
    }
    return gPlayerSearchConditionController;
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

- (void)removeSearchConditions
{
    [condition removeAllObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    _AgeKey = @"Ages";
    _PositionKey = @"Positions";
    _WeekKey = @"WorkDays";
    _ActAreaKey = @"ActArea";

    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [self viewWithCondition];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutComponents
{
    _AgeCondition = @"";
    _PositionCondition = @"";
    _WeekCondition = @"";
    _ActAreaCondition = @"";
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];

    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    backImage.image = IMAGE(@"search_filter_background");
    [scrollView addSubview:backImage];
    
    UIColor * text_color = [UIColor colorWithRed:152/255.f green:152/255.f blue:152/255.f alpha:1.f];
    UIColor * color = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
    
    _searchCondAgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 300, 20)];
    [_searchCondAgeLabel setTextColor:[UIColor whiteColor]];
    [_searchCondAgeLabel setBackgroundColor:color];
    _searchCondAgeLabel.numberOfLines = 1;
    [scrollView addSubview:_searchCondAgeLabel];
    
    NSInteger h =  40;
    
    _searchCondPositionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60 + h, 300, 20)];
    _searchCondPositionLabel.numberOfLines = 1;
    [_searchCondPositionLabel setBackgroundColor:color];
    [_searchCondPositionLabel setTextColor:[UIColor whiteColor]];
    [scrollView addSubview:_searchCondPositionLabel];
    
    _searchCondWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 155 + h, 300, 20)];
    _searchCondWeekLabel.numberOfLines = 1;
    [_searchCondWeekLabel setBackgroundColor:color];
    [_searchCondWeekLabel setTextColor:[UIColor whiteColor]];
    [scrollView addSubview:_searchCondWeekLabel];
    
    _searchCondAreaLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 250 + h, 300, 20)];
    [_searchCondAreaLabel setBackgroundColor:color];
    [_searchCondAreaLabel setTextColor:[UIColor whiteColor]];
    [scrollView addSubview:_searchCondAreaLabel];
    
    
    //年龄区间（18岁以下、18-25、26-33、34-41、42-49、50以上）、
    _ageLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 5 + h, 80, 20)];
    [_ageLabel1 setBackgroundColor:color];
    [_ageLabel1 setTextColor:text_color];
    _ageLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 5 + h, 45, 20)];
    [_ageLabel2 setBackgroundColor:color];
    [_ageLabel2 setTextColor:text_color];
    
    _ageLabel3= [[UILabel alloc] initWithFrame:CGRectMake(155, 5 + h, 45, 20)];
    [_ageLabel3 setBackgroundColor:color];
    [_ageLabel3 setTextColor:text_color];
    
    _ageLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(210, 5 + h, 45, 20)];
    [_ageLabel4 setBackgroundColor:color];
    [_ageLabel4 setTextColor:text_color];
    
    _ageLabel5 = [[UILabel alloc] initWithFrame:CGRectMake(265, 5 + h, 45, 20)];
    [_ageLabel5 setBackgroundColor:color];
    [_ageLabel5 setTextColor:text_color];
    
    _ageLabel6 = [[UILabel alloc] initWithFrame:CGRectMake(20, 25 + h, 60, 20)];
    [_ageLabel6 setBackgroundColor:color];
    [_ageLabel6 setTextColor:text_color];
    [_ageLabel1 setText:[NSString stringWithFormat:@"18%@%@",LANGUAGE(@"AGE"),LANGUAGE(@"LESSTHAN")]];
    [_ageLabel2 setText:@"18-25"];
    [_ageLabel3 setText:@"26-33"];
    [_ageLabel4 setText:@"34-41"];
    [_ageLabel5 setText:@"42-49"];
    [_ageLabel6 setText:[NSString stringWithFormat:@"50%@",LANGUAGE(@"MORETHAN")]];
    [scrollView addSubview:_ageLabel1];
    [scrollView addSubview:_ageLabel2];
    [scrollView addSubview:_ageLabel3];
    [scrollView addSubview:_ageLabel4];
    [scrollView addSubview:_ageLabel5];
    [scrollView addSubview:_ageLabel6];
    
    //场上位置（前锋、中场、后卫、门将）、
    _positionLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 100 + h, 35, 20)];
    _positionLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(70, 100 + h, 35, 20)];
    _positionLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(115, 100 + h, 35, 20)];
    _positionLabel4= [[UILabel alloc] initWithFrame:CGRectMake(160, 100 + h, 35, 20)];
    
    [_positionLabel1 setBackgroundColor:color];
    [_positionLabel2 setBackgroundColor:color];
    [_positionLabel3 setBackgroundColor:color];
    [_positionLabel4 setBackgroundColor:color];
    
    [_positionLabel1 setTextColor:text_color];
    [_positionLabel2 setTextColor:text_color];
    [_positionLabel3 setTextColor:text_color];
    [_positionLabel4 setTextColor:text_color];
    
    [_positionLabel1 setText:LANGUAGE(@"ClubMemberController_Forward")];
    [_positionLabel2 setText:LANGUAGE(@"MIDDLE_YARD")];
    [_positionLabel3 setText:LANGUAGE(@"ClubMemberController_Defence")];
    [_positionLabel4 setText:LANGUAGE(@"ClubMemberController_label_1")];
    [scrollView addSubview:_positionLabel1];
    [scrollView addSubview:_positionLabel2];
    [scrollView addSubview:_positionLabel3];
    [scrollView addSubview:_positionLabel4];
    
    //活动时间（周一至周日）、
    _weekLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(25, 180 + h, 40, 20)];
    _weekLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(70, 180 + h, 40, 20)];
    _weekLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(115, 180 + h, 40, 20)];
    _weekLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(165, 180 + h, 40, 20)];
    _weekLabel5 = [[UILabel alloc] initWithFrame:CGRectMake(210, 180 + h, 40, 20)];
    _weekLabel6 = [[UILabel alloc] initWithFrame:CGRectMake(255, 180 + h, 40, 20)];
    _weekLabel7 = [[UILabel alloc] initWithFrame:CGRectMake(25, 200 + h, 40, 20)];
    [_weekLabel1 setBackgroundColor:color];
    [_weekLabel2 setBackgroundColor:color];
    [_weekLabel3 setBackgroundColor:color];
    [_weekLabel4 setBackgroundColor:color];
    [_weekLabel5 setBackgroundColor:color];
    [_weekLabel6 setBackgroundColor:color];
    [_weekLabel7 setBackgroundColor:color];
    
    [_weekLabel1 setTextColor:text_color];
    [_weekLabel2 setTextColor:text_color];
    [_weekLabel3 setTextColor:text_color];
    [_weekLabel4 setTextColor:text_color];
    [_weekLabel5 setTextColor:text_color];
    [_weekLabel6 setTextColor:text_color];
    [_weekLabel7 setTextColor:text_color];
    
    [_weekLabel1 setText:LANGUAGE(@"week_mon")];
    [_weekLabel2 setText:LANGUAGE(@"week_tue")];
    [_weekLabel3 setText:LANGUAGE(@"week_web")];
    [_weekLabel4 setText:LANGUAGE(@"week_thu")];
    [_weekLabel5 setText:LANGUAGE(@"week_fri")];
    [_weekLabel6 setText:LANGUAGE(@"week_sat")];
    [_weekLabel7 setText:LANGUAGE(@"week_sun")];
    [scrollView addSubview:_weekLabel1];
    [scrollView addSubview:_weekLabel2];
    [scrollView addSubview:_weekLabel3];
    [scrollView addSubview:_weekLabel4];
    [scrollView addSubview:_weekLabel5];
    [scrollView addSubview:_weekLabel6];
    [scrollView addSubview:_weekLabel7];
    //活动区域（大连各个区）
    
    areaLabels = [[NSMutableArray alloc] init];
    
    int x = 25;
    int y = 0;
    for (NSDictionary *area in [[DistrictManager sharedInstance] districtsWithCityIndex:curCityID]) {
        CGSize size = [[area valueForKey:@"district"] sizeWithFont:FONT(20.f) constrainedToSize:CGSizeMake(SCREEN_WIDTH, 20)];
        
        if (x + size.width > SCREEN_WIDTH - 20)
        {
            x = 25;
            y += 20;
        }
        
        UILabel *_areaLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(x, 280 + y + h, size.width, 20)];
        [_areaLabel1 setBackgroundColor:color];
        [_areaLabel1 setTextColor:text_color];
        [_areaLabel1 setText:[area valueForKey:@"district"]];
        [scrollView addSubview:_areaLabel1];
        
        x += size.width;
        
        UITapGestureRecognizer *tapgestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
        [_areaLabel1 addGestureRecognizer:tapgestureRecog1];
        _areaLabel1.userInteractionEnabled = YES;
        
        [areaLabels addObject:_areaLabel1];
    }
    
    
    //add Event
    UITapGestureRecognizer *gestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    UITapGestureRecognizer *gestureRecog2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    UITapGestureRecognizer *gestureRecog3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    UITapGestureRecognizer *gestureRecog4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    UITapGestureRecognizer *gestureRecog5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    UITapGestureRecognizer *gestureRecog6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    
    [_ageLabel1 addGestureRecognizer:gestureRecog1];
    [_ageLabel2 addGestureRecognizer:gestureRecog2];
    [_ageLabel3 addGestureRecognizer:gestureRecog3];
    [_ageLabel4 addGestureRecognizer:gestureRecog4];
    [_ageLabel5 addGestureRecognizer:gestureRecog5];
    [_ageLabel6 addGestureRecognizer:gestureRecog6];
    
    _ageLabel1.userInteractionEnabled = YES;
    _ageLabel2.userInteractionEnabled = YES;
    _ageLabel3.userInteractionEnabled = YES;
    _ageLabel4.userInteractionEnabled = YES;
    _ageLabel5.userInteractionEnabled = YES;
    _ageLabel6.userInteractionEnabled = YES;
    
    gestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    [_positionLabel1 addGestureRecognizer:gestureRecog1];
    _positionLabel1.userInteractionEnabled = YES;
    
    gestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    [_positionLabel2 addGestureRecognizer:gestureRecog1];
    _positionLabel2.userInteractionEnabled = YES;
    
    gestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    [_positionLabel3 addGestureRecognizer:gestureRecog1];
    _positionLabel3.userInteractionEnabled = YES;
    
    gestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    [_positionLabel4 addGestureRecognizer:gestureRecog1];
    _positionLabel4.userInteractionEnabled = YES;
    
    
    gestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    [_weekLabel1 addGestureRecognizer:gestureRecog1];
    _weekLabel1.userInteractionEnabled = YES;
    gestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    [_weekLabel2 addGestureRecognizer:gestureRecog1];
    _weekLabel2.userInteractionEnabled = YES;
    gestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    [_weekLabel3 addGestureRecognizer:gestureRecog1];
    _weekLabel3.userInteractionEnabled = YES;
    gestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    [_weekLabel4 addGestureRecognizer:gestureRecog1];
    _weekLabel4.userInteractionEnabled = YES;
    gestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    [_weekLabel5 addGestureRecognizer:gestureRecog1];
    _weekLabel5.userInteractionEnabled = YES;
    gestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    [_weekLabel6 addGestureRecognizer:gestureRecog1];
    _weekLabel6.userInteractionEnabled = YES;
    gestureRecog1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelect:)];
    [_weekLabel7 addGestureRecognizer:gestureRecog1];
    _weekLabel7.userInteractionEnabled = YES;
    
    
    ageLabels = [NSArray arrayWithObjects:_ageLabel1, _ageLabel2, _ageLabel3, _ageLabel4, _ageLabel5, _ageLabel6, nil];
    positionLabels = [NSArray arrayWithObjects:_positionLabel1, _positionLabel2, _positionLabel3, _positionLabel4, nil];
    weekLabels = [NSArray arrayWithObjects:_weekLabel1,_weekLabel2,_weekLabel3,_weekLabel4,_weekLabel5,_weekLabel6,_weekLabel7, nil];
    searchLabels = [NSArray arrayWithObjects:ageLabels, positionLabels, weekLabels, areaLabels,nil];
    
    searchKeyLabels = [NSArray arrayWithObjects:_AgeCondition, _PositionCondition, _WeekCondition, _ActAreaCondition, nil];
    
    //Button's event
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    int nButtonY = (y + h + 280 + 20 + 60 + 40);
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, nButtonY > SCREEN_HEIGHT? nButtonY : SCREEN_HEIGHT);
    
    _cancelButton.frame =  CGRectMake(30, 400, 110, 40);
    [_cancelButton setTitle:LANGUAGE(@"cancel") forState:UIControlStateNormal];
    [scrollView addSubview:_cancelButton];
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"search_cancel"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(doCancel:) forControlEvents:UIControlEventTouchDown];
    
    _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _okButton.frame =  CGRectMake(177, 400, 110, 40);
    [_okButton setTitle:LANGUAGE(@"yes") forState:UIControlStateNormal];
    [scrollView addSubview:_okButton];
    [_okButton setBackgroundImage:[UIImage imageNamed:@"search_cancel"] forState:UIControlStateNormal];
    [_okButton addTarget:self action:@selector(doSearch:) forControlEvents:UIControlEventTouchDown];
    
    [_searchCondAgeLabel setText:LANGUAGE(@"SEARCH_COND_AGE")];
    [_searchCondAreaLabel setText:LANGUAGE(@"SEARCH_COND_AREA")];
    [_searchCondWeekLabel setText:LANGUAGE(@"SEARCH_COND_WEEK")];
    [_searchCondPositionLabel setText:LANGUAGE(@"POSITION")];

}

- (IBAction)doSelect:(UITapGestureRecognizer *) gesture
{
    
    UILabel * lbl = (UILabel *)gesture.view;
    UILabel *beforelbl;
    
    BOOL labelSelected = NO;
    CGFloat red = 0.0f, blue = 0.0f, green = 0.0f, alpha = 0.0f;
    
    for (UILabel *selLabel in [searchLabels objectAtIndex:0])
    {
        [selLabel.textColor getRed:&red green:&green blue:&blue alpha:&alpha];
        
        if (blue <= 0.5f)
            beforelbl = selLabel;
        if ([lbl isEqual:selLabel])
            labelSelected = YES;
    }
    
    if (labelSelected) {
        if ([lbl isEqual:beforelbl])
        {
            [lbl setTextColor:[UIColor colorWithRed:152/255.f green:152/255.f blue:152/255.f alpha:1.f]];
            return;
        }
        
        for (UILabel *selLabel in [searchLabels objectAtIndex:0])
            [selLabel setTextColor:[UIColor colorWithRed:152/255.f green:152/255.f blue:152/255.f alpha:1.f]];
        [lbl setTextColor:[UIColor colorWithRed:106/255.f green:166/255.f blue:24/255.f alpha:1.f]];
        return;
    }
    
    [lbl.textColor getRed:&red green:&green blue:&blue alpha:&alpha];
    if(blue >0.5f){//non-selected ->selected
        [lbl setTextColor:[UIColor colorWithRed:106/255.f green:166/255.f blue:24/255.f alpha:1.f]];
    }else{//selected ->non
        [lbl setTextColor:[UIColor colorWithRed:152/255.f green:152/255.f blue:152/255.f alpha:1.f]];
    }

}

- (IBAction)doCancel:(id) btn{
    self.navigationController.navigationBarHidden = NO;
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}
- (IBAction)doSearch:(id) btn{
    
    @try {
        CGFloat red = 0.0f, green = 0.0f, blue = 0.0f, alpha = 0.0f;
        
        NSString *minAge = @"";
        NSString *maxAge = @"";
        NSString *activePosition = @"";
        NSString *activeTime = @"";
        NSString *activeArea = @"";
        NSString *str = @"";
        
        for (int i = 0; i < 4;  i ++)
        {
            str = [searchKeyLabels objectAtIndex:i];
            NSArray *arr = [searchLabels objectAtIndex:i];
            str = @"";
            
            for (int j = 0; j < [arr count]; j++)
            {
                UILabel *label = [arr objectAtIndex:j];
                [label.textColor getRed:&red green:&green blue:&blue alpha:&alpha];
                
                if (blue < 0.5f)
                {
                    if ([str isEqual:@""])
                        str = label.text;
                    else
                        str = [NSString stringWithFormat:@"%@,%@", str, label.text];
                }
                
            }
            
            if (i == 0)
            {
                if ([str componentsSeparatedByString:@"-"].count == 2){
                    minAge = [[str componentsSeparatedByString:@"-"] objectAtIndex:0];
                    maxAge = [[str componentsSeparatedByString:@"-"] objectAtIndex:1];
                }
                else if([str isEqualToString:[NSString stringWithFormat:@"18%@%@",LANGUAGE(@"AGE"),LANGUAGE(@"LESSTHAN")]])
                {
                    minAge = @"0";
                    maxAge = @"18";
                }
                else if ([str isEqualToString:[NSString stringWithFormat:@"50%@",LANGUAGE(@"MORETHAN")]])
                {
                    minAge = @"50";
                    maxAge = @"100";
                }
                else
                {
                    minAge= @"0";
                    maxAge = @"100";
                }
            }
            else if (i == 1)
            {
                if ([str isEqualToString:@""])
                    activePosition = @"0";//@"2047";
                else
                    activePosition = [NSString stringWithFormat:@"%ld", [NSPosition intWithStringPosition:str]];
            }
            else if (i == 2)
            {
                if ([str isEqualToString:@""])
                    activeTime = @"0";//@"127";
                else
                    activeTime = [NSString stringWithFormat:@"%ld", [NSWeek intWithStringWeek:str]];
            }
            else if (i == 3)
            {
                if ([str isEqualToString:@""])
                {
                    /*
                     //if not selected city, select all cities.
                     for (NSDictionary *item in CITYS) {
                     str = [str stringByAppendingString:[item valueForKeyPath:@"city"]];
                     str = [str stringByAppendingString:@","];
                     }
                     str = [str substringToIndex:(str.length - 1)];
                     */
                    activeArea = @"";
                }
                else
                {
                    NSArray *temp = [str componentsSeparatedByString:@","];
                    for (int ii = 0; ii < temp.count; ii ++) {
                        NSString *id = @"";
                        for (NSDictionary *area in [[DistrictManager sharedInstance] districtsWithCityIndex:curCityID])
                        {
                            if ([[area valueForKeyPath:@"district"] isEqualToString:[temp objectAtIndex:ii]]) {
                                id = [area valueForKeyPath:@"id"];
                                break;
                            }
                        }
                        
                        if ([activeArea isEqualToString:@""])
                            activeArea = [NSString stringWithFormat:@"%@", id];
                        else
                            activeArea = [NSString stringWithFormat:@"%@,%@", activeArea, id];
                    }
                }
                
            }
        }
        
        condition = [NSMutableArray arrayWithObjects:minAge, maxAge, activePosition, activeTime, activeArea, nil];
        [self.delegate playerSearchWithCondition:condition];

    }
    @catch (NSException *exception) {
        
#ifdef DEMO_MODE
        NSLog(@"%@ 검색조건오유 %@", LOGTAG, exception);
#endif
    }
    
    self.navigationController.navigationBarHidden = NO;
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

-(void)viewWithCondition
{
    if (condition && condition.count >0)
    {
        NSString *minAge = [[NSString alloc] initWithString:(NSString *)[condition objectAtIndex:0]];
        NSString *maxAge = [[NSString alloc] initWithString:(NSString *)[condition objectAtIndex:1]];
        NSString *Age = @"";
        if ([minAge isEqualToString:@"0"] && [maxAge isEqualToString:@"18"])
            Age =[NSString stringWithFormat:@"18%@%@",LANGUAGE(@"AGE"),LANGUAGE(@"LESSTHAN")];
        else if ([minAge isEqualToString:@"50"])
            Age =[NSString stringWithFormat:@"50%@",LANGUAGE(@"MORETHAN")];
        else
            Age = [NSString stringWithFormat:@"%@-%@", minAge, maxAge];
        for (UILabel *label in [searchLabels objectAtIndex:0])
        {
            if ([[label text] isEqualToString:Age])
            {
                [label setTextColor:[UIColor colorWithRed:106/255.f green:166/255.f blue:24/255.f alpha:1.f]];
            }
            else
            {
                [label setTextColor:[UIColor colorWithRed:152/255.f green:152/255.f blue:152/255.f alpha:1.f]];
            }
        }

        NSString *activePosition = [NSPosition stringPositionWithIntegerPosition:[condition[2] intValue]];
        for (UILabel *label in [searchLabels objectAtIndex:1])
        {
            if ([activePosition rangeOfString:label.text].length > 0)
            {
                [label setTextColor:[UIColor colorWithRed:106/255.f green:166/255.f blue:24/255.f alpha:1.f]];
            }
            else
            {
                [label setTextColor:[UIColor colorWithRed:152/255.f green:152/255.f blue:152/255.f alpha:1.f]];
            }
        }
        
       NSString *activeTime = [NSWeek stringWithIntegerWeek:[condition[3] intValue]];
       for (UILabel *label in [searchLabels objectAtIndex:2])
        {
            
            if ([activeTime rangeOfString:label.text].length > 0)
            {
                [label setTextColor:[UIColor colorWithRed:106/255.f green:166/255.f blue:24/255.f alpha:1.f]];
            }
            else
            {
                [label setTextColor:[UIColor colorWithRed:152/255.f green:152/255.f blue:152/255.f alpha:1.f]];
            }
        }
        
        NSString *activeArea = (NSString *)condition[4];
        for (UILabel *label in [searchLabels objectAtIndex:3])
        {
            NSString *id = @"";
            for (NSDictionary *area in [[DistrictManager sharedInstance] districtsWithCityIndex:curCityID])
            {
                NSString *district = [area valueForKey:@"district"];
                if ([district isEqualToString:label.text])
                {
                    id = [area valueForKeyPath:@"id"];
                    break;
                }
            }
            if ([activeArea rangeOfString:id].length > 0)
            {
                [label setTextColor:[UIColor colorWithRed:106/255.f green:166/255.f blue:24/255.f alpha:1.f]];
            }
            else
            {
                [label setTextColor:[UIColor colorWithRed:152/255.f green:152/255.f blue:152/255.f alpha:1.f]];
            }
        }
    }
    else
    {
        for (NSArray *labels in searchLabels)
        {
            for (UILabel *lbl in labels)
            {
                [lbl setTextColor:[UIColor colorWithRed:152/255.f green:152/255.f blue:152/255.f alpha:1.f]];
            }
        }
    }

}
@end
