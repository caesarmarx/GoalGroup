//
//  HttpManager.h
//  iOM
//
//  Created by KCHN on 8/7/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClubListRecord.h"
#import "PlayerListRecord.h"
#import "ChallengeListRecord.h"

typedef enum
{
    ProtocolErrorTypeNone =                     0,                  // None
    ProtocolErrorTypeInvalidService =           10,                 //invalid service
    ProtocolErrorTypeUnregisterUser =           100,                // Unexpected Error
    ProtocolErrorTypeWrongPassword =            101,                 //
    ProtocolErrorTypeForbiddenUser =            102,                 //
    ProtocolErrorTypeNoData =                   103,
    ProtocolErrorTypeReportFailed =             104,
    ProtocolErrorTypeNoUpdateApp =              105,
    ProtocolErrorTypeCreateClubFailed =         106,
    ProtocolErrorTypeUnexpected =               107,
    ProtocolErrorTypeNickNameDuplicate =        108,
    ProtocolErrorTypeRegisterFail =             109,
    ProtocolErrorTypeAgreeFail =                110,
    ProtocolErrorTypeBrowseDataFail =           111,
    ProtocolErrorTypeProcessFail =              112,
    ProtocolErrorTypeInviteDuplicate =          113,
    protocolerrortypeJoinReqDuplicate =              114,
    ProtocolErrorTypeLogoutFail =               115,
    ProtocolErrorTypeDismissClubFail =          116,
    protocolerrortypeAlreadyApply =             117,
    protocolerrortypeCreateDuplicate =          118,
    ProtocolErrorTypeAskForManager =            119,
    ProtocolErrorTypeCreateChattingRoomFail =   120,
    ProtocolErrorTypeSetGameResultFail =        121,
    ProtocolErrorTypeSetUserPointFail =         122,
    ProtocolErrorTypeGameResignFail =           123,
    ProtocolErrorTypeGameResignSucceess =           124,
    ProtocolErrorTypeGameResignDuplicate =           125,
    ProtocolErrorTypeGameResignAllow =           126,
    ProtocolErrorTypeGameResignRefused =           127,
    ProtocolErrorTypeGameResignAlready =           128,
    ProtocolErrorTypeGameResignForce =           129,
    ProtocolErrorTypeGameResignTimeLimited =           130,
    ProtocolErrorTypeHeIsYourClubMember =                   131,
    ProtocolErrorTypePhoneNumberDuplicate =     132,
    ProtocolErrorTypeJoinReqForbidden = 133,
    ProtocolErrorTypeInviteForbidden = 134,
    ProtocolErrorTypeHeIsClubMember = 135,
    ProtocolErrorTypeGameNotFinished = 136,
}
ProtocolErrorType;

#define GOALGROUPURL                   [SERVER_PREFIX_URL stringByAppendingString:@"goalsrv/api"]

@protocol HttpManagerDelegate<NSObject>
@optional
- (void)loginResultWithErrorCode:(int)errorCode;
- (void)browseChallengeResultWithErrorCode:(int)errorCode dataMore:(int)more data:(NSArray *)data;
- (void)browseMyClubResultWithErrorCode:(int)errorCode dataMore:(int)more data:(NSArray *)data;
- (void)browseDiscussResultWithErrorCode:(int)errorCode dataMore:(int)more data:(NSArray *)data;
- (void)browseClubDetailResultWithErrorCode:(int)errorCode clubdata:(ClubListRecord *)data;
- (void)clubReportResultWithErrorCode:(int)errorCode;
- (void)browseRequestResultWithErrorCode:(int)errorCode dataMore:(int)more data:(NSArray *)data;
- (void)searchClubResultWithErrorCode:(int)errorCode dataMore:(int)more data:(NSArray *)data;
- (void)searchPlayerResultWithErrorCode:(int)errorCode dataMore:(int)more data:(NSArray *)data;
- (void)browseMemberListResultWithErrorCode:(int)errorCode data:(NSArray *)data;
- (void)saveMemberListResultWithErrorCode:(int)errorCode status:(int)status;
- (void)updateVersionResultWithErrorCode:(int)error_code data:(NSArray *)data;
- (void)createClubResultWithErrorCode:(int)error_code data:(NSDictionary *)club;
- (void)userRegisterResultWithErrorCode:(int)errorCode;
- (void)agreeGameWithErrorCode:(int)errorCode withRoomID:(int)nRoomID withRoomName:(NSString *)roomStr;
- (void)browseClubMarkResultWithErrorCode:(int)errorCode data:(NSArray *)data;
- (void)browsePlayerMarkResultwithErrorCode:(int)errorCode data:(NSArray *)data;
- (void)browseScheduleResultwithErrorCode:(int)errorcode dataMore:(int)more data:(NSArray *)data;
- (void)browseReqMemberResultWithErrorCode:(int)errorcode dataMore:(int)more data:(NSArray *)data;
- (void)acceptRequestResultWithErrorCode:(int)errorcode;
- (void)acceptInvReqResultWithErrorCode:(int)errorcode;
- (void)browseTempInvitationResultErrorCode:(int)errorcode dataMore:(int)more data:(NSArray *)data;
- (void)acceptTempInvReqResultErrorCode:(int)errorcode;
- (void)sendInvRequestResultWithErrorCode:(int)errorcode;
- (void)sendTempInvRequestResultWithErrorCode:(int)errorcode;
- (void)registerUserToClubResultWithErrorCode:(int)errorcode;
- (void)userLogoutResultWithErroCode:(int)errorcode;
- (void)dismissClubResultWithErrorCode:(int)errorcode;
- (void)sendChallengeResultWithErrorCode:(int)errorcode room:(int)roomID title:(NSString *)titles;
- (void)adviseOpinionResultWithErrorCode:(int)errorcode;
- (void)delChallengeResultWithErrorCode:(int)errorcode;
- (void)setUserOptionResultWithErrorCode:(int)errorcode;
- (void)getClubSettingResultWithErrorCode:(int)errorcode state:(int)state;
- (void)setClubSettingResultWithErrorCode:(int)errorcode;
- (void)breakDownClubResultWithErrorCode:(int)errorcode;
- (void)applyGameResultWithErrorCode:(int)errorcode;
- (void)browseApplyGameListWithErrorCode:(int)errorcode dataMore:(int)more data:(NSArray *)data;
- (void)gameCreateResultWithErrorCode:(int)errorcode;
- (void)getUserProfileResultWithErrorCode:(int)errorcode data:(PlayerListRecord *)record;
- (void)editUserProfileResultWithErrorCode:(int)errorcode;
- (void)createDiscussResultWithErrorCode:(int)errorcode;
- (void)getDiscussDetailResultWithErrorCode:(int)errorcode more:(int)more header:(NSArray *)headerData article:(NSArray *)articlesData;
- (void)evalDiscussResultWithErrorCode:(int)errorcode data:(NSArray *)data;
- (void)gameResignResultWithErrorCode:(int)errorcode;
- (void)createChattingRoomWithErrorCode:(int)errorcode withRoom:(int)r_id;
- (void)createDiscussChatRoomWithErrorCode:(int)errorcode withRoom:(int)r_id withRoomName:(NSString *)roomName;
- (void)setGameResultResultWithErrorCode:(int)errorcode;
- (void)setUserPointResultWithErrorCode:(int)errorcode;
- (void)getGameResultResultWithErrorCode:(int)errorcode data:(NSArray *)array;
- (void)getAdminNewsResultWithErrorCode:(int)errorcode more:(int)more data:(NSArray *)data;
- (void)getGameDetailResultWithErrorCode:(int)errorcode data:(ChallengeListRecord *)record;
- (void)getCheckMemberAndClubScheduleCountResultWithErrorCode:(int)errorcode count:(int)count check:(int)checked;
- (void)getUserIDResultWithErrorCode:(int)errorcode uid:(int)uid;
- (void)getMasterDataResult;
- (void)checkMemberResultWithErrorCode:(int)errorcode;
- (void)downloadVoiceMailResultWithErrorCode:(int)errorCode filePath:(NSString *)filePath recordIdx:(int)recordIdx;
@end

