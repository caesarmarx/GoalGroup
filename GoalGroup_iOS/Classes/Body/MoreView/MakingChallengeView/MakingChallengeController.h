//
//  MakingChallengeController.h
//  GoalGroup
//
//  Created by KCHN on 2/8/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpenseSelectController.h"
#import "PlayerCountSelectController.h"
#import "RefereeSelectController.h"
#import "TeamSelectController.h"
#import "StadiumSelectController.h"
#import "ChallengeListRecord.h"
#import "HttpManager.h"


#define CHALLENGEMODE_DIRECT_CHALLEGNE    0
#define CHALLENGEMODE_DIRECT_NOTICE       1
#define CHALLENGEMODE_GAME_EDITING        2

#define CREATINGMODE_CREATING       0
#define CREATINGMODE_EDITING        1

@class MakingChallengeController;
MakingChallengeController *gMakingChallengeController;

@interface MakingChallengeController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, ExpenseSelectControllerDelegate, PlayerCountSelectControllerDelegate, RefereeSelectControllerDelegate, TeamSelectControllerDelegate, StadiumSelectControllerDelegate, HttpManagerDelegate, UITextViewDelegate, UIAlertViewDelegate>
{
    NSInteger sheetMode;
    NSArray *buttons;
    UIScrollView *scrollView;
}

@property (nonatomic, strong) UILabel *challengeNameLabel;
@property (nonatomic, strong) UILabel *challengeNameText;

@property (nonatomic, strong) UILabel *inviteNameLabel;
@property (nonatomic, strong) UILabel *inviteNameText;

@property (nonatomic, strong) UITextField *inviteNameTextField;

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *dateText;

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *timeText;

@property (nonatomic, strong) UILabel *stadiumAreaLabel;
@property (nonatomic, strong) UILabel *stadiumAreaText;

@property (nonatomic, strong) UILabel *stadiumAddrLabel;
@property (nonatomic, strong) UITextView *stadiumAddrText;

@property (nonatomic, strong) UILabel *membersLabel;
@property (nonatomic, strong) UILabel *membersText;

@property (nonatomic, strong) UILabel *refNeccLabel;
@property (nonatomic, strong) UILabel *refNeccText;

@property (nonatomic, strong) UILabel *expenseLabel;
@property (nonatomic, strong) UILabel *expenseText;

@property (nonatomic, strong) UIButton *challengeButton;

@property (nonatomic, strong) UILabel *establishDayLabel;
@property (nonatomic, strong) UILabel *establishDayText;
@property (nonatomic, strong) UILabel *establishDayIcon;
@property (nonatomic, strong) UIDatePicker *datepicker;
@property (nonatomic, strong) UIToolbar *toolbar;

@property int challengeMode;
@property int creatingMode;
@property int gameID;

@property NSString *challengeTeam;
@property int challengeTeamID;
@property NSString *inviteTeam;
@property int inviteTeamID;
@property NSString *challengeDate;
@property NSString *challengeTime;
@property int members;
@property NSString *stadiumArea;
@property NSString *stadiumAddr;
@property int stadium_id;
@property BOOL refNecc;
@property int expenseMode;

@property int nRoomID;
@property int nGameType;

//Challenge
- (id)initWithChallengeTeam;

//Notice
- (id)initWithNoticeTeam:(int)team name:(NSString *)name;

//GameCreating
- (id)initWithGameEditMode:(int)team;

//Challenge, Notice, Schedule Editing
- (id)initWithGameEditModeInExisting:(ChallengeListRecord *)record withType:(int)type room:(int)roomID gameID:(int)gameID gameType:(int)gameType sendGame:(BOOL)sendgame;
@end
