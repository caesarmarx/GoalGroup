//
//  ClubSearchConditionController.h
//  GoalGroup
//
//  Created by MacMini on 4/27/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClubSearchConditionController;
ClubSearchConditionController *gClubSearchConditionController;

@protocol ClubSearchConditionControllerDeleagte <NSObject>

- (void)clubSearchWithCondition:(NSArray *)condition;
@end

@interface ClubSearchConditionController : UIViewController
{
    NSMutableArray *condition;
}

@property (nonatomic, strong) id<ClubSearchConditionControllerDeleagte> delegate;

@property (nonatomic, strong) UILabel *searchCondAreaLabel;
@property (nonatomic, strong) UILabel *searchCondWeekLabel;
@property (nonatomic, strong) UILabel *searchCondAgeLabel;

@property (nonatomic, strong) UILabel *ageLabel1;
@property (nonatomic, strong) UILabel *ageLabel2;
@property (nonatomic, strong) UILabel *ageLabel3;
@property (nonatomic, strong) UILabel *ageLabel4;
@property (nonatomic, strong) UILabel *ageLabel5;
@property (nonatomic, strong) UILabel *ageLabel6;
@property (nonatomic, strong) UILabel *weekLabel1;
@property (nonatomic, strong) UILabel *weekLabel2;
@property (nonatomic, strong) UILabel *weekLabel3;
@property (nonatomic, strong) UILabel *weekLabel4;
@property (nonatomic, strong) UILabel *weekLabel5;
@property (nonatomic, strong) UILabel *weekLabel6;
@property (nonatomic, strong) UILabel *weekLabel7;
@property (nonatomic, strong) NSString *AgeKey;
@property (nonatomic, strong) NSString *WeekKey;
@property (nonatomic, strong) NSString *ActAreaKey;

@property (nonatomic, strong) NSString *AgeCondition;
@property (nonatomic, strong) NSString *WeekCondition;
@property (nonatomic, strong) NSString *ActAreaCondition;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *okButton;

+ (id) sharedInstance;
- (void) viewWithCondition;
- (void) removeSearchConditions;

@end
