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
#import "Constants.h"
#import "HttpRequest.h"

@class CreatingClubController;
CreatingClubController *gCreatingClubController;

@interface CreatingClubController : UIViewController<UITextFieldDelegate, UIActionSheetDelegate, UITextViewDelegate, StadiumSelectControllerDelegate, CitySelectControllerDelegate, HttpManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    CGFloat viewHeight;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *clubImage;

@property (nonatomic, strong) UITextField *nameTField;

@property (nonatomic, strong) UILabel *establishDayLabel;
@property (nonatomic, strong) UILabel *establishDayText;
@property (nonatomic, strong) UILabel *establishDayIcon;
@property (nonatomic, strong) UIDatePicker *datepicker;
@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, strong) UILabel *cityText;
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UILabel *cityIcon;

@property (nonatomic, strong) UITextView *sponsorField;
@property (nonatomic, strong) UILabel *sponsorLabel;

@property (nonatomic, strong) UITextView *noteField;
@property (nonatomic, strong) UILabel *noteLabel;

@property (nonatomic, strong) UILabel *activeDayLabels;
@property (nonatomic, strong) UILabel *activeLabel;

@property (nonatomic, strong) UILabel *stadiumAreaText;
@property (nonatomic, strong) UILabel *stadiumAreaLabel;

@property (nonatomic, strong) UITextView *stadiumAddrText;
@property (nonatomic, strong) UILabel *stadiumAddrLabel;

@property (nonatomic, strong) UILabel *zoneText;
@property (nonatomic, strong) UILabel *zoneLabel;

@property (nonatomic, strong) UIButton *createButton;

@property NSString *establishDayStr;
@property NSString *nameStr;
@property NSInteger cityID;
@property NSString *sponsorStr;
@property NSString *noteStr;
@property NSString *activeTimeStr;
@property NSInteger stadiumAreaID;
@property NSString *stadiumAddrStr;
@property NSString *zoneIDs;

@property(nonatomic, weak) id<HttpManagerDelegate> delegate;

+ (CreatingClubController *)sharedInstance;

@end
