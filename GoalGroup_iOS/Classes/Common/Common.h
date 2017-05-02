//
//  Common.h
//
//  Created by JinYongHao on 9/25/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ggaAppDelegate.h"
#import "UIColor+User.h"
#import "UIImage+Web.h"
#import "UIImage+Mask.h"
#import "NSString+MD5.h"
#import "Language.h"
#import "NSWeek.h"
#import "LoginManager.h"
#import "FileManager.h"
#import "CacheManager.h"
#import "AlertManager.h"
#import "NetworkManager.h"
#import "ChallengeListRecord.h"
#import "ClubListRecord.h"
#import "DiscussListRecord.h"
#import "DemandListRecord.h"
#import "PlayerListRecord.h"
#import "ClubManager.h"
#import "LBorderView.h"
#import "Constants.h"
#import "CustomValidation.h"

#define DEMO_MODE

#ifdef DEMO_MODE
#define RANDOM_INT(from, to)            (rand()%to + from)
#define RANDOM_FLOAT(from, to)          (((arc4random()%RAND_MAX) / (RAND_MAX * 1.0)) * (to - from) + from)
#endif

#define SERVER_PREFIX_URL               [NSString stringWithFormat:@"http://%@:%d/", SERVER_IP_ADDRESS, _PORT]
#define NEWORDER_CHECK_TIME_INTERVAL    300

NSString                        *MyDeviceToken;
NSString                        *USERPHOTO;
NSString                        *lastUpdateTime;
NSString                        *USERNAME;
NSString                        *sUID;
NSString                        *YourUIDForNotification;
NSString                        *curSystemTimeStr;

int                             UID;
int                             nInvCount;
int                             nTempInvCount;
int                             nNewsCount;

NSArray                         *STADIUMS;
NSArray                         *CITYS;
NSString                        *DEFAULT_CITY_NAME;
int                             DEFAULT_CITY_ID;
NSMutableArray                  *DISTRICTS;
int                             curCityID;
int                             OPTIONS;

int                             nCurChattingRoom;
BOOL                            bIsChatting;

int                             uidForRemoteNotification;
int                             roomIDForRemoteNotification;
NSString                        *msgForRemoteNotification;
NSString                        *nameForRemoteNotification;
NSString                        *userPhotoForRemoteNotification;
NSString                        *timeForRemoteNotification;
int                             typeForRemoteNotification;

BOOL                            userRegisteredSuccessfully;
BOOL                            sentAllUnsendMsg;
NSDictionary                    *savedNotification;

//#define REMOTE_NOTIFICATION_DEMO