@class HttpManager;
HttpManager *gHttpManager;

@interface HttpManager : NSObject
{
    NSThread *thread;
}

@property (nonatomic, assign) id<HttpManagerDelegate> delegate;

+ (HttpManager *)newInstance;
+ (HttpManager *)sharedInstance;
- (void)loginWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)browseChallengeListWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)array;
- (void)browseClublistWithDelegate:(id<HttpManagerDelegate>)delegate;
- (void)browseDiscussListWithDelegate:(id<HttpManagerDelegate>)delegate;
- (void)browseClubDataWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)clubReportWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSString *)report;
- (void)browseRequestWithDelegate:(id<HttpManagerDelegate>)delegate;
- (void)searchClubWithDelegate:(id<HttpManagerDelegate>)delegate withCondition:(NSArray *)condition;
- (void)searchPlayerWithDelegate:(id<HttpManagerDelegate>)delegate withCondition:(NSArray *)condition;
- (void)browseMemberListWithDelegate:(id<HttpManagerDelegate>)delegate withClubID:(NSArray *)data;
- (void)saveMemberListWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)updateVersionWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)array;
- (void)createClubWithDelegate:(id<HttpManagerDelegate>) delegate data:(NSArray *)record;
- (void)userRegisterWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)agreeGameWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)browseClubMarkWithDelegate:(id<HttpManagerDelegate>)delegate club:(NSNumber *)club;
- (void)browsePlayerMarkWithDelegate:(id<HttpManagerDelegate>)delegate club:(NSNumber *)clubid;
- (void)browseScheduleWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)browseReqMemberListWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)acceptReqestWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)acceptInvReqWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)browseTempInvitationWithDelegate:(id<HttpManagerDelegate>)delegate;
- (void)acceptTempInvReqWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)sendInvRequestWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)sendTempInvRequestWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)registerUserToClubWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)userLogoutWithDelegate:(id<HttpManagerDelegate>)delegate;
- (void)dismissClubWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)sendChallengeWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)adviseOpinionWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSString *)content;
- (void)delChallengeWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)setUserOptionWithDelegate:(id<HttpManagerDelegate>)delegate;
- (void)getClubSettingWithDelegate:(id<HttpManagerDelegate>)delegate clubID:(NSNumber *)club;
- (void)setClubSettingWithDelegate:(id<HttpManagerDelegate>)delegate;
- (void)breakDownClubWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)applyGameWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *) data;
- (void)browseApplyGameListWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)gameCreateWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)getUserProfileWithDelegate:(id<HttpManagerDelegate>)delegate;
- (void)editUserProfileWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)createDiscussWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)getDiscussDetailWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)evalDiscussWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)gameResignWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)createChattingRoomWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)createDiscussChatRoomWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)setGameResultWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)setUserPointWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)getGameResultWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)getAdminNewsWithDelegate:(id<HttpManagerDelegate>) delegate data:(NSArray *)data;
- (void)getGameDetailWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)getCheckMemberAndClubScheduleCountWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)getUserIDWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)getMasterDataWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)checkMemberWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data;
- (void)downloadVoiceMail:(id<HttpManagerDelegate>)delegate filePath:(NSString *)filePath recordIdx:(int)recordIdx;

@end
