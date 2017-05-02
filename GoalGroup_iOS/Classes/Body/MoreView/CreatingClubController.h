//
//  CreatingClubController.h
//  GoalGroup
//
//  Created by KCHN on 2/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StadiumSelectController.h"
#import "CitySelectController.h"
#import "HttpManager.h"

@class CreatingClubController;
CreatingClubController *gCreatingClubController;

@interface CreatingClubController : UIViewController<UITextFieldDelegate, UIActionSheetDelegate, StadiumSelectControllerDelegate, CitySelectControllerDelegate, HttpManagerDelegate>

@property (nonatomic, strong) UIImageView *clubImage;

@property (nonatomic, strong) UITextField *nameTField;

@property (nonatomic, strong) UILabel *establishDayLabel;
@property (nonatomic, strong) UILabel *establishDayText;

@property (nonatomic, strong) UILabel *cityText;
@property (nonatomic, strong) UILabel *cityLabel;

@property (nonatomic, strong) UITextField *sponsorField;
@property (nonatomic, strong) UILabel *sponsorLabel;

@property (nonatomic, strong) UITextField *noteField;
@property (nonatomic, strong) UILabel *noteLabel;

@property (nonatomic, strong) UILabel *activeDayLabels;
@property (nonatomic, strong) UILabel *activeLabel;

@property (nonatomic, strong) UILabel *stadiumText;
@property (nonatomic, strong) UILabel *stadiumLabel;

@property (nonatomic, strong) UILabel *zoneText;
@property (nonatomic, strong) UILabel *zoneLabel;

@property (nonatomic, strong) UIButton *createButton;

@property NSString *establishDayStr;
@property NSString *nameStr;
@property NSInteger cityID;
@property NSString *sponsorStr;
@property NSString *noteStr;
@property NSString *activeTimeStr;
@property NSInteger stadiumID;
@property NSInteger zoneID;

@property(nonatomic, weak) id<HttpManagerDelegate> delegate;

+ (CreatingClubController *)sharedInstance;

@end