#define IOS_VERSION             [[[UIDevice currentDevice] systemVersion] floatValue]
#define IOS_VERSION_7
#define APP_DELEGATE            (ggaAppDelegate *)[[UIApplication sharedApplication] delegate]
#define SCREEN_WIDTH            [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT           [[UIScreen mainScreen] bounds].size.height
#define LANGUAGE(key)           [Language GetStringByKey:key]
#define IMAGE(key)              [UIImage imageNamed:key]
#define FONT(key)               [UIFont systemFontOfSize:key]
#define BOLDFONT(key)           [UIFont boldSystemFontOfSize:key]
#define ADMINOFCLUB(club)       [[ClubManager sharedInstance] checkAdminClub:club]
#define MEMBEROFCLUB(club)      [[ClubManager sharedInstance] checkMyClub:club]
#define CURRENT_DATE            [NSDate date]
#define CHATENABLE              [[Chat sharedInstance] chatEnable]
#define APPVERSION              [Common appNameAndVersionNumberDisplayString]
#define DAYS                    [NSArray arrayWithObjects: LANGUAGE(@"week_mon"), LANGUAGE(@"week_tue"), LANGUAGE(@"week_web"), LANGUAGE(@"week_thu"), LANGUAGE(@"week_fri"), LANGUAGE(@"week_sat"), LANGUAGE(@"week_sun"), nil]
#define DAYSDI                    [NSArray arrayWithObjects: LANGUAGE(@"week_sun"), LANGUAGE(@"week_mon"), LANGUAGE(@"week_tue"), LANGUAGE(@"week_web"), LANGUAGE(@"week_thu"), LANGUAGE(@"week_fri"), LANGUAGE(@"week_sat"), nil]
#define DETAILPOSITIONS         [NSArray arrayWithObjects:LANGUAGE(@"DETAILPOSITIONS_1"), LANGUAGE(@"DETAILPOSITIONS_2"),LANGUAGE(@"DETAILPOSITIONS_3"), LANGUAGE(@"DETAILPOSITIONS_4"), LANGUAGE(@"DETAILPOSITIONS_5"), LANGUAGE(@"DETAILPOSITIONS_6"), LANGUAGE(@"DETAILPOSITIONS_7"), LANGUAGE(@"DETAILPOSITIONS_8"), LANGUAGE(@"DETAILPOSITIONS_9"), LANGUAGE(@"DETAILPOSITIONS_10"), LANGUAGE(@"ClubMemberController_label_1"), nil]
#define POSITIONS               [NSArray arrayWithObjects:LANGUAGE(@"ClubMemberController_Forward"), LANGUAGE(@"ClubMemberController_Forward"), LANGUAGE(@"ClubMemberController_Forward"), LANGUAGE(@"MIDDLE_YARD"), LANGUAGE(@"MIDDLE_YARD"), LANGUAGE(@"MIDDLE_YARD"), LANGUAGE(@"MIDDLE_YARD"), LANGUAGE(@"ClubMemberController_Defence"), LANGUAGE(@"ClubMemberController_Defence"), LANGUAGE(@"ClubMemberController_Defence"), LANGUAGE(@"ClubMemberController_label_1"), nil]
#define ADMINCLUBCOUNT          [[ClubManager sharedInstance] countsAdminClub]
#define CLUBCOUNT               [[ClubManager sharedInstance] countsClubs]
#define ADMINCLUBS              [[ClubManager sharedInstance] adminClub]
#define CLUBS                   [[ClubManager sharedInstance] clubs]

//이모티콘
NSMutableArray                  *ARR_EMOJI;
#define EMOTICON_COL_COUNT      7
#define EMOTICON_ROW_COUNT      4
#define EMOTICON_WIDTH          32
#define MAKE_Q(x)               @#x
#define MAKE_EM(x,y)            MAKE_Q(x##y)
#define MAKE_EMOJI(x)           MAKE_EM(¥U000,x)
#define EMOJI_METHOD(x,y)       + (NSString *)x { return MAKE_EMOJI(y); }
#define EMOJI_HMETHOD(x)        + (NSString *)x;
#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

typedef enum
{
    MESSAGE_TYPE_TEXT = 1,
    MESSAGE_TYPE_IMAGE = 2,
    MESSAGE_TYPE_AUDIO = 3,
}MESSAGE_TYPE;

typedef enum
{
    INVITE_REQUEST                    = 1,  //초청요청(2player)
    ACCEPT_INVITE_REQUEST             = 2,  //림시초청요청
    TEMP_INVITE_REQUEST               = 3,  //초청요청수락(2captain)
    ACCEPT_TEMP_INVITE_REQUEST        = 4,  //림시초청요청수락
    REGISTER_USER2CLUB_REQUEST        = 5,  //구락부사용자등록(2player)
    RESIGN_GAME_REQUEST               = 6,  //경기포기요청
    ADD_PROCLAIM_REQUEST              = 7,  //포고추가요청수락
    AGREE_GAME_REQUEST                = 8,  //경기수락
    DELETE_CHALLEANGE_REQUEST         = 9,  //도전요청취소
    SET_GAME_RESULT_REQUEST           = 10,
    ACCEPT_JOIN_REQUEST               = 11, //구락부탈퇴
    DISMISS_CLUB_REQUEST              = 12,
    BREAK_CLUB_REQUEST                = 13, //구락부해체요청
    SET_MEMBER_POSITION_REQUEST       = 14,
    CREATE_DISCUSS_CHATROOM_REQUEST   = 15, //대화방챠팅창조요청
    CHATTING_MESSAGE                  = 16,  //대화방챠팅창조요청
    
    BEFORE_GAME_START_FOUR            = 17,  //대화방챠팅창조요청
    BEFORE_GAME_START_TWELVE          = 18,  //대화방챠팅창조요청
    BEFORE_GAME_START_TWENTYFOUR      = 19,  //대화방챠팅창조요청
    N_ACCEPT_RESIGN_GAME              = 20  //대화방챠팅창조요청
    
    
}REMOTE_NOTIFICATION_TYPE;

