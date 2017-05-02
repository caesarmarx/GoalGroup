//
//  ClubDetailController.h
//  GoalGroup
//
//  Created by KCHN on 2/12/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"
#import "StadiumSelectController.h"
#import "ZoneSelectController.h"
#import "CitySelectController.h"
#import "DistrictManager.h"


@class ClubDetailController;
ClubDetailController *gClubDetailController;

@interface ClubDetailController : UIViewController<UITextFieldDelegate, UITextViewDelegate, HttpManagerDelegate, CitySelectControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
{
    int nClubID;
    int nUserType;
    NSString *zoneIDs;
    int cityID;
    int stadiumAreaID;
    NSString *stadiumAddrStr;
    
    BOOL fromClubCenter;
}

@property (nonatomic, strong) UIImageView *clubImage;
@property (nonatomic, strong) UITextField *clubNameField;
@property (nonatomic, strong) UILabel *activeLabel;
@property (nonatomic, strong) UILabel *establishLabel;
@property (nonatomic, strong) UILabel *establishText;
@property (nonatomic, strong) UIDatePicker *datepicker;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UILabel *cityText;
@property (nonatomic, strong) UILabel *activeTimeLabel;
@property (nonatomic, strong) UILabel *activeTimeText;
@property (nonatomic, strong) UILabel *sponsorLabel;
@property (nonatomic, strong) UITextView *sponsorText;
@property (nonatomic, strong) UILabel *zoneLabel;
@property (nonatomic, strong) UILabel *zoneText;
@property (nonatomic, strong) UILabel *stadiumAreaLabel;
@property (nonatomic, strong) UILabel *stadiumAreaText;
@property (nonatomic, strong) UILabel *stadiumAddrLabel;
@property (nonatomic, strong) UITextView *stadiumAddrText;
@property (nonatomic, strong) UILabel *introLabel;
@property (nonatomic, strong) UITextView *introText;
@property (nonatomic, strong) UILabel *honorLabel;
@property (nonatomic, strong) UILabel *honorText;
@property (nonatomic, strong) UILabel *marksText;
@property (nonatomic, strong) UILabel *memberLabel;
@property (nonatomic, strong) UILabel *memberText;

@property (nonatomic, strong) UIImageView *marksArrowView;
@property (nonatomic, strong) UIImageView *memberArrowView;

+ (ClubDetailController *) sharedInstance;
- (id)initWithClub:(int)club fromClubCenter:(BOOL)center;
@end