typedef enum
{
    GAME_STATUS_DELAY = 0,
    GAME_STATUS_JOINFINISHED = 1,
    GAME_STATUS_RUNNING = 2,
    GAME_STATUS_CANCELLED = 3,
    GAME_STATUS_FINISHED = 4,
}GAME_STATUS;

typedef enum
{
    GAME_VSSTATUS_VICTORY = 0,
    GAME_VSSTATUS_FAILED = 1,
    GAME_VSSTATUS_PLAIN = 2,
    GAME_VSSTATUS_CHALLINPUT = 3,
    GAME_VSSTATUS_OPPCONF = 4,
    GAME_VSSTATUS_OPPINPUT = 5,
    GAME_VSSTATUS_CHALLCONF = 6,
}GAME_VSSTATUS;

typedef enum
{
    GAME_TYPE_CHALLENGE = 0,
    GAME_TYPE_NOTIFY = 1,
    GAME_TYPE_CUSTOM = 2,
}GAME_TYPE;

typedef enum
{
    CHATTING_TYPE_CLUBROOM = 0,
    CHATTING_TYPE_DISCUSS = 1,
}CHATTING_TYPE;

typedef enum
{
    LOGIN_STATUS_SUCCESS = 1,
    LOGIN_STATUS_UNREGISTERED = 2,
    LOGIN_STATUS_WRONGPASSWORD = 3,
    LOGIN_STATUS_FORBIDDEN = 4,
    LOGIN_STATUS_DISAGREE = 5,
}LOGIN_STATUS;

typedef enum
{
    RESIGN_TYPE_CONSULT = 0,
    RESIGN_TYPE_FORCE = 1,
}RESIGN_TYPE;

typedef enum
{
    GAME_RESIGH_FAILED = 0,
    GAME_RESIGH_SUCCEESS = 1,
    GAME_RESIGH_DUPLICATE = 2,
    GAME_RESIGH_ALLOW = 3,
    GAME_RESIGH_REFUSED = 4,
    GAME_RESIGH_ALREADY = 5,
    GAME_RESIGH_FORCE = 6,
    GAME_RESIGH_TIMELIMITED = 7,
}GAME_RESIGN;

typedef enum
{
    CLUB_USER_POST_NONE = 0,
    CLUB_USER_POST_CAPTAIN = 1,
    CLUB_USER_POST_CORCH = 2,
    CLUB_USER_POST_MEMBER = 8,
}CLUB_USER_POST;

typedef enum
{
    CLUB_POSITIONINGAME_FORWARD = 1,
    CLUB_POSITIONINGAME_MIDDLE = 8,
    CLUB_POSITIONINGAME_DEFENCE = 128,
    CLUB_POSITIONINGAME_KEEPER = 1024,
}CLUB_POSITIONINGAME;

typedef enum
{
    CHALLENGE_GAME_STATE_OPEN = 0,
    CHALLENGE_GAME_STATE_CLOSE = 1,
}CHALLENGE_GAME_STATE;

@interface Common : NSObject

+ (void)DialPhoneNumber:(NSString *)dialNum;
+ (NSString *)appNameAndVersionNumberDisplayString;
+ (void)BackToPage;
+ (NSString*)EmojiFilterFrom:(NSString*)text;
+ (NSString*)EmojiFilterTo:(NSString*)text;

@end
