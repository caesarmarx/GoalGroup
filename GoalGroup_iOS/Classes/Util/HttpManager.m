//
//  HttpManager.m
//  iOM
//
//  Created by KCHN on 8/7/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "HttpManager.h"
#import "DateManager.h"
#import "DistrictManager.h"
#import "GameScheduleRecord.h"
#import "DiscussDetailListRecord.h"
#import "SystemConferenceListRecord.h"
#import "DiscussRoomManager.h"
#import "ChatMessage.h"
#import "Common.h"
#import "Sqlite3Manager.h"

@implementation HttpManager



#pragma Initialization
+ (HttpManager *)newInstance
{
    return [[HttpManager alloc] init];
}

+ (HttpManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gHttpManager == nil)
            gHttpManager = [[HttpManager alloc] init];
    }
    return gHttpManager;
}

#pragma UserDefinded

//Login
- (void)loginWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread new] initWithTarget:self
                                   selector:@selector(loginThread:)
                                     object:data
              ];
    [thread start];
}


- (void)loginThread:(NSArray *)data
{
    NSString *username = [data objectAtIndex:0];
    NSString *password = [data objectAtIndex:1];

    lastUpdateTime = @"2999-04-10 00:00:00";
    
    //Modified By Boss.2015/05/20
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&account_num=%@&password=%@&device_token=%@&last_updated_time=%@", @"user_login", username, password, MyDeviceToken, lastUpdateTime] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code =  ProtocolErrorTypeNone;
    
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        [self performSelectorOnMainThread:@selector(loginResultComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
        return;
    }
    
    NSError *localError = nil;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localError];

#ifdef DEMO_MODE
    NSLog(@"loginThread: rootObject=%@", rootObject);
#endif
        
    if (!rootObject || [rootObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        [self performSelectorOnMainThread:@selector(loginResultComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
        return;
    }

    NSInteger nLoginStatus = [[rootObject objectForKey:@"login_status"] intValue];
    
    UID = [[rootObject objectForKey:@"user_id"] intValue];
    sUID = [rootObject objectForKey:@"user_id"];
    USERNAME = [rootObject objectForKey:@"user_name"];
    USERPHOTO = [rootObject objectForKey:@"user_photo"];
    nInvCount = [[rootObject objectForKey:@"inv_count"] intValue];
    nTempInvCount = [[rootObject objectForKey:@"temp_inv_count"] intValue];
    curCityID = [[rootObject objectForKey:@"playing_city"] intValue];
    curSystemTimeStr = [rootObject objectForKey:@"server_time"];
    
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];

    if (!dataObject || [dataObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        [self performSelectorOnMainThread:@selector(loginResultComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
        return;
    }
    
    NSArray *chatArray = [dataObject objectForKey:@"offline_chat_content"];
    
    for (NSDictionary *dict in chatArray) {
        ChatMessage *newMsg = [ChatMessage new];
        newMsg.msg = [dict objectForKey:@"content"];
        newMsg.roomId = [[dict objectForKey:@"chat_room_id"] intValue];
        newMsg.senderId = [[dict objectForKey:@"sender_id"] intValue];
        newMsg.sendTime = [dict objectForKey:@"sendtime"];
        newMsg.senderName = [dict objectForKey:@"sender_name"];
        newMsg.userPhoto = [dict objectForKey:@"sender_photo"];
        newMsg.readState = 0;
        newMsg.sendState = 1;
        
        if ([newMsg.msg hasPrefix:@"Create new discuss room"] ||
            [newMsg.msg hasPrefix:@"create new discuss room"] ||
            [newMsg.msg hasPrefix:@"Update discuss room"] ||
            [newMsg.msg hasPrefix:@"update discuss room"])
            continue;
        
        if ([newMsg.msg hasSuffix:@"jpg"])
            newMsg.type = MESSAGE_TYPE_IMAGE;
        else if ([newMsg.msg hasSuffix:@"gga"])
            newMsg.type = MESSAGE_TYPE_AUDIO;
        else
            newMsg.type = MESSAGE_TYPE_TEXT;

        [ChatMessage addChatMessage:newMsg];
        [[NotificationManager sharedInstance] notify:newMsg.msg who:newMsg.senderName type:newMsg.type];
    }

    NSArray *clubs = [[NSMutableArray alloc] initWithArray:[dataObject objectForKey:@"club_info"]];
    [[ClubManager sharedInstance] setClubs:clubs];

    NSArray *discussChatArray = [dataObject objectForKey:@"discuss_chat_room"];
    [[DiscussRoomManager sharedInstance] setDiscussChatRooms:discussChatArray];

    STADIUMS = [dataObject objectForKey:@"stadium_info"];
    CITYS = [dataObject objectForKey:@"city_info"];
    for (NSDictionary *item in CITYS)
    {
        if ([[item objectForKey:@"city"] isEqualToString:LANGUAGE(@"DEFAULT_CITY_NAME")])
        {
            DEFAULT_CITY_NAME = LANGUAGE(@"DEFAULT_CITY_NAME");
            DEFAULT_CITY_ID = [[item valueForKey:@"id"] intValue];
        }
    }
    DISTRICTS = [[NSMutableArray alloc] init];
            
    switch (nLoginStatus) {
        case LOGIN_STATUS_DISAGREE:
            error_code = ProtocolErrorTypeAskForManager;
            break;
        case 1:
            break;
        case LOGIN_STATUS_UNREGISTERED:
            error_code = ProtocolErrorTypeUnregisterUser;
            break;
        case LOGIN_STATUS_WRONGPASSWORD:
            error_code = ProtocolErrorTypeWrongPassword;
            break;
        case LOGIN_STATUS_FORBIDDEN:
            error_code = ProtocolErrorTypeForbiddenUser;
            break;
        default:
            break;
    }
            
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"LOGIN_DATA_USER"];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"LOGIN_DATA_PASS"];
    [[NSUserDefaults standardUserDefaults] setObject:[rootObject objectForKey:@"user_id"] forKey:@"LOGIN_DATA_UID"];
            
    NSArray *districts = [dataObject objectForKey:@"district_info"];
    OPTIONS = [[rootObject valueForKey:@"option"] intValue];
    [[DistrictManager sharedInstance] setDistrictRecord:districts];
    
    if (error_code == ProtocolErrorTypeNone)
        [self getMasterData:nil];

    [self performSelectorOnMainThread:@selector(loginResultComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)loginResultComplete:(NSNumber *)data
{
    if ([self.delegate respondsToSelector:@selector(loginResultWithErrorCode:)])
        [self.delegate loginResultWithErrorCode:[data intValue]];
}

//Battle->Challenge
//Battle->Notice
- (void)browseChallengeListWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)array;
{
    self.delegate = delegate;
    thread = [[NSThread new] initWithTarget:self
                                   selector:@selector(browseChallengeListThreadFromPage:)
                                     object:array
              ];
    [thread start];
}

- (void)browseChallengeListThreadFromPage:(NSArray *)array
{
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&club_id=%@&type=%@&page=%@&start_state=%@", @"browse_challenge_list", [array objectAtIndex:0], [array objectAtIndex:1], [array objectAtIndex:2], [array objectAtIndex:3]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseChallengeResultWithErrorCode: dataMore: data:)])
            [self.delegate browseChallengeResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }
    
    NSError *localError = nil;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localError];

    if (!rootObject || [rootObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseChallengeResultWithErrorCode: dataMore: data:)])
            [self.delegate browseChallengeResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }
#ifdef DEMO_MODE
    NSLog(@"BrowseChallengeListResult = %@", rootObject);
#endif
    
    int nDownState = [[rootObject objectForKey:@"succeed"] intValue];
    int nMoreState = [[rootObject objectForKey:@"more"] intValue];
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    if (nDownState != 1 || !dataObject)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseChallengeResultWithErrorCode: dataMore: data:)])
            [self.delegate browseChallengeResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }

    if ([dataObject isEqual:@""] )
    {
        error_code = ProtocolErrorTypeNoData;
        
        if ([self.delegate respondsToSelector:@selector(browseChallengeResultWithErrorCode: dataMore: data:)])
            [self.delegate browseChallengeResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }

    NSArray *listObjects = [dataObject objectForKey:@"result"];
    for (NSDictionary *item in listObjects) {
        ChallengeListRecord *record = [[ChallengeListRecord alloc] initWithSendClubName:[item valueForKey:@"club_name_01"]
                                                                                   sendImageUrl:[item valueForKey:@"mark_pic_url_01"]
                                                                                   recvClubName:[item valueForKey:@"club_name_02"]
                                                                                   recvImageUrl:[item valueForKey:@"mark_pic_url_02"]
                                                                                   playerNumber:[[item valueForKey:@"player_count"] intValue]
                                                                                       playDate:[item valueForKey:@"game_date"]
                                                                                        playDay:[[item valueForKey:@"game_weekday"] intValue]
                                                                                       playTime:[item valueForKey:@"game_time"]
                                                                        playStadiumArea:[item valueForKey:@"stadium_area"]
                                                                     playStadiumAddress:[item valueForKey:@"stadium_address"]
                                                                                     sendClubID:[[item valueForKey:@"club_id_01"] intValue]
                                                                                     recvClubID:[[item valueForKey:@"club_id_02"] intValue]
                                               gameID:[[item valueForKey:@"challenge_id"] intValue]
                                                                                   tempInvState:0
                                                                                vcStatus:0
                                                                              tempUnread:NO];
        [data addObject:record];
    }

    if ([self.delegate respondsToSelector:@selector(browseChallengeResultWithErrorCode: dataMore: data:)])
        [self.delegate browseChallengeResultWithErrorCode:error_code dataMore:nMoreState data:data];
}

//BrowseClubList
- (void)browseClublistWithDelegate:(id<HttpManagerDelegate>)delegate
{
    self.delegate = delegate;
    
    thread = [[NSThread alloc] initWithTarget:self
                                     selector:@selector(clubListThread)
                                       object:nil];
    [thread start];
}
	
- (void)clubListThread
{
    int page = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CLUBLIST_PAGENO"] intValue];
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&page=%d", @"browse_club_list", UID, page] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    
    if (resultData == nil)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseMyClubResultWithErrorCode:dataMore:data:)])
            [self.delegate browseMyClubResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }
    
    NSError *localError = nil;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localError];

    if (!rootObject || [rootObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseMyClubResultWithErrorCode:dataMore:data:)])
            [self.delegate browseMyClubResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }
    
    int nDownState = [[rootObject objectForKey:@"succeed"] intValue];
    int nMoreState = [[rootObject objectForKey:@"more"] intValue];

    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSDictionary *dataObjects = [rootObject objectForKey:@"data"];
    if (!resultData || nDownState != 1)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseMyClubResultWithErrorCode:dataMore:data:)])
            [self.delegate browseMyClubResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }
    
    if ([dataObjects isEqual:@""])
    {
        error_code = ProtocolErrorTypeNoData;
        
        if ([self.delegate respondsToSelector:@selector(browseMyClubResultWithErrorCode:dataMore:data:)])
            [self.delegate browseMyClubResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }

    NSArray *listObjects = [dataObjects objectForKey:@"result"];
    
    if (listObjects) {
        for (NSDictionary *item in listObjects) {
            ClubListRecord *record = [[ClubListRecord alloc] initWithClubID:[[item valueForKey:@"club_id"] intValue]
                                                                   clubImageUrl:[item valueForKey:@"mark_pic_url"]
                                                                       clubname:[item valueForKey:@"name"]];
            [data addObject:record];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(browseMyClubResultWithErrorCode:dataMore:data:)])
        [self.delegate browseMyClubResultWithErrorCode:error_code dataMore:nMoreState data:data];
}

//DiscussList
- (void)browseDiscussListWithDelegate:(id<HttpManagerDelegate>)delegate
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(browseDiscussList) object:nil];
    [thread start];
}

- (void)browseDiscussList
{
    int page = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DISCUSSLIST_PAGENO"] intValue];
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&page=%d", @"browse_discuss_list", page] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int nMoreState;
    int nDownState;
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    if (!resultData){
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseDiscussResultWithErrorCode:dataMore:data:)])
            [self.delegate browseDiscussResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
#ifdef DEMO_MODE
    NSLog(@"BrowseDiscussList = %@", rootObject);
#endif
        
    if (!rootObject){
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseDiscussResultWithErrorCode:dataMore:data:)])
            [self.delegate browseDiscussResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }
    
    nMoreState = [[rootObject objectForKey:@"more"] intValue];
    nDownState = [[rootObject objectForKey:@"succeed"] intValue];
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
            
    
    if (!dataObject || [dataObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeNoData;
        
        if ([self.delegate respondsToSelector:@selector(browseDiscussResultWithErrorCode:dataMore:data:)])
            [self.delegate browseDiscussResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }

    NSArray *listObjects = [dataObject objectForKey:@"result"];
    DiscussListRecord *record;
    for (NSDictionary *item in listObjects) {
                record = [[DiscussListRecord alloc] initWithID:[[item valueForKey:@"bbs_id"] intValue]
                                                            imageDiscussUrl:[item valueForKey:@"img_url"]
                                                            imageOfferUrl:[item valueForKey:@"user_icon"]
                                                             titleDiscuss:@""
                                                                nameOffer:[item valueForKey:@"user_name"]
                                                             introDisucss:[item objectForKey:@"content"]
                                                              timeDiscuss:[item objectForKey:@"date"]
                                                              dicussCount:[[item objectForKey:@"reply_count"] intValue]];
                [data addObject:record];
    }
    
    if ([self.delegate respondsToSelector:@selector(browseDiscussResultWithErrorCode:dataMore:data:)])
        [self.delegate browseDiscussResultWithErrorCode:error_code dataMore:nMoreState data:data];
}

//ClubDetail
- (void)browseClubDataWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(browseClubDetail:) object:data];
    [thread start];
}

- (void)browseClubDetail:(NSArray *)array
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%@&club_id=%@", @"browse_club_data", [array objectAtIndex:0], [array objectAtIndex:1]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    ClubListRecord *record;
    int error_code = ProtocolErrorTypeNone;
    
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        [self performSelectorOnMainThread:@selector(browseClubDetailComplete:)
                               withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], nil, nil]
                            waitUntilDone:YES
         ];
        return;
    }
    

    NSError *localerror;
    NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];

    if (!rootDictionary || [rootDictionary isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        [self performSelectorOnMainThread:@selector(browseClubDetailComplete:)
                               withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], nil, nil]
                            waitUntilDone:YES
         ];
        return;
    }

#ifdef DEMO_MODE
    NSLog(@"browseClubDetail = %@", rootDictionary);
#endif
    
    int nDownState = [[rootDictionary objectForKey:@"succeed"] intValue];
    NSDictionary *dataDictionary = [rootDictionary objectForKey:@"data"];
            
    if (!dataDictionary || [dataDictionary isEqual:@""] || nDownState != 1)
    {
        error_code = ProtocolErrorTypeInvalidService;
        [self performSelectorOnMainThread:@selector(browseClubDetailComplete:)
                               withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], nil, nil]
                            waitUntilDone:YES
         ];
        return;
    }

    record = [[ClubListRecord alloc] initWithClubID:[[array objectAtIndex:0] intValue]
                                           userType:[[dataDictionary valueForKey:@"user_type"] intValue]
                                       ClubImageUrl:[dataDictionary valueForKey:@"mark_pic_url"]
                                           clubname:[dataDictionary valueForKey:@"club_name"]
                                            members:[[dataDictionary valueForKey:@"member_count"] intValue]
                                         activeRate:[[dataDictionary valueForKey:@"point"] intValue]
                                         averageAge:[[dataDictionary valueForKey:@""] intValue]
                                         activeArea:[dataDictionary valueForKey:@"act_area"]
                                        activeWeeks:[[dataDictionary valueForKey:@"act_time"] intValue]
                                          foundDate:[dataDictionary valueForKey:@"found_date"]
                                               city:[dataDictionary valueForKey:@"city"]
                                            sponsor:[dataDictionary valueForKey:@"sponsor"]
                                    homeStadiumArea:[dataDictionary valueForKey:@"home_stadium_area"]
                                    homeStadiumAddr:[dataDictionary valueForKey:@"home_stadium_address"]
                                       introduction:[dataDictionary valueForKey:@"introduction"]
                                           allGames:[[dataDictionary valueForKey:@"all_game"] intValue]
                                           vicGames:[[dataDictionary valueForKey:@"victor_game"] intValue]
                                          lossGames:[[dataDictionary valueForKey:@"lose_game"] intValue]
                                          drawGames:[[dataDictionary valueForKey:@"draw_game"] intValue]];

    [self performSelectorOnMainThread:@selector(browseClubDetailComplete:)
                           withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], record, nil]
                        waitUntilDone:YES
     ];
}

- (void)browseClubDetailComplete:(id)data
{
    int error_code = [[data objectAtIndex:0] intValue];
    ClubListRecord *record = [data objectAtIndex:1];
    if ([self.delegate respondsToSelector:@selector(browseClubDetailResultWithErrorCode:clubdata:)])
        [self.delegate browseClubDetailResultWithErrorCode:error_code clubdata:record];
}

//ClubReport
- (void)clubReportWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSString *)report
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(clubReport:) object:report];
    [thread start];
}

- (void)clubReport:(NSString *)report
{
    int nClubID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CLUBDETAIL_CLUBID"] intValue];
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&club_id=%d&reason=%@", @"club_report", UID, nClubID, report] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    int error_code = ProtocolErrorTypeNone;;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        [self performSelectorOnMainThread:@selector(clubReportComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
        return;
    }

    NSError *localerror;
    NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
    if (!rootDictionary || [rootDictionary isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        [self performSelectorOnMainThread:@selector(clubReportComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
        return;
    }
    
    int nDownState = [[rootDictionary objectForKey:@"succeed"] intValue];
    NSDictionary *dataDictionary = [rootDictionary objectForKey:@"data"];
        
    if (nDownState != 1 || !dataDictionary || [dataDictionary isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        [self performSelectorOnMainThread:@selector(clubReportComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
        return;
    }
    
    int n = [[dataDictionary objectForKey:@"success"] intValue];
    error_code = (n == 1)? ProtocolErrorTypeNone: ProtocolErrorTypeReportFailed;
    
    [self performSelectorOnMainThread:@selector(clubReportComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)clubReportComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(clubReportResultWithErrorCode:)])
        [self.delegate clubReportResultWithErrorCode:[number intValue]];
}
//RequestList
- (void)browseRequestWithDelegate:(id<HttpManagerDelegate>)delegate
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(browseRequest) object:nil];
    [thread start];
}

- (void)browseRequest
{
    int page = [[[NSUserDefaults standardUserDefaults] objectForKey:@"REQUESTLIST_PAGENO"] intValue];
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&page=%d", @"browse_request", UID, page] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    int error_Code = ProtocolErrorTypeNone;
    
    if (!resultData)
    {
        error_Code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseRequestResultWithErrorCode:dataMore:data:)])
            [self.delegate browseRequestResultWithErrorCode:error_Code dataMore:0 data:nil];
        return;
    }

    int nMoreState;
    int nDownState;
    NSError *localerror;
    NSMutableArray *data = [[NSMutableArray alloc] init];

    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
#ifdef DEMO_MODE
    NSLog(@"BrowseRequestResult = %@", rootObject);
#endif
        
    if (!rootObject || [rootObject isEqual:@""])
    {
        error_Code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseRequestResultWithErrorCode:dataMore:data:)])
            [self.delegate browseRequestResultWithErrorCode:error_Code dataMore:0 data:nil];
        return;
    }

    nMoreState = [[rootObject objectForKey:@"more"] intValue];
    nDownState = [[rootObject objectForKey:@"succeed"] intValue];
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
    if (nDownState != 1 || !dataObject || [dataObject isEqual:@""])
    {
        error_Code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseRequestResultWithErrorCode:dataMore:data:)])
            [self.delegate browseRequestResultWithErrorCode:error_Code dataMore:0 data:nil];
        return;
    }

    NSArray *listObjects = [dataObject objectForKey:@"result"];
            
    for (NSDictionary *item in listObjects) {
        DemandListRecord *recode = [[DemandListRecord alloc] initWithClubID:[[item valueForKey:@"club_id"] intValue]
                                                                      title:[item valueForKey:@"club_name"]
                                                              thumbImageUrl:[item valueForKey:@"mark_pic_url"]
                                                                       date:[item valueForKey:@"req_date"]
                                                                       time:[item valueForKey:@"req_time"]
                                    read:NO];
        [data addObject:recode];
    }

    if ([self.delegate respondsToSelector:@selector(browseRequestResultWithErrorCode:dataMore:data:)])
        [self.delegate browseRequestResultWithErrorCode:error_Code dataMore:nMoreState data:data];
}

//SearchClub
- (void)searchClubWithDelegate:(id<HttpManagerDelegate>)delegate withCondition:(NSArray *)condition
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(searchClub:) object:condition];
    [thread start];
}

- (void)searchClub:(NSArray *)condition
{
    int page = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SEARCHCLUB_PAGENO"] intValue];
    
    NSData *postData = nil;
    
    if (condition.count == 0)
        postData = [[NSString stringWithFormat:@"cmd=%@&page=%d", @"search_club", page] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    else
        postData = [[NSString stringWithFormat:@"cmd=%@&page=%d&min_age=%@&max_age=%@&ActivityTime=%@&ActivityArea=%@&user_id=%d", @"search_club_list", page, [condition objectAtIndex:0],[condition objectAtIndex:1],[condition objectAtIndex:2],[condition objectAtIndex:3], UID] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    int error_code = ProtocolErrorTypeNone;

    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(searchClubResultWithErrorCode:dataMore:data:)])
            [self.delegate searchClubResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }
    
    int nDownState;
    int nMoreState;
    
    NSMutableArray *data= [[NSMutableArray alloc] init];

    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
#ifdef DEMO_MODE
    NSLog(@"SearchClubResult = %@", rootObject);
#endif
    
    if (!rootObject || [rootObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(searchClubResultWithErrorCode:dataMore:data:)])
            [self.delegate searchClubResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }

    
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
    nDownState = [[rootObject objectForKey:@"succeed"] intValue];
    nMoreState = [[rootObject objectForKey:@"more"] intValue];
            
    if (nDownState != 1 || !dataObject){
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(searchClubResultWithErrorCode:dataMore:data:)])
            [self.delegate searchClubResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }

    if ([dataObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeNoData;
        
        if ([self.delegate respondsToSelector:@selector(searchClubResultWithErrorCode:dataMore:data:)])
            [self.delegate searchClubResultWithErrorCode:error_code dataMore:0 data:nil];
        return;
    }

    NSArray *listObjects = [dataObject objectForKey:@"result"];
    for (NSDictionary *item in listObjects) {
        ClubListRecord *record = [[ClubListRecord alloc] initWithClubId:[[item valueForKey:@"club_id"] intValue]
                                                           ClubImageUrl:[item valueForKey:@"mark_pic_url"]
                                                               clubname:[item valueForKey:@"club_name"]
                                                                members:[[item valueForKey:@"player_count"] intValue]
                                                             activeRate:[[item valueForKey:@"point"] intValue]
                                                             averageAge:[[item valueForKey:@"average_age"] intValue]
                                                             activeArea:[item valueForKey:@"act_area"]
                                                            activeWeeks:[[item valueForKey:@"act_time"] intValue]];
        
        [data addObject:record];
    }
    
    if ([self.delegate respondsToSelector:@selector(searchClubResultWithErrorCode:dataMore:data:)])
        [self.delegate searchClubResultWithErrorCode:error_code dataMore:nMoreState data:data];
}

//SearchPlayer
- (void)searchPlayerWithDelegate:(id<HttpManagerDelegate>)delegate withCondition:(NSArray *)condition
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(searchPlayer:) object:condition];
    [thread start];
}

- (void)searchPlayer:(NSArray *)condition
{
    int page = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SEARCHPLAYER_PAGENO"] intValue];
    
    NSData *postData = nil;
    
    if (condition.count == 0)
        postData = [[NSString stringWithFormat:@"cmd=%@&page=%d", @"browse_player_list", page] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    else
        postData = [[NSString stringWithFormat:@"cmd=%@&page=%d&min_age=%@&max_age=%@&position=%@&Activity_Time=%@&Activity_Area=%@&user_id=%d", @"search_player_list", page, [condition objectAtIndex:0],[condition objectAtIndex:1],[condition objectAtIndex:2],[condition objectAtIndex:3],[condition objectAtIndex:4], UID] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int nDownState;
    int nMoreState;
    
    NSMutableArray *data= [[NSMutableArray alloc] init];
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        [self performSelectorOnMainThread:@selector(searchPlayerComplete:)
                               withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], [NSNumber numberWithInt:0], [[NSArray alloc] init], nil]
                            waitUntilDone:YES];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
    
    if (!rootObject || [rootObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        [self performSelectorOnMainThread:@selector(searchPlayerComplete:)
                               withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], [NSNumber numberWithInt:0], [[NSArray alloc] init], nil]
                            waitUntilDone:YES];
        return;
    }
    
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
    nDownState = [[rootObject objectForKey:@"succeed"] intValue];
    nMoreState = [[rootObject objectForKey:@"more"] intValue];
            
    if (nDownState != 1 || !dataObject )
    {
        error_code = ProtocolErrorTypeInvalidService;
        [self performSelectorOnMainThread:@selector(searchPlayerComplete:)
                               withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], [NSNumber numberWithInt:0], [[NSArray alloc] init], nil]
                            waitUntilDone:YES];
        return;
    }
    
    if ([dataObject isEqual:@""])
    {
        [self performSelectorOnMainThread:@selector(searchPlayerComplete:)
                               withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [[NSArray alloc] init], nil]
                            waitUntilDone:YES];
        return;
    }
    
    NSArray *listObjects = [dataObject objectForKey:@"result"];
    for (NSDictionary *item in listObjects) {
        PlayerListRecord *record = [[PlayerListRecord alloc] initWithPlayerID:[[item valueForKey:@"user_id"] intValue]
                                                               playerImageUrl:[item valueForKey:@"user_icon"]
                                                                   playerName:[item valueForKey:@"user_name"]
                                                                          age:[[item valueForKey:@"age"] intValue]
                                                                  footballage:[[item valueForKey:@"term"] intValue]
                                                                       height:[[item valueForKey:@"height"] intValue]
                                                                       weight:[[item valueForKey:@"weight"] intValue]
                                                                     position:[[item valueForKey:@"position"] intValue]
                                                                         week:[[item valueForKey:@"act_time"] intValue]
                                                                         area:[item valueForKey:@"act_area"]
                                                                       health:YES];
                    
        [data addObject:record];
    }
    
    [self performSelectorOnMainThread:@selector(searchPlayerComplete:)
                           withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], [NSNumber numberWithInt:nMoreState], data, nil]
                        waitUntilDone:YES];
}

- (void)searchPlayerComplete:(NSArray *)arr
{
    int error_code = [[arr objectAtIndex:0] intValue];
    int nMoreState = [[arr objectAtIndex:1] intValue];
    NSArray *data = [arr objectAtIndex:2];
    if ([self.delegate respondsToSelector:@selector(searchPlayerResultWithErrorCode:dataMore:data:)])
        [self.delegate searchPlayerResultWithErrorCode:error_code dataMore:nMoreState data:data];
}

//BrowseMemberList
- (void)browseMemberListWithDelegate:(id<HttpManagerDelegate>)delegate withClubID:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(browseMemberList:) object:data];
    [thread start];
}

- (void)browseMemberList:(NSArray *)array
{
    
    int nClubID = [[array objectAtIndex:0] intValue];
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&club_id=%d", @"browse_member_list", nClubID] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];

    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int nDownState;
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseMemberListResultWithErrorCode:data:)])
            [self.delegate browseMemberListResultWithErrorCode:error_code data:nil];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];

    if (!rootDictionary || [rootDictionary isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseMemberListResultWithErrorCode:data:)])
            [self.delegate browseMemberListResultWithErrorCode:error_code data:nil];
        return;
    }
    
    nDownState = [[rootDictionary objectForKey:@"succeed"] intValue];
        
    if (nDownState != 1 || !rootDictionary)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(browseMemberListResultWithErrorCode:data:)])
            [self.delegate browseMemberListResultWithErrorCode:error_code data:nil];
        return;

    }
    
    NSDictionary *dataObject = [rootDictionary objectForKey:@"data"];
            
    if (!dataObject || [dataObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeNoData;
        
        if ([self.delegate respondsToSelector:@selector(browseMemberListResultWithErrorCode:data:)])
            [self.delegate browseMemberListResultWithErrorCode:error_code data:nil];
        return;
    }
    
    NSArray *listObjects = [dataObject objectForKey:@"result"];
    for (NSDictionary *item in listObjects) {
        PlayerListRecord *record = [[PlayerListRecord alloc] initWithPlayerID:[[item valueForKey:@"user_id"] intValue]
                                                                     userType:[[item valueForKey:@"user_type"] intValue]
                                                               playerImageUrl:[item valueForKey:@"user_icon"]
                                                                   playerName:[item valueForKey:@"user_name"]
                                                               positionInGame:[[item valueForKey:@"position"] intValue]
                                                                       health:[[item valueForKey:@"health"] boolValue]
                                                                    tempState:[[item valueForKey:@"user_temp"] intValue]];
                    
        [data addObject:record];
    }
    
    if ([self.delegate respondsToSelector:@selector(browseMemberListResultWithErrorCode:data:)])
        [self.delegate browseMemberListResultWithErrorCode:error_code data:data];
}

//saveMemberList
- (void)saveMemberListWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(saveMemberList:) object:data];
    [thread start];
}

- (void)saveMemberList:(NSArray *)data
{
    int nClubID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CLUBDETAIL_CLUBID"] intValue];
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&club_id=%d&user_id=%@&position=%@&manager_id=%@&captain_id=%@&del_user_id=%@",
                         @"set_member_position",
                         nClubID,
                         [data objectAtIndex:0],
                         [data objectAtIndex:1],
                         [data objectAtIndex:2],
                         [data objectAtIndex:3],
                         [data objectAtIndex:4]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];;
    
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int nStatus = 0;

    if (!resultData)
        error_code = ProtocolErrorTypeInvalidService;
    else
    {
        NSError *localerror;
        NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
        if (!rootDictionary || [rootDictionary isEqual:@""])
            error_code = ProtocolErrorTypeInvalidService;
        else
            nStatus = [[rootDictionary objectForKey:@"set_status"] intValue];
    }

    [self performSelectorOnMainThread:@selector(saveMemberListComplete:)
                           withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], [NSNumber numberWithInt:nStatus], nil]
                        waitUntilDone:YES
     ];
}

- (void)saveMemberListComplete:(id)data
{
    int error_code = [[data objectAtIndex:0] intValue];
    int status = [[data objectAtIndex:1] intValue];
    if ([self.delegate respondsToSelector:@selector(saveMemberListResultWithErrorCode:status:)])
        [self.delegate saveMemberListResultWithErrorCode:error_code status:status];
}


//UpdateVersion
- (void)updateVersionWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(updateVersion:) object:data];
    [thread start];
}

- (void)updateVersion:(NSArray *)array
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&oldVer=%@&dev_type=%d", @"update_ver", [array objectAtIndex:0], 0] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    NSError *localerror;
    NSDictionary *rootObjects = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];

    int nDownState;
    int nExistState;
    int error_code = ProtocolErrorTypeNone;

    if (!rootObjects || [rootObjects isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(updateVersionResultWithErrorCode:data:)])
            [self.delegate updateVersionResultWithErrorCode:error_code data:nil];
        return;
    }

        
    NSArray *data;
    
    nExistState = [[rootObjects objectForKey:@"state"] intValue];
    nDownState = [[rootObjects objectForKey:@"succeed"] intValue];
        
    if (nExistState == 0)
        error_code = ProtocolErrorTypeNoUpdateApp;
        
    NSDictionary *dataObject = [rootObjects objectForKey:@"data"];
    if (!dataObject || [dataObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(updateVersionResultWithErrorCode:data:)])
            [self.delegate updateVersionResultWithErrorCode:error_code data:nil];
        return;
    }

    NSDictionary *resultObjects = [dataObject objectForKey:@"result"];
    NSString *versionString = [resultObjects valueForKey:@"new_ver"];
    NSString *dateString = [resultObjects valueForKey:@"up_date"];
    NSString *urlString = [resultObjects valueForKey:@""];
    data = [NSArray arrayWithObjects:versionString, dateString, urlString, nil];
    
    if ([self.delegate respondsToSelector:@selector(updateVersionResultWithErrorCode:data:)])
        [self.delegate updateVersionResultWithErrorCode:error_code data:data];
    
}

//CreateClub
- (void)createClubWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)record
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(createClub:) object:record];
    [thread start];
}

- (void)createClub:(NSArray *)record
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%@&club_id=%@&ClubName=%@&Mark_Pic_Url=%@&City=%@&Money=%@&Sponsor=%@&Introduction=%@&ActivityTime=%@&ActivityArea=%@&Home_Stadium_Area=%@&Home_Stadium_Address=%@&create_date=%@&create_type=%@",
                         @"create_club",
                         [record objectAtIndex:0],
                         [record objectAtIndex:1],
                         [record objectAtIndex:2],
                         [record objectAtIndex:3],
                         [record objectAtIndex:4],
                         [record objectAtIndex:5],
                         [record objectAtIndex:6],
                         [record objectAtIndex:7],
                         [record objectAtIndex:8],
                         [record objectAtIndex:9],
                         [record objectAtIndex:10],
                         [record objectAtIndex:11],
                         [record objectAtIndex:12],
                         [record objectAtIndex:13]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];;
    
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;

    NSDictionary *data;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        NSArray *ret = [NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], nil];
        [self performSelectorOnMainThread:@selector(createClubComplete:) withObject:ret waitUntilDone:YES];
        return;
    }
    

    NSError *localerror;
    NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
#ifdef DEMO_MODE
    NSLog(@"Createclub = %@", rootDictionary);
#endif
    if (!rootDictionary)
    {
        error_code = ProtocolErrorTypeInvalidService;
        NSArray *ret = [NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], nil];
        [self performSelectorOnMainThread:@selector(createClubComplete:) withObject:ret waitUntilDone:YES];
        return;
    }

    int nState = [[rootDictionary objectForKey:@"status"] intValue];
    error_code = nState == 1? ProtocolErrorTypeNone: ProtocolErrorTypeCreateClubFailed;
    data = [rootDictionary objectForKey:@"data"];
    NSArray *ret = [NSArray arrayWithObjects:[NSNumber numberWithInt:error_code],
                    data, nil];
    
    [self performSelectorOnMainThread:@selector(createClubComplete:) withObject:ret waitUntilDone:YES];
}

- (void)createClubComplete:(NSArray *)array
{
    int error_code = [[array objectAtIndex:0] intValue];
    
    NSDictionary *data = nil;
    if ([array count] > 1)
        data = [array objectAtIndex:1];
    
    if ([self.delegate respondsToSelector:@selector(createClubResultWithErrorCode:data:)])
        [self.delegate createClubResultWithErrorCode:error_code data:data];
}

//userRegister
- (void)userRegisterWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(userRegister:) object:data];
    [thread start];
}

- (void)userRegister:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&Account_Num=%@&NickName=%@&Password=%@&IP_Addr=%@", @"user_register", [data objectAtIndex:0], [data objectAtIndex:1], [data objectAtIndex:2], @""] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *requset = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:requset returningResponse:nil error:nil];
    NSError *localerror;

    int error_code = ProtocolErrorTypeNone;

    if (!resultData)
        error_code = ProtocolErrorTypeInvalidService;
    else{
        NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];

        if (!rootDictionary)
        {
            error_code = ProtocolErrorTypeInvalidService;
        }
        else
        {
#ifdef DEMO_MODE
            NSLog(@"UserRegister = %@", rootDictionary);
#endif
            
            int nState = [[rootDictionary objectForKey:@"register_status"] intValue];
            
            switch (nState) {
                case 0:
                    error_code = ProtocolErrorTypeRegisterFail;
                    return;
                case 1:
                    break;
                case 2:
                    error_code = ProtocolErrorTypePhoneNumberDuplicate;
                    break;
                case 3:
                    error_code = ProtocolErrorTypeNickNameDuplicate;
                    break;
            }

        }
        
    }
    
    [self performSelectorOnMainThread:@selector(userRegisterComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}
- (void)userRegisterComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(userRegisterResultWithErrorCode:)])
        [self.delegate userRegisterResultWithErrorCode:[number intValue]];
}

//AgreeChallenge, AgreeNotice
- (void)agreeGameWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(agreeGame:) object:data];
    [thread start];
}

- (void)agreeGame:(NSArray *)data
{
    
    int gameID = [[data objectAtIndex:0] intValue];
    int clubID = [[data objectAtIndex:1] intValue];
    int gameType = [[data objectAtIndex:2] intValue];
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&agree_game_id=%d&agree_club_id=%d&game_type=%d", @"game_agree", gameID, clubID, gameType] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] ;
    

    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int nRoomID = 0;
    NSString *roomTitles = @"";
    
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localerror;
        NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
#ifdef DEMO_MODE
        NSLog(@"AGREEGAME = %@", rootDictionary);
#endif
        if (!rootDictionary)
        {
            error_code = ProtocolErrorTypeInvalidService;
        }
        else
        {
            int nDownState = [[rootDictionary objectForKey:@"succeed"] intValue];
            NSDictionary *dataObject = [rootDictionary objectForKey:@"data"];
            
            if (nDownState != 1 || !dataObject)
            {
                error_code = ProtocolErrorTypeAgreeFail;
            }
            else
            {
                int n = [[dataObject objectForKey:@"success"] intValue];
                if (n != 1) error_code = ProtocolErrorTypeAgreeFail;
                
                nRoomID = [[dataObject objectForKey:@"room_id"] intValue];
                roomTitles = [dataObject objectForKey:@"room_name"];
            }
        }
    }
    
    [self agreeGameResult:error_code withRoomID:nRoomID withRoomName:roomTitles];
    
}

- (void)agreeGameResult:(int)errorcode withRoomID:(int)nRoomID withRoomName:(NSString *)roomStr
{
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:errorcode],
                      [NSNumber numberWithInt:nRoomID],
                      roomStr,
                      nil];
    [self performSelectorOnMainThread:@selector(agreeGameComplete:) withObject:array waitUntilDone:YES];
}

- (void)agreeGameComplete:(NSArray *)array
{
    int error_code = [[array objectAtIndex:0] intValue];
    int nRoomID = [[array objectAtIndex:1] intValue];
    NSString *roomStr = [array objectAtIndex:2];
    
    if ([self.delegate respondsToSelector:@selector(agreeGameWithErrorCode:withRoomID:withRoomName:)])
        [self.delegate agreeGameWithErrorCode:error_code withRoomID:nRoomID withRoomName:roomStr ];
}
//BrowseClubMarks
- (void)browseClubMarkWithDelegate:(id<HttpManagerDelegate>)delegate club:(NSNumber *)club
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(browseClubMarks:) object:club];
    [thread start];
}

- (void)browseClubMarks:(NSNumber *)club
{
    int nClubID = [club intValue];
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&club_id=%d", @"browse_club_result", nClubID] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
#ifdef DEMO_MODE
        NSLog(@"browseclubMarks= %@", rootObject);
#endif
        
        if (!rootObject)
            error_code = ProtocolErrorTypeInvalidService;
        else
        {
            int nDownState = [[rootObject valueForKey:@"succeed"] intValue];
            NSDictionary *dataObject = [rootObject objectForKey:@"data"];
            
            if (nDownState != 1 || !dataObject || [dataObject isEqual:@""]) {
                error_code = ProtocolErrorTypeBrowseDataFail;
            }
            else
            {
                NSArray *listObjects = [dataObject objectForKey:@"result"];
                
                for (NSDictionary *item in listObjects) {
                    NSArray *mark = [NSArray arrayWithObjects:[item valueForKey:@"year"],
                                     [item valueForKey:@"all_game"],
                                     [item valueForKey:@"victor_game"],
                                     [item valueForKey:@"draw_game"],
                                     [item valueForKey:@"lose_game"],
                                     [item valueForKey:@"goal_point"],
                                     [item valueForKey:@"miss_point"],
                                     [item valueForKey:@"ga_point"], nil];
                    
                    [data addObject:mark];
                }
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(browseClubMarkResultWithErrorCode:data:)])
        [self.delegate browseClubMarkResultWithErrorCode:error_code data:data];
}

//BrowsePlayerMarks
- (void)browsePlayerMarkWithDelegate:(id<HttpManagerDelegate>)delegate club:(NSNumber *)clubid
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(browsePlayerMarks:) object:clubid];
    [thread start];
}

- (void)browsePlayerMarks:(NSNumber *)club
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&club_id=%d", @"browse_player_result", UID, [club intValue]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        [self.delegate browsePlayerMarkResultwithErrorCode:error_code data:nil];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
    
    if (!rootObject)
    {
        error_code = ProtocolErrorTypeInvalidService;
        [self.delegate browsePlayerMarkResultwithErrorCode:error_code data:nil];
        return;
    }
    
    int nDownState = [[rootObject valueForKey:@"succeed"] intValue];
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
            
    if (nDownState != 1 || !dataObject || [dataObject isEqual:@""]) {
        error_code = ProtocolErrorTypeBrowseDataFail;
        [self.delegate browsePlayerMarkResultwithErrorCode:error_code data:nil];
        return;
    }
    
    NSArray *listObjects = [dataObject objectForKey:@"result"];
                
    for (NSDictionary *item in listObjects) {
        NSArray *mark = [NSArray arrayWithObjects:[item valueForKey:@"year"],
                                [item valueForKey:@"game_count"],
                                [item valueForKey:@"goal_point"],
                                [item valueForKey:@"assist"],
                                [item valueForKey:@"point"], nil];
        
        [data addObject:mark];
    }
    
    if ([self.delegate respondsToSelector:@selector(browsePlayerMarkResultwithErrorCode:data:)])
        [self.delegate browsePlayerMarkResultwithErrorCode:error_code data:data];
}

//BrowseSchedule
- (void)browseScheduleWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(browseScheduleWithData:) object:data];
    [thread start];
}

- (void)browseScheduleWithData:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&club_id=%@&page=%@&type=%@", @"browse_schedule", [data objectAtIndex:0], [data objectAtIndex:1], [data objectAtIndex:2]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];

    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    int error_code = ProtocolErrorTypeNone;
    int nMoreState = 0;
    
    if (!resultData){
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
#ifdef DEMO_MODE
        NSLog(@"BrowseSchedule = %@", rootObject);
#endif
        if (!rootObject)
        {
            error_code = ProtocolErrorTypeInvalidService;
        }
        else
        {
            NSDictionary *dataObject = [rootObject objectForKey:@"data"];
            nMoreState = [[rootObject objectForKey:@"more"] intValue];
            
            if (!dataObject || [dataObject isEqual:@""])
            {
                error_code = ProtocolErrorTypeNoData;
            }
            else
            {
                NSArray *listObjects = [dataObject objectForKey:@"result"];
                
                for (NSDictionary *item in listObjects) {
                    GameScheduleRecord *record = [[GameScheduleRecord alloc] initWithGameListID:[[item valueForKey:@"game_list_id"] intValue]
                                                                                       gameType:[[item valueForKey:@"game_type"] intValue]
                                                                                       vsStatus:[[item valueForKey:@"vs_status"] intValue]
                                                                                       gameDate:[item valueForKey:@"game_date"]
                                                                                       gameTime:[item valueForKey:@"game_time"]
                                                                                        gameDay:[[item valueForKey:@"game_wday"] intValue]
                                                                                     gameResult:[item valueForKey:@"game_result"]
                                                                                           home:[item valueForKey:@"home_name"]
                                                                                           away:[item valueForKey:@"away_name"]
                                                                                   homeImageUrl:[item valueForKey:@"home_pic"]
                                                                                   awayImageUrl:[item valueForKey:@"away_pic"]
                                                                                         homeID:[[item valueForKey:@"home_id"] intValue]
                                                                                         awayID:[[item valueForKey:@"away_id"] intValue]
                                                                                     playerMode:[[item valueForKey:@"player_num_mode"] intValue]
                                                                                     homePlayer:[[item valueForKey:@"home_playercount"] intValue]
                                                                                     awayPlayer:[[item valueForKey:@"away_playercount"] intValue]
                                                                                    stadiumArea:[item valueForKey:@"stadium_area"]
                                                                                 stadiumAddress:[item valueForKey:@"stadium_address"]];
                    [array addObject:record];
                }
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(browseScheduleResultwithErrorCode:dataMore:data:)])
        [self.delegate browseScheduleResultwithErrorCode:error_code dataMore:nMoreState data:array];
}

//BrowseReqMember
- (void)browseReqMemberListWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(browseReqMemberList:) object:data];
    [thread start];
}

- (void)browseReqMemberList:(NSArray *)array
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&club_id=%@&page=%@", @"browse_reqmember_list", [array objectAtIndex:0], [array objectAtIndex:1]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    int error_code = ProtocolErrorTypeNone;
    int nMoreState = 0;
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localerror;
        NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
#ifdef DEMO_MODE
        NSLog(@"BrowseReqMember = %@", rootDictionary);
#endif
        if (!rootDictionary)
        {
            error_code = ProtocolErrorTypeInvalidService;
        }
        else
        {
            int nDownState = [[rootDictionary objectForKey:@"succeed"] intValue];
            nMoreState = [[rootDictionary objectForKey:@"more"] intValue];
            NSDictionary *dataObject = [rootDictionary objectForKey:@"data"];
            
            if (nDownState != 1 || !dataObject || [dataObject isEqual:@""])
            {
                error_code = ProtocolErrorTypeNoData;
            }
            else
            {
                NSArray *listObjects = [dataObject objectForKey:@"result"];
                
                for (NSDictionary *item in listObjects) {
                    PlayerListRecord *record = [[PlayerListRecord alloc] initWithPlayerID:[[item valueForKey:@"user_id"] intValue]
                                                                           PlayerImageUrl:[item valueForKey:@"user_icon"]
                                                                               playerName:[item valueForKey:@"user_name"]
                                                                                 position:[[item valueForKey:@"position"] intValue]
                                                                                     date:[item valueForKey:@"req_date"]];
                    [data addObject:record];
                }
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(browseReqMemberResultWithErrorCode:dataMore:data:)])
        [self.delegate browseReqMemberResultWithErrorCode:error_code dataMore:nMoreState data:data];
}

//AcceptReqest
- (void)acceptReqestWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(acceptRequest:) object:data];
    [thread start];
}

- (void)acceptRequest:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%@&req_type=%@&club_id=%@", @"accept_request", [data objectAtIndex:0], [data objectAtIndex:1], [data objectAtIndex:2]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData) {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else{
        NSError *localerror;
        NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootDictionary)
        {
            error_code = ProtocolErrorTypeInvalidService;
        }
        else{
            int nSucceed = [[rootDictionary objectForKey:@"succeed"] intValue];
            
            error_code = nSucceed == 1? ProtocolErrorTypeNone: ProtocolErrorTypeProcessFail;
        }
    }
    
    [self performSelectorOnMainThread:@selector(acceptRequestComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)acceptRequestComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(acceptRequestResultWithErrorCode:)])
        [self.delegate acceptRequestResultWithErrorCode:[number intValue]];
}

//InvAcceptReqest
- (void)acceptInvReqWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(acceptInvRequest:) object:data];
    [thread start];
}

- (void)acceptInvRequest:(NSArray *)data
{
    int nClubID = [[data objectAtIndex:0] intValue];
    int nType = [[data objectAtIndex:1] intValue];
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&club_id=%d&req_type=%d", @"accept_inv_req", UID, nClubID, nType] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData) {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else{
        NSError *localerror;
        NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootDictionary)
        {
            error_code = ProtocolErrorTypeInvalidService;
        }
        else{
            int nSucceed = [[rootDictionary objectForKey:@"succeed"] intValue];
            
            error_code = nSucceed == 1? ProtocolErrorTypeNone: ProtocolErrorTypeProcessFail;
        }
    }
    
    [self performSelectorOnMainThread:@selector(acceptInvReqComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)acceptInvReqComplete:(NSNumber *)data
{
    if ([self.delegate respondsToSelector:@selector(acceptInvReqResultWithErrorCode:)])
        [self.delegate acceptInvReqResultWithErrorCode:[data intValue]];

}

//TemporateInvitation
- (void)browseTempInvitationWithDelegate:(id<HttpManagerDelegate>)delegate
{
    self.delegate =delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(browseTempInvitation) object:nil];
    [thread start];
}

- (void)browseTempInvitation
{
    int page = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TEMPINV_PAGENO"] intValue];
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&page=%d", @"browse_temp_inv", UID, page] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    int error_code = ProtocolErrorTypeNone;
    int nMoreState = 0;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localerror;
        NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootDictionary)
        {
            error_code = ProtocolErrorTypeInvalidService;
        }
        else
        {
            NSDictionary *dataObject = [rootDictionary objectForKey:@"data"];
            int nDownState = [[rootDictionary objectForKey:@"succeed"] intValue];
            nMoreState = [[rootDictionary objectForKey:@"more"] intValue];
            
            if (nDownState != 1 || !dataObject || [dataObject isEqual:@""])
            {
                error_code = ProtocolErrorTypeBrowseDataFail;
            }
            else
            {
                NSArray *listObjects = [dataObject objectForKey:@"result"];
                for (NSDictionary *item in listObjects) {
                    int club_id = [[item valueForKey:@"club_id"] intValue];
                    NSString *club_name = [item valueForKey:@"club_name"];
                    NSString *mark_pic_url = [item valueForKey:@"mark_pic_url"];
                    int opp_club_id = [[item valueForKey:@"opp_club_id"] intValue];
                    NSString *opp_club_name =[item valueForKey:@"opp_club_name"];
                    NSString *opp_mark_pic_url = [item valueForKey:@"opp_mark_pic_url"];
//                    NSString *meesge = [item valueForKey:@"message"];
//                    NSString *end_date = [item valueForKey:@"end_date"];
//                    NSString *end_time = [item valueForKey:@"end_time"];
                    int home = [[item valueForKey:@"home"] intValue];
                    int game_id = [[item valueForKey:@"game_id"] intValue];
                    
                    ChallengeListRecord *record = [[ChallengeListRecord alloc] initWithSendClubName:home? club_name: opp_club_name
                                                                                       sendImageUrl:home? mark_pic_url: opp_mark_pic_url
                                                                                       recvClubName:home? opp_club_name: club_name
                                                                                       recvImageUrl:home? opp_mark_pic_url: mark_pic_url
                                                                                       playerNumber:[[item valueForKey:@"player_count"] intValue]
                                                                                           playDate:[item valueForKey:@"game_date"]
                                                                                            playDay:[[item valueForKey:@"game_weekday"] intValue]
                                                                                           playTime:[item valueForKey:@"game_time"]
                                                                                    playStadiumArea:[item valueForKey:@"stadium_area"]
                                                                                 playStadiumAddress:[item valueForKey:@"stadium_address"]
                                                                                         sendClubID:home? club_id: opp_club_id
                                                                                         recvClubID:home? opp_club_id: club_id
                                                                                             gameID:game_id
                                                                                       tempInvState:home
                                                   vcStatus:0
                                                   tempUnread:NO];
                    [data addObject:record];
                }
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(browseTempInvitationResultErrorCode:dataMore:data:)])
        [self.delegate browseTempInvitationResultErrorCode:error_code dataMore:nMoreState data:data];
}

//AcceptTempReqReqest
- (void)acceptTempInvReqWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(acceptTempInvReqest:) object:data];
    [thread start];
}

- (void)acceptTempInvReqest:(NSArray *)data
{
    int nClubID = [[data objectAtIndex:0] intValue];
    int nGameID = [[data objectAtIndex:1] intValue];
    int nType = [[data objectAtIndex:2] intValue];
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&club_id=%d&game_id=%d&req_type=%d", @"accept_temp_req", UID, nClubID, nGameID, nType] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    
    if (!resultData)
        error_code = ProtocolErrorTypeInvalidService;
    else{
        NSError *localerror;
        NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootDictionary)
            error_code = ProtocolErrorTypeInvalidService;
        else{
            NSDictionary *dataDictionary = [rootDictionary objectForKey:@"data"];
            
            if (!dataDictionary || [dataDictionary isEqual:@""])
                error_code = ProtocolErrorTypeInvalidService;
            else
                [[ClubManager sharedInstance] addClubs:dataDictionary];
        }
    }

    [self performSelectorOnMainThread:@selector(acceptTempInvRequestComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)acceptTempInvRequestComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(acceptTempInvReqResultErrorCode:)])
        [self.delegate acceptTempInvReqResultErrorCode:[number intValue]];
}

//SendTemporateInvitationRequest
- (void)sendTempInvRequestWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(sendTempInvRequest:) object:data];
    [thread start];
}

- (void)sendTempInvRequest:(NSArray *)data
{
    int nUserID = [[data objectAtIndex:0] intValue];
    int nClubID = [[data objectAtIndex:1] intValue];
    int nGameID = [[data objectAtIndex:2] intValue];
    NSString *message = [data objectAtIndex:3];
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&club_id=%d&game_id=%d&message=%@", @"send_temp_req", nUserID, nClubID, nGameID, message] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!resultData || [rootObject isEqual:@""])
        {
            error_code = ProtocolErrorTypeProcessFail;
        }
        else
        {
            int n = [[rootObject objectForKey:@"succeed"] intValue];
            
            switch (n) {
                case 1:
                    break;
                case 0:
                    error_code = ProtocolErrorTypeProcessFail;
                    break;
                case 2:
                    error_code = ProtocolErrorTypeInviteDuplicate;
                    break;
                case 3:
                    error_code = ProtocolErrorTypeHeIsYourClubMember;
                    break;
                default:
                    break;
            }
        }
    }
    
    [self performSelectorOnMainThread:@selector(sendTempInvRequestComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)sendTempInvRequestComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(sendTempInvRequestResultWithErrorCode:)])
        [self.delegate sendTempInvRequestResultWithErrorCode:[number intValue]];
}

//SendInvitationRequest
- (void)sendInvRequestWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(sendInvRequest:) object:data];
    [thread start];
}

- (void)sendInvRequest:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%@&club_id=%@", @"send_inv_request", [data objectAtIndex:0], [data objectAtIndex:1]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!resultData || [rootObject isEqual:@""])
        {
            error_code = ProtocolErrorTypeProcessFail;
        }
        else
        {
            int n = [[rootObject objectForKey:@"succeed"] intValue];
            
            switch (n) {
                case 1:
                    break;
                case 0:
                    error_code = ProtocolErrorTypeProcessFail;
                    break;
                case 2:
                    error_code = ProtocolErrorTypeInviteDuplicate;
                    break;
                case 3:
                    error_code = ProtocolErrorTypeHeIsYourClubMember;
                    break;
                case 4:
                    error_code = ProtocolErrorTypeInviteForbidden;
                    break;
                default:
                    break;
            }
        }
    }
    
    [self performSelectorOnMainThread:@selector(sendInvRequestComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
    
}

- (void)sendInvRequestComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(sendInvRequestResultWithErrorCode:)])
        [self.delegate sendInvRequestResultWithErrorCode:[number intValue]];

}
//RegisterUserToClub
- (void)registerUserToClubWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(registerUserToClub:) object:data];
    [thread start];
}

- (void)registerUserToClub:(NSArray *)data
{
#ifdef DEMO_MODE
    NSLog(@"RegisterUserToClub");
#endif
    
    int nPlayerID = [[data objectAtIndex:0] intValue];
    int nClubID = [[data objectAtIndex:1] intValue];
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&club_id=%d", @"register_user_to_club", nPlayerID, nClubID] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int nSucceed = 0;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootObject || [rootObject isEqual:@""])
        {
            error_code = ProtocolErrorTypeProcessFail;
        }
        else
        {
            nSucceed = [[rootObject objectForKey:@"succeed"] intValue];
            
            switch (nSucceed) {
                case 0:
                    error_code = ProtocolErrorTypeProcessFail;
                    break;
                case 1:
                    break;
                case 2:
                    error_code = protocolerrortypeJoinReqDuplicate;
                    break;
                case 3:
                    error_code = ProtocolErrorTypeJoinReqForbidden;
                default:
                    break;
            }
        }
    }
    
    [self performSelectorOnMainThread:@selector(registerUserToClubComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
    
}

- (void)registerUserToClubComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(registerUserToClubResultWithErrorCode:)])
        [self.delegate registerUserToClubResultWithErrorCode:[number intValue]];
}

//UserLogout
- (void)userLogoutWithDelegate:(id<HttpManagerDelegate>)delegate
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(userLogout) object:nil];
    [thread start];
}

- (void)userLogout
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d", @"user_logout", UID] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else{
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        int nSucceed = [[rootObject objectForKey:@"logout_status"] intValue];
        
        if (nSucceed != 1)
            error_code = ProtocolErrorTypeLogoutFail;

    }
    
    [self performSelectorOnMainThread:@selector(userLogoutComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)userLogoutComplete:(NSNumber *)data
{
    if ([self.delegate respondsToSelector:@selector(userLogoutResultWithErroCode:)])
        [self.delegate userLogoutResultWithErroCode:[data intValue]];
}

//DismisssClub
- (void)dismissClubWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(dismissClub:) object:data];
    [thread start];
}

- (void)dismissClub:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&club_id=%@&new_manager_id=%@", @"dismiss_club",
                        UID,
                        [data objectAtIndex:0],
                         [data objectAtIndex:1]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        int n = [[rootObject objectForKey:@"succeed"] intValue];
        
        if (n != 1)
            error_code = ProtocolErrorTypeDismissClubFail;
    }
    
    [self performSelectorOnMainThread:@selector(dismissClubComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)dismissClubComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(dismissClubResultWithErrorCode:)])
        [self.delegate dismissClubResultWithErrorCode:[number intValue]];
}

//SendChallenge
- (void)sendChallengeWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(sendchallenge:) object:data];
    [thread start];
}

- (void)sendchallenge:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&club_id=%@&game_date=%@&game_time=%@&player_count=%@&stadium_area=%@&stadium_address=%@&money_split=%@&req_club_id=%@&type=%@&create_type=%@&challenge_id=%@",
                         @"send_challenge",
                         [data objectAtIndex:0],
                         [data objectAtIndex:1],
                         [data objectAtIndex:2],
                         [data objectAtIndex:3],
                         [data objectAtIndex:4],
                         [data objectAtIndex:5],
                         [data objectAtIndex:6],
                         [data objectAtIndex:7],
                         [data objectAtIndex:8],
                         [data objectAtIndex:9],
                         [data objectAtIndex:10]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int nRoomID = 0;
    NSString *roomTitles = @"";
    if (!resultData)
        error_code = ProtocolErrorTypeInvalidService;
    else
    {
        NSError *localerror;
        NSDictionary*rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootObject)
            error_code = ProtocolErrorTypeInvalidService;
        else
        {
            NSDictionary *dataObject = [rootObject objectForKey:@"data"];
            int nSucceed = [[rootObject objectForKey:@"succeed"] intValue];
            if (!dataObject || nSucceed != 1 || [dataObject isEqual:@""])
                error_code = ProtocolErrorTypeProcessFail;
            else
            {
                int n = [[dataObject objectForKey:@"success"] intValue];
                if (n != 1)
                    error_code = ProtocolErrorTypeProcessFail;
                nRoomID = [[dataObject objectForKey:@"room_id"] intValue];
                roomTitles = [dataObject objectForKey:@"room_name"];
            }
            
        }
    }
    
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:error_code],
                      [NSNumber numberWithInt:nRoomID],
                      roomTitles,
                      nil];
    [self performSelectorOnMainThread:@selector(sendChallengeComplete:) withObject:array waitUntilDone:YES];
}

- (void)sendChallengeComplete:(NSArray *)array
{
    int error_code = [[array objectAtIndex:0] intValue];
    int nRoomID = [[array objectAtIndex:1] intValue];
    NSString *roomTitles = [array objectAtIndex:2];
    
    if ([self.delegate respondsToSelector:@selector(sendChallengeResultWithErrorCode:room:title:)])
        [self.delegate sendChallengeResultWithErrorCode:error_code room:nRoomID title:roomTitles];
}

//AdviseOpinion
- (void)adviseOpinionWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSString *)content
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(adviseOpinion:) object:content];
    [thread start];
}

- (void)adviseOpinion:(NSString *)content
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&content=%@", @"advise_opinion", UID, content] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localerror;
        NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        int nDownState = [[rootDictionary objectForKey:@"advise_status"] intValue];
        
        if (nDownState != 1)
        {
            error_code = ProtocolErrorTypeInvalidService;
        }
    }
    
[self performSelectorOnMainThread:@selector(adviseOpinionComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)adviseOpinionComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(adviseOpinionResultWithErrorCode:)])
        [self.delegate adviseOpinionResultWithErrorCode:[number intValue]];
}
//DelChallenge
- (void)delChallengeWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(delChallenge:) object:data];
    [thread start];
}

- (void)delChallenge:(NSArray *)data
{
    int nClubID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CLUBDETAIL_CLUBID"] intValue];
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&club_id=%d&game_id=%d&game_type=%d",
                         @"del_challenge",
                         nClubID,
                         [[data objectAtIndex:0] intValue],
                         [[data objectAtIndex:1] intValue]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else{
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootObject || [rootObject isEqual:@""])
            error_code = ProtocolErrorTypeProcessFail;
        
        int nState = [[rootObject objectForKey:@"del_status"] intValue];
        
        if (nState != 1)
            error_code = ProtocolErrorTypeProcessFail;
    }

    [self performSelectorOnMainThread:@selector(delChallengeComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)delChallengeComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(delChallengeResultWithErrorCode:)])
        [self.delegate delChallengeResultWithErrorCode:[number intValue]];
}

//SetUserOption
- (void)setUserOptionWithDelegate:(id<HttpManagerDelegate>)delegate
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(setUserOption) object:nil];
    [thread start];
}

- (void)setUserOption
{
    int nOption = [[[NSUserDefaults standardUserDefaults] objectForKey:@"USER_OPTION"] intValue];
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&option=%d", @"set_user_option", UID, nOption] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
        error_code = ProtocolErrorTypeInvalidService;
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootObject || [rootObject isEqual:@""])
            error_code = ProtocolErrorTypeInvalidService;
        else
        {
            int nSucceed = [[rootObject objectForKey:@"succeed"] intValue];
            if (nSucceed != 1)
                error_code = ProtocolErrorTypeProcessFail;
        }
        
    }
    
    [self performSelectorOnMainThread:@selector(setUserOptionComplete:) withObject:[NSArray arrayWithObject:[NSNumber numberWithInt:error_code]] waitUntilDone:YES];
}

- (void)setUserOptionComplete:(id)data
{
    int error_code = [[data objectAtIndex:0] intValue];
    if ([self.delegate respondsToSelector:@selector(setUserOptionResultWithErrorCode:)])
        [self.delegate setUserOptionResultWithErrorCode:error_code];
}

//GetClubSetting
- (void)getClubSettingWithDelegate:(id<HttpManagerDelegate>)delegate clubID:(NSNumber *)club
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(getClubSetting:) object:club];
    [thread start];
}

- (void)getClubSetting:(NSNumber *)number
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&club_id=%@", @"get_club_setting", UID, number] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int status = 0;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localeror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localeror];
        
        if (!rootObject || [rootObject isEqual:@""])
            error_code = ProtocolErrorTypeInvalidService;
        else
        {
            int nSucceed = [[rootObject objectForKey:@"succeed"] intValue];
            NSDictionary *dataObject = [rootObject objectForKey:@"data"];
            
            if (nSucceed != 1 || !dataObject || [dataObject isEqual:@""])
                error_code = ProtocolErrorTypeProcessFail;
            else{
                status = [[dataObject objectForKey:@"status"] intValue];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(getClubSettingResultWithErrorCode:state:)])
        [self.delegate getClubSettingResultWithErrorCode:error_code state:status];
}


//SetClubSetting
- (void)setClubSettingWithDelegate:(id<HttpManagerDelegate>)delegate
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(setClubSetting) object:nil];
    [thread start];
}

- (void)setClubSetting
{
    int nClubID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CLUBDETAIL_CLUBID"] intValue];
    int nStatus = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CLUBSETTING_STATUS"] intValue];
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&club_id=%d&status=%d", @"set_club_setting", UID, nClubID, nStatus] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int status = 0;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localeror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localeror];
        
        if (!rootObject || [rootObject isEqual:@""])
            error_code = ProtocolErrorTypeInvalidService;
        else
        {
            int nSucceed = [[rootObject objectForKey:@"succeed"] intValue];
            NSDictionary *dataObject = [rootObject objectForKey:@"data"];
            
            if (nSucceed != 1 || !dataObject || [dataObject isEqual:@""])
                error_code = ProtocolErrorTypeProcessFail;
            else{
                status = [[dataObject objectForKey:@"success"] intValue];
                
                error_code = status == 1? ProtocolErrorTypeNone: ProtocolErrorTypeProcessFail;
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(setClubSettingResultWithErrorCode:)])
        [self.delegate setClubSettingResultWithErrorCode:error_code];
}

//BreakDownClub
- (void)breakDownClubWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(breakDownClub:) object:data];
    [thread start];
}

- (void)breakDownClub:(NSArray *)array
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%@&club_id=%@", @"break_club", [array objectAtIndex:0], [array objectAtIndex:1]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
        error_code = ProtocolErrorTypeInvalidService;
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootObject || [rootObject isEqual:@""])
            error_code = ProtocolErrorTypeProcessFail;
        else
        {
            int n = [[rootObject objectForKey:@"break_status"] intValue];
            
            error_code = n == 1? ProtocolErrorTypeNone: ProtocolErrorTypeInvalidService;
        }
    }
    
    [self performSelectorOnMainThread:@selector(breakDownClubComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)breakDownClubComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(breakDownClubResultWithErrorCode:)])
        [self.delegate breakDownClubResultWithErrorCode:[number intValue]];
}
//ApplyGame
- (void)applyGameWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(applyGame:) object:data];
    [thread start];
}

- (void)applyGame:(NSArray *)data
{
    int nClubID = [[data objectAtIndex:0] intValue];
    int nGameID = [[data objectAtIndex:1] intValue];
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&club_id=%d&game_id=%d", @"apply_game", UID, nClubID, nGameID] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
        error_code = ProtocolErrorTypeInvalidService;
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootObject || [rootObject isEqual:@""])
            error_code = ProtocolErrorTypeProcessFail;
        else
            error_code = [[rootObject objectForKey:@"apply_status"] intValue];
    }
    
    [self performSelectorOnMainThread:@selector(applyGameComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)applyGameComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(applyGameResultWithErrorCode:)])
        [self.delegate applyGameResultWithErrorCode:[number intValue]];
}

//BrowseApplyGameList
- (void)browseApplyGameListWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(browseApplyGameList:) object:data];
    [thread start];
}

- (void)browseApplyGameList:(NSArray *)array
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&club_id=%@&game_id=%@&page=%@", @"browse_apply_game_list", [array objectAtIndex:0], [array objectAtIndex:1], [array objectAtIndex:2]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int nMoreState = 0;
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    if (!resultData)
        error_code = ProtocolErrorTypeNone;
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        nMoreState = [[rootObject objectForKey:@"more"] intValue];
        int nSucceed = [[rootObject objectForKey:@"succeed"] intValue];
        NSDictionary *dataObject = [rootObject objectForKey:@"data"];
        
        if (nSucceed != 1 || !dataObject || [dataObject isEqual:@""])
            error_code = ProtocolErrorTypeBrowseDataFail;
        else
        {
            NSArray *listObject = [dataObject objectForKey:@"result"];
            for (NSDictionary *item in listObject) {
                PlayerListRecord *record = [[PlayerListRecord alloc] initWithPlayerID:[[item valueForKey:@"user_id"] intValue]
                                                                       PlayerImageUrl:[item valueForKey:@"photo_url"]
                                                                           playerName:[item valueForKey:@"user_name"]
                                                                             position:[[item valueForKey:@"position"] intValue]
                                                                                 goals:[[item valueForKey:@"goal_point"] intValue]
                                                                              assists:[[item valueForKey:@"assist"] intValue] points:[[item valueForKey:@"point"] floatValue]];
                
                [data addObject:record];
            }
        }
        
    }
    
    if ([self.delegate respondsToSelector:@selector(browseApplyGameListWithErrorCode:dataMore:data:)])
        [self.delegate browseApplyGameListWithErrorCode:error_code dataMore:nMoreState data:data];
}

//GameCreate
- (void)gameCreateWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(gameCreate:) object:data];
    [thread start];
}

- (void)gameCreate:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&club_id=%@&game_date=%@&game_time=%@&player_count=%@&stadium_area=%@&stadium_address=%@&money_split=%@&req_club_name=%@",
                        @"game_create",
                        [data objectAtIndex:0],
                        [data objectAtIndex:1],
                        [data objectAtIndex:2],
                        [data objectAtIndex:3],
                        [data objectAtIndex:4],
                        [data objectAtIndex:5],
                        [data objectAtIndex:6],
                        [data objectAtIndex:7]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
        error_code = ProtocolErrorTypeInvalidService;
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootObject || [rootObject isEqual:@""])
            error_code = ProtocolErrorTypeProcessFail;
        else
        {
            int n = [[rootObject objectForKey:@"create_status"] intValue];
            
            switch (n) {
                case 0:
                    error_code = ProtocolErrorTypeProcessFail;
                    break;
                case 1:
                    break;
                case 2:
                    error_code = protocolerrortypeCreateDuplicate;
                    break;
                default:
                    break;
            }
        }
    }
    
    [self performSelectorOnMainThread:@selector(gameCreateComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];

}

- (void)gameCreateComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(gameCreateResultWithErrorCode:)])
        [self.delegate gameCreateResultWithErrorCode:[number intValue]];
}

//GetUserProfile
- (void)getUserProfileWithDelegate:(id<HttpManagerDelegate>)delegate
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(getUserProfile) object:nil];
    [thread start];
}

- (void)getUserProfile
{
    int nPlayerID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"USERPROFILE_PLAYERID"] intValue];
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d", @"get_user_profile", nPlayerID] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    PlayerListRecord *record;
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
        error_code = ProtocolErrorTypeInvalidService;
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootObject || [rootObject isEqual:@""])
            error_code = ProtocolErrorTypeBrowseDataFail;
        else
        {
            int n = [[rootObject objectForKey:@"succeed"] intValue];
            NSDictionary *dataObject = [rootObject objectForKey:@"data"];
            
            if (!dataObject || [dataObject isEqual:@""] || n != 1)
                error_code = ProtocolErrorTypeBrowseDataFail;
            else
            {
                NSString *photoUrl = [dataObject valueForKey:@"photo_url"];
                NSString *nick = [dataObject valueForKey:@"nick_name"];
                NSString *phoneNum = [dataObject valueForKey:@"phone_num"];
                int sex = [[dataObject valueForKey:@"sex"] intValue];
                NSString *birthday = [dataObject valueForKey:@"birthday"];
                int height = [[dataObject valueForKey:@"height"] intValue];
                int weight = [[dataObject valueForKey:@"weight"] intValue];
                int age = [[dataObject valueForKey:@"term"] intValue];
                int position = [[dataObject valueForKey:@"position"] intValue];
                NSString *city = [dataObject valueForKey:@"city"];
                int activeTime = [[dataObject valueForKey:@"activity_time"] intValue];
                NSString *activeArea = [dataObject valueForKey:@"activity_area"];
                
                record = [[PlayerListRecord alloc] initWithPlayerID:nPlayerID playerName:nick imageUrl:photoUrl playerSex:sex playerBithday:birthday playerHeight:height playerWeight:weight footballAge:age playerPosition:position playerCity:city playerWeek:activeTime activeArea:activeArea phone:phoneNum];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(getUserProfileResultWithErrorCode:data:)])
        [self.delegate getUserProfileResultWithErrorCode:error_code data:record];
}

//EditUserProfile
- (void)editUserProfileWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(editUserProfile:) object:data];
    [thread start];
}

- (void)editUserProfile:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&OldNick=%@&NewNick=%@&Photo_URL=%@&Sex=%@&Birthday=%@&Height=%@&Weight=%@&Term=%@&City=%@&Position=%@&ActivityArea=%@&ActivityTime=%@&user_id=%d",
                         @"edit_user_profile",
                        [data objectAtIndex:0],
                        [data objectAtIndex:1],
                        [data objectAtIndex:2],
                        [data objectAtIndex:3],
                        [data objectAtIndex:4],
                        [data objectAtIndex:5],
                        [data objectAtIndex:6],
                        [data objectAtIndex:7],
                        [data objectAtIndex:8],
                        [data objectAtIndex:9],
                        [data objectAtIndex:10],
                        [data objectAtIndex:11],
                         UID ] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localerror;
        NSDictionary *rootOject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootOject || [rootOject isEqual:@""]) {
            error_code = ProtocolErrorTypeInvalidService;
        }
        else
        {
            int n = [[rootOject valueForKey:@"edit_profile_status"] intValue];
            
            if (n == 0)
                error_code = ProtocolErrorTypeProcessFail;
            else if (n == 2)
                error_code = ProtocolErrorTypeNickNameDuplicate;
            else
                error_code = ProtocolErrorTypeNone;
            
        }
    }
    
    [self performSelectorOnMainThread:@selector(edituserProfileComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)edituserProfileComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(editUserProfileResultWithErrorCode:)])
        [self.delegate editUserProfileResultWithErrorCode:[number intValue]];
}

//CreateDiscuss
- (void)createDiscussWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(createDiscuss:) object:data];
    [thread start];
}

- (void)createDiscuss:(NSArray *)data
{
    NSString *postString = [NSString stringWithFormat:@"cmd=%@&user_id=%d&count=%d&type=%d", @"create_discuss", UID, data.count / 2, 1];
    
    for (int i = 0; i < (data.count / 2); i ++) {
        NSString *str = [NSString stringWithFormat:@"&img_%d=%@&content_%d=%@", i + 1, [data objectAtIndex:i * 2], i + 1, [data objectAtIndex:(i * 2 + 1)]];
        
        postString = [postString stringByAppendingString:str];
    }
    
    NSData *postData  = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int errorr_code = ProtocolErrorTypeNone;
    if (!resultData)
    {
        errorr_code = ProtocolErrorTypeInvalidService;
    }
    else
    {
        NSError *localerror;
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootObject || [rootObject isEqual:@""])
            errorr_code = ProtocolErrorTypeProcessFail;
        else
        {
            int n = [[rootObject objectForKey:@"create_discuss_status"] intValue];
            
            if (n != 1) {
                errorr_code = ProtocolErrorTypeProcessFail;
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(createDiscussResultWithErrorCode:)])
        [self.delegate createDiscussResultWithErrorCode:errorr_code];
}

//GetDiscussDetail
- (void)getDiscussDetailWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)array
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(getDiscussDetail:) object:array];
    [thread start];
}

- (void)getDiscussDetail:(NSArray *)array
{
    int nBBSID = [[array objectAtIndex:0] intValue];
    int nPage = [[array objectAtIndex:1] intValue];
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&bbs_id=%d&page=%d", @"get_discuss_detail", nBBSID, nPage] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int nMoreState = 0;
    int nSucceed = 0;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(getDiscussDetailResultWithErrorCode:more:header:article:)])
            [self.delegate getDiscussDetailResultWithErrorCode:error_code more:(int)0 header:nil article:nil];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
    if (!rootObject || [rootObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(getDiscussDetailResultWithErrorCode:more:header:article:)])
            [self.delegate getDiscussDetailResultWithErrorCode:error_code more:(int)0 header:nil article:nil];
        return;
    }

    nMoreState = [[rootObject objectForKey:@"more"] intValue];
    nSucceed = [[rootObject objectForKey:@"succeed"] intValue];
    
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
            
    if (nSucceed != 1 || !dataObject || [dataObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeNoData;
        
        if ([self.delegate respondsToSelector:@selector(getDiscussDetailResultWithErrorCode:more:header:article:)])
            [self.delegate getDiscussDetailResultWithErrorCode:error_code more:(int)0 header:nil article:nil];
        return;
    }
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSArray *headerDiscuss;

    if (nPage == 1)
    {
        NSDictionary *headerObject = [dataObject objectForKey:@"bbs_detail"];
        
        if (!headerObject || [headerObject isEqual:@""])
        {
            if ([self.delegate respondsToSelector:@selector(getDiscussDetailResultWithErrorCode:more:header:article:)])
                [self.delegate getDiscussDetailResultWithErrorCode:ProtocolErrorTypeInvalidService more:(int)0 header:nil article:nil];
            return;
        }
        
        headerDiscuss = [NSArray arrayWithObjects:[headerObject objectForKey:@"user_id"],
                         [headerObject objectForKey:@"user_name"],
                         [headerObject objectForKey:@"photo_url"],
                         [headerObject objectForKey:@"date"],
                         nil];

        NSArray *mainDiscuss = [dataObject objectForKey:@"content_arr"];
        
        for (NSDictionary *item in mainDiscuss) {
            DiscussDetailListRecord *record = [[DiscussDetailListRecord alloc] initWithImageUrl:[item valueForKey:@"img"]
                                                                                        content:[item valueForKey:@"content"]];
            [data addObject:record];
        }
    }
    
    NSArray *replyDiscuss = [dataObject objectForKey:@"discuss_reply"];
    
    for (NSDictionary *item in replyDiscuss) {
        DiscussDetailListRecord *record = [[DiscussDetailListRecord alloc] initWithDiscussID:[[item valueForKey:@"id"] intValue]
                                                                                      userID:[[item valueForKey:@"user_id"] intValue]
                                                                                    userName:[item valueForKey:@"user_name"]
                                                                                     content:[item valueForKey:@"content"]
                                                                                     replyID:[[item valueForKey:@"reply_id"] intValue]
                                                                                   replyDate:[item valueForKey:@"reply_date"]
                                                                                        deep:[[item valueForKey:@"depth"] intValue]];
        [data addObject:record];
    }
    
    if ([self.delegate respondsToSelector:@selector(getDiscussDetailResultWithErrorCode:more:header:article:)])
        [self.delegate getDiscussDetailResultWithErrorCode:error_code more:(int)nMoreState header:headerDiscuss article:data];
    
}

//EvalDiscuss
- (void)evalDiscussWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(evalDiscuss:) object:data];
    [thread start];
}

- (void)evalDiscuss:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&content=%@&reply_src=%@&reply_type=%@", @"eval_discuss", UID, [data objectAtIndex:0], [data objectAtIndex:1], [data objectAtIndex:2]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(evalDiscussResultWithErrorCode:data:)])
            [self.delegate evalDiscussResultWithErrorCode:error_code data:nil];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
    if (!rootObject || [rootObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeProcessFail;
        
        if ([self.delegate respondsToSelector:@selector(evalDiscussResultWithErrorCode:data:)])
            [self.delegate evalDiscussResultWithErrorCode:error_code data:nil];
        return;
    }
    
    int nState = [[rootObject objectForKey:@"eval_status"] intValue];
    
    if (nState != 1)
        error_code = ProtocolErrorTypeProcessFail;
    
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
    
    if (!dataObject || [dataObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeProcessFail;
        
        if ([self.delegate respondsToSelector:@selector(evalDiscussResultWithErrorCode:data:)])
            [self.delegate evalDiscussResultWithErrorCode:error_code data:nil];
        return;
    }
    
    NSArray *reply = [NSArray arrayWithObjects:[dataObject objectForKey:@"list_id"],
                      [dataObject objectForKey:@"user_id"],
                      [dataObject objectForKey:@"user_name"],
                      [dataObject objectForKey:@"reply_id"],
                      [dataObject objectForKey:@"reply_time"],
                      [dataObject objectForKey:@"depth"],
                      nil];
    
    if ([self.delegate respondsToSelector:@selector(evalDiscussResultWithErrorCode:data:)])
        [self.delegate evalDiscussResultWithErrorCode:error_code data:reply];
}

//GameResign
- (void)gameResignWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(gameResign:) object:data];
    [thread start];
}

- (void)gameResign:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&resign_game_id=%@&resign_club_id=%@&resign_cause=%@&resign_type=%@", @"game_resign", [data objectAtIndex:0], [data objectAtIndex:1], [data objectAtIndex:2], [data objectAtIndex:3]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (!resultData)
    {
        if ([self.delegate respondsToSelector:@selector(gameResignResultWithErrorCode:)])
            [self.delegate gameResignResultWithErrorCode:0];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
    if (!rootObject || [rootObject isEqual:@""])
    {
        if ([self.delegate respondsToSelector:@selector(gameResignResultWithErrorCode:)])
            [self.delegate gameResignResultWithErrorCode:0];
        return;
    }
    
    int n = [[rootObject valueForKeyPath:@"succeed"] intValue];
    NSDictionary *dataObject = [rootObject valueForKeyPath:@"data"];
    
    if (n != 1 || !dataObject || [dataObject isEqual:@""])
    {
        if ([self.delegate respondsToSelector:@selector(gameResignResultWithErrorCode:)])
            [self.delegate gameResignResultWithErrorCode:0];
        return;
    }
    
    n = [[dataObject valueForKeyPath:@"success"] intValue];
    
    if ([self.delegate respondsToSelector:@selector(gameResignResultWithErrorCode:)])
        [self.delegate gameResignResultWithErrorCode:n];
}

//CreateChattingRoom
- (void)createChattingRoomWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(createChattingRoom:) object:data];
    [thread start];
}

- (void)createChattingRoom:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%@&club_id=%@&chat_type=%@", @"create_chat_room", [data objectAtIndex:0], [data objectAtIndex:1], [data objectAtIndex:2]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        [self performSelectorOnMainThread:@selector(createChattingRoomComplete:)
                               withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], [NSNumber numberWithInt:0], nil]
                            waitUntilDone:YES];

        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
    if (!rootObject || [rootObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        [self performSelectorOnMainThread:@selector(createChattingRoomComplete:)
                               withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], [NSNumber numberWithInt:0], nil]
                            waitUntilDone:YES];

        return;
    }
    
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
    int nStatus = [[rootObject objectForKey:@"status"] intValue];
    
    if (nStatus == 0)
    {
        error_code = ProtocolErrorTypeCreateChattingRoomFail;
        
        [self performSelectorOnMainThread:@selector(createChattingRoomComplete:)
                               withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], [NSNumber numberWithInt:0], nil]
                            waitUntilDone:YES];

        return;
    }
    if ( !dataObject || [dataObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeCreateChattingRoomFail;
        
        [self performSelectorOnMainThread:@selector(createChattingRoomComplete:)
                               withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], [NSNumber numberWithInt:0], nil]
                            waitUntilDone:YES];

        return;
    }
    
    int nRoomId = [[dataObject valueForKey:@"room_id"] intValue];
    
    [self performSelectorOnMainThread:@selector(createChattingRoomComplete:)
                           withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], [NSNumber numberWithInt:nRoomId], nil]
                        waitUntilDone:YES];
}

- (void)createChattingRoomComplete:(id)data
{
    int error_code = [[data objectAtIndex:0] intValue];
    int nRoomId = [[data objectAtIndex:1] intValue];
    if ([self.delegate respondsToSelector:@selector(createChattingRoomWithErrorCode:withRoom:)])
        [self.delegate createChattingRoomWithErrorCode:error_code withRoom:nRoomId];
    
}

//createDiscussChatRoom
- (void)createDiscussChatRoomWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(createDiscussChatRoom:) object:data];
    [thread start];
}

- (void)createDiscussChatRoom:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&team1=%@&team2=%@&challenge_id=%@&player_count=%@", @"create_discuss_chat_room", [data objectAtIndex:0], [data objectAtIndex:1], [data objectAtIndex:2], [data objectAtIndex:3]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        [self createDiscussChatRoomResult:error_code withRoom:0 withRoomName:@""];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
    if (!rootObject || [rootObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        [self createDiscussChatRoomResult:error_code withRoom:0 withRoomName:@""];
        return;
    }
    
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
    int nStatus = [[rootObject objectForKey:@"status"] intValue];
    
    if (nStatus == 0)
    {
        error_code = ProtocolErrorTypeCreateChattingRoomFail;
        [self createDiscussChatRoomResult:error_code withRoom:0 withRoomName:@""];
        return;
    }
    if ( !dataObject || [dataObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeCreateChattingRoomFail;
        
        [self createDiscussChatRoomResult:error_code withRoom:0 withRoomName:@""];
        return;
    }
    
    int nRoomId = [[dataObject valueForKey:@"room_id"] intValue];
    NSString *roomStr = [dataObject valueForKey:@"room_name"];
    
    [self createDiscussChatRoomResult:error_code withRoom:nRoomId withRoomName:roomStr];
}

- (void)createDiscussChatRoomResult:(int)error_code withRoom:(int)nRoomId withRoomName:(NSString *)roomStr
{
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:error_code],
                      [NSNumber numberWithInt:nRoomId],
                      roomStr,
                      nil];
    [self performSelectorOnMainThread:@selector(createDiscussChatRoomComplete:) withObject:array waitUntilDone:YES];
}

- (void)createDiscussChatRoomComplete:(NSArray *)array
{
    int error_code = [[array objectAtIndex:0] intValue];
    int nRoomId = [[array objectAtIndex:1] intValue];
    NSString *roomStr = [array objectAtIndex:2];
    
    if ([self.delegate respondsToSelector:@selector(createDiscussChatRoomWithErrorCode:withRoom:withRoomName:)])
        [self.delegate createDiscussChatRoomWithErrorCode:error_code withRoom:nRoomId withRoomName:roomStr];
}
//setGameResult
- (void)setGameResultWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(setGameResult:) object:data];
    [thread start];
}

- (void)setGameResult:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&club_id=%@&game_id=%@&Fhalf_Goal1=%@&Shalf_Goal1=%@&Fhalf_Goal2=%@&Shalf_Goal2=%@&Match_Result=%@", @"set_game_result", [data objectAtIndex:0], [data objectAtIndex:1], [data objectAtIndex:2], [data objectAtIndex:3], [data objectAtIndex:4], [data objectAtIndex:5], [data objectAtIndex:6]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        [self performSelector:@selector(setGameResultComplete:) withObject:[NSNumber numberWithInteger:error_code] afterDelay:YES];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
    if (!rootObject || [rootObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        [self performSelector:@selector(setGameResultComplete:) withObject:[NSNumber numberWithInteger:error_code] afterDelay:YES];
        return;
    }
    
    int nStatus = [[rootObject objectForKey:@"set_status"] intValue];
    
    if (nStatus == 0)
    {
        error_code = ProtocolErrorTypeSetGameResultFail;
        
        [self performSelector:@selector(setGameResultComplete:) withObject:[NSNumber numberWithInteger:error_code] afterDelay:YES];
        return;
    }
    
    if (nStatus == 3)
    {
        error_code = ProtocolErrorTypeGameNotFinished;
        
        [self performSelector:@selector(setGameResultComplete:) withObject:[NSNumber numberWithInteger:error_code] afterDelay:YES];
        return;
    }

    [self performSelectorOnMainThread:@selector(setGameResultComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];

}

- (void)setGameResultComplete:(NSNumber *)error
{
    if ([self.delegate respondsToSelector:@selector(setGameResultResultWithErrorCode:)])
        [self.delegate setGameResultResultWithErrorCode:[error intValue]];
}

//SetUserPoint
- (void)setUserPointWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(setUserPoint:) object:data];
    [thread start];
}

- (void)setUserPoint:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&game_id=%@&club_id=%@&user_id=%@&goal_point=%@&assist=%@&point=%@", @"set_user_point", [data objectAtIndex:0], [data objectAtIndex:1], [data objectAtIndex:2], [data objectAtIndex:3], [data objectAtIndex:4], [data objectAtIndex:5]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil
                                                           error:nil];
    int error_code = ProtocolErrorTypeNone;
    
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        [self performSelectorOnMainThread:@selector(setUserPointComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
    if (!rootObject || [rootObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        [self performSelectorOnMainThread:@selector(setUserPointComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
        return;
    }
    
    int nStatus = [[rootObject objectForKey:@"status"] intValue];
    
    if (nStatus == 0)
    {
        error_code = ProtocolErrorTypeSetUserPointFail;
        
        [self performSelectorOnMainThread:@selector(setUserPointComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
        return;
    }
    
    [self performSelectorOnMainThread:@selector(setUserPointComplete:) withObject:[NSNumber numberWithInt:error_code] waitUntilDone:YES];
}

- (void)setUserPointComplete:(NSNumber *)number
{
    if ([self.delegate respondsToSelector:@selector(setUserPointResultWithErrorCode:)])
        [self.delegate setUserPointResultWithErrorCode:[number intValue]];
}

//GetGameResult
- (void)getGameResultWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(getGameResult:) object:data];
    [thread start];
}

- (void)getGameResult:(NSArray *) data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&game_id=%@", @"get_game_result", [data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        NSArray *retArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], nil];
        [self performSelectorOnMainThread:@selector(getGameResultComplete:) withObject:retArray waitUntilDone:YES];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
    int nSucceed = [[rootObject objectForKey:@"succeed"] intValue];
    
    if (nSucceed != 1)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        NSArray *retArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], nil];
        [self performSelectorOnMainThread:@selector(getGameResultComplete:) withObject:retArray waitUntilDone:YES];
        return;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:
                             [dataObject objectForKey:@"id1"],
                             [dataObject objectForKey:@"name1"],
                             [dataObject objectForKey:@"photo_url1"],
                             [[dataObject objectForKey:@"fhalf_goal1"] stringValue],
                             [[dataObject objectForKey:@"shalf_goal1"] stringValue],
                             [dataObject objectForKey:@"id2"],
                             [dataObject objectForKey:@"name2"],
                             [dataObject objectForKey:@"photo_url2"],
                             [[dataObject objectForKey:@"fhalf_goal2"] stringValue],
                             [[dataObject objectForKey:@"shalf_goal2"] stringValue],
                             [dataObject objectForKey:@"Match_Result"],
                             nil];
    
    NSArray *retArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], array, nil];
    [self performSelectorOnMainThread:@selector(getGameResultComplete:) withObject:retArray waitUntilDone:YES];
}

- (void)getGameResultComplete:(NSArray *)array
{
    int error_code = [[array objectAtIndex:0] intValue];
    NSArray *data = nil;
    
    if (array.count > 1)
        data = [array objectAtIndex:1];
    
    if ([self.delegate respondsToSelector:@selector(getGameResultResultWithErrorCode:data:)])
        [self.delegate getGameResultResultWithErrorCode:error_code data:data];
}

//GetAdminNews
- (void)getAdminNewsWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(getAdminNews:) object:data];
    [thread start];
}

- (void)getAdminNews:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&page=%@&user_id=%@", @"get_admin_news", [data objectAtIndex:0], [data objectAtIndex:1]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil
                                                           error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(getAdminNewsResultWithErrorCode:more:data:)])
            [self.delegate getAdminNewsResultWithErrorCode:error_code more:0 data:nil];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
    int nSucceed = [[rootObject objectForKey:@"succeed"] intValue];
    int nMore = [[rootObject objectForKey:@"more"] intValue];
    
    if (nSucceed != 1)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(getAdminNewsResultWithErrorCode:more:data:)])
            [self.delegate getAdminNewsResultWithErrorCode:error_code more:0 data:nil];
        return;
    }
    
    if (dataObject == nil || [dataObject isEqual:@""])
    {
        if ([self.delegate respondsToSelector:@selector(getAdminNewsResultWithErrorCode:more:data:)])
            [self.delegate getAdminNewsResultWithErrorCode:ProtocolErrorTypeNone more:0 data:nil];
        return;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *results = [dataObject objectForKey:@"result"];
    
    for (NSDictionary *item in results) {
        SystemConferenceListRecord *record = [[SystemConferenceListRecord alloc]
                                              initWithUser:[item objectForKey:@"user_name"]
                                              date:[item objectForKey:@"date"]
                                              time:[item objectForKey:@"time"]
                                              weekDay:[[item objectForKey:@"weekday"] intValue]
                                              appeal:[item objectForKey:@"appeal_content"]
                                              answer:[item objectForKey:@"answer_content"]];
        [array addObject:record];
    }

    if ([self.delegate respondsToSelector:@selector(getAdminNewsResultWithErrorCode:more:data:)])
        [self.delegate getAdminNewsResultWithErrorCode:error_code more:nMore data:array];
}

//getGameDetail
- (void)getGameDetailWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(getGameDetail:) object:data];
    [thread start];
}

- (void)getGameDetail:(NSArray *)array
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&game_id=%@&type=%@", @"get_game_detail", [array objectAtIndex:0], [array objectAtIndex:1]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(getGameDetailResultWithErrorCode:data:)])
            [self.delegate getGameDetailResultWithErrorCode:error_code data:nil];
        return;
    }
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
#ifdef DEMO_MODE
    NSLog(@"rootObject = %@", rootObject);
#endif
    
    NSDictionary *dataObject = [rootObject objectForKey:@"data"];
    int nSucceed = [[rootObject objectForKey:@"succeed"] intValue];
    
    if (nSucceed != 1 || [dataObject isEqual:@""])
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(getGameDetailResultWithErrorCode:data:)])
            [self.delegate getGameDetailResultWithErrorCode:error_code data:nil];
        return;
    }
    
    ChallengeListRecord *record = [[ChallengeListRecord alloc] initWithSendClubName:[dataObject valueForKey:@"club_name_01"]
                                                                       sendImageUrl:[dataObject valueForKey:@"mark_pic_url_01"]
                                                                       recvClubName:[dataObject valueForKey:@"club_name_02"]
                                                                       recvImageUrl:[dataObject valueForKey:@"mark_pic_url_02"]
                                                                       playerNumber:[[dataObject valueForKey:@"player_count"] intValue]
                                                                           playDate:[dataObject valueForKey:@"game_date"]
                                                                            playDay:[[dataObject valueForKey:@"game_weekday"] intValue]
                                                                           playTime:[dataObject valueForKey:@"game_time"]
                                                                    playStadiumArea:[dataObject valueForKey:@"stadium_area"]
                                                                 playStadiumAddress:[dataObject valueForKey:@"stadium_address"]
                                                                         sendClubID:[[dataObject valueForKey:@"club_id_01"] intValue]
                                                                         recvClubID:[[dataObject valueForKey:@"club_id_02"] intValue]
                                                                             gameID:[[dataObject valueForKey:@"challenge_id"] intValue]
                                                                       tempInvState:0
                                                                           vcStatus:[[dataObject objectForKey:@"vs_status"] intValue]
                                                                         tempUnread:NO];

    NSArray *tmpArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:error_code], record, nil];
    [self performSelectorOnMainThread:@selector(getGameDetailResultComplete:) withObject:tmpArray waitUntilDone:YES];
}

- (void)getGameDetailResultComplete:(NSArray *)array
{
    int error_code = [[array objectAtIndex:0] intValue];
    ChallengeListRecord *record = (ChallengeListRecord *)[array objectAtIndex:1];

    if ([self.delegate respondsToSelector:@selector(getGameDetailResultWithErrorCode:data:)])
        [self.delegate getGameDetailResultWithErrorCode:error_code data:record];
}

- (void)getCheckMemberAndClubScheduleCountWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(checkMember:) object:data];
    [thread start];
}

/*
- (void)getClubScheduleCount:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&club_id=%@", @"club_schedule_count", [data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int count = 0;
    
    NSError *localerror;
    NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
    
    NSLog(@"rootObject = %@", rootObject);
    if (!rootObject || [rootObject isEqual:@""])
        error_code = ProtocolErrorTypeInvalidService;
    else
    {
        count = [[rootObject objectForKey:@"count"] intValue];
    }
    
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:error_code],
                      [NSNumber numberWithInt: count],
                      nil];
    
    [self performSelectorOnMainThread:@selector(getClubScheduleCountComplete:) withObject:array waitUntilDone:YES];
}

- (void)getClubScheduleCountComplete:(NSArray *) data
{
    if ([self.delegate respondsToSelector:@selector(getClubScheduleCountResultWithErrorCode:count:)])
        [self.delegate getClubScheduleCountResultWithErrorCode:[[data objectAtIndex:0] intValue] count:[[data objectAtIndex:1] intValue]];
}
*/
- (void)getUserIDWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(getUserID:) object:data];
    [thread start];
}

- (void)getUserID:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_name=%@", @"get_user_id", [data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    NSError *localerror;
    NSString *uid = @"";
    
    if (!resultData)
        error_code = ProtocolErrorTypeInvalidService;
    else
    {
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootObject || [rootObject isEqual:@""])
            error_code = ProtocolErrorTypeInvalidService;
        else
            uid = [rootObject objectForKey:@"user_id"];
    }
    
    NSArray *array = [NSArray arrayWithObjects:
                      [NSNumber numberWithInt:error_code],
                      uid,
                      nil];
    
    [self performSelectorOnMainThread:@selector(getUserIDComplete:) withObject:array waitUntilDone:YES];
}

- (void)getUserIDComplete:(NSArray *)data
{
    int error_code = [[data objectAtIndex:0] intValue];
    int uid = [[data objectAtIndex:1] intValue];
    
    if ([self.delegate respondsToSelector:@selector(getUserIDResultWithErrorCode:uid:)])
        [self.delegate getUserIDResultWithErrorCode:error_code uid:uid];
}

- (void)getMasterDataWithDelegate:(id<HttpManagerDelegate>)delegate data :(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(getMasterData:) object:data];
    [thread start];
}

- (void)getMasterData:(NSArray *)data
{
    lastUpdateTime = [[Sqlite3Manager sharedInstance] lastReceivedChattingTimeAllRoom];
    if ([lastUpdateTime isEqualToString:@""])
        lastUpdateTime = [DateManager StringDateWithFormat:@"yyyy-MM-dd HH:mm:ss" date:[NSDate date]];
    
#ifdef DEMO_MODE
    NSLog(@"%@마지막채팅시간 %@", LOGTAG, lastUpdateTime);
#endif
    
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%d&last_updated_time=%@", @"get_masterdata", UID, lastUpdateTime] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    NSError *localerror;
    
    if (!resultData)
        error_code = ProtocolErrorTypeInvalidService;
    else
    {
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        NSArray *chatArray = [rootObject objectForKey:@"offline_chat_content"];
        
        for (NSDictionary *dict in chatArray) {
            ChatMessage *newMsg = [ChatMessage new];
            newMsg.msg = [Common EmojiFilterTo:[dict objectForKey:@"content"]];
            newMsg.roomId = [[dict objectForKey:@"chat_room_id"] intValue];
            newMsg.senderId = [[dict objectForKey:@"sender_id"] intValue];
            newMsg.sendTime = [dict objectForKey:@"sendtime"];
            newMsg.senderName = [dict objectForKey:@"sender_name"];
            newMsg.userPhoto = [dict objectForKey:@"sender_photo"];
            newMsg.readState = 0;
            newMsg.sendState = 1;
            
            if ([newMsg.msg hasPrefix:@"Create new discuss room"] ||
                [newMsg.msg hasPrefix:@"create new discuss room"] ||
                [newMsg.msg hasPrefix:@"Update discuss room"] ||
                [newMsg.msg hasPrefix:@"update discuss room"])
                continue;
            
            if ([newMsg.msg hasSuffix:@"jpg"])
                newMsg.type = MESSAGE_TYPE_IMAGE;
            else if ([newMsg.msg hasSuffix:@"gga"])
                newMsg.type = MESSAGE_TYPE_AUDIO;
            else
                newMsg.type = MESSAGE_TYPE_TEXT;

            [ChatMessage addChatMessage:newMsg];
            [[NotificationManager sharedInstance] notify:newMsg.msg who:newMsg.senderName type:newMsg.type];
        }

    }

//    [self performSelectorOnMainThread:@selector(getMasterDataComplete:) withObject:nil waitUntilDone:YES];
}

- (void)checkMemberWithDelegate:(id<HttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(checkMember:) object:data];
    [thread start];
}

- (void)checkMember:(NSArray *)data
{
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%@&club_id=%@", @"check_member", [data objectAtIndex:0], [data objectAtIndex:1]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = ProtocolErrorTypeNone;
    int count = 0;
    int check = 0;
    
    NSError *localerror;
    
    if (!resultData)
        error_code = ProtocolErrorTypeInvalidService;
    else
    {
        NSDictionary *rootObject = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&localerror];
        
        if (!rootObject || [rootObject isEqual:@""])
            error_code = ProtocolErrorTypeInvalidService;
        else
        {
            int success = [[rootObject objectForKey:@"succeed"] intValue];
            if (success != 1)
                error_code = ProtocolErrorTypeInvalidService;
            else
            {
                check = [[rootObject objectForKey:@"status"] intValue];
                count = [[rootObject objectForKey:@"count"] intValue];
            }
        };
    }
    
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:error_code],
                      [NSNumber numberWithInt:count],
                      [NSNumber numberWithInt:check],
                      nil];

    [self performSelectorOnMainThread:@selector(checkMemberComplete:) withObject:array waitUntilDone:YES];

}

- (void)checkMemberComplete:(NSArray *)number
{
    int error = [[number objectAtIndex:0] intValue];
    int count = [[number objectAtIndex:1] intValue];
    int check = [[number objectAtIndex:2] intValue];
    
    if ([self.delegate respondsToSelector:@selector(getCheckMemberAndClubScheduleCountResultWithErrorCode:count:check:)])
        [self.delegate getCheckMemberAndClubScheduleCountResultWithErrorCode:error count:count check:check];
}

- (void)getMasterDataComplete:(NSArray *)data
{
    if ([self.delegate respondsToSelector:@selector(getMasterDataResult)])
        [self.delegate getMasterDataResult];
}
#pragma UserDefined
- (NSMutableURLRequest *)requestWithData:(NSData *)postData;
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postLength = [NSString stringWithFormat:@"%d", postData.length];
    [request setURL:[NSURL URLWithString:GOALGROUPURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:5];
    return request;
}

#pragma 화일다운로드
- (void)downloadVoiceMail:(id<HttpManagerDelegate>)delegate filePath:(NSString *)filePath recordIdx:(int)recordIdx
{
    self.delegate = delegate;
    thread = [[NSThread new] initWithTarget:self
                                   selector:@selector(downloadVoiceMailThread:)
                                     object:[NSArray arrayWithObjects:filePath, [NSNumber numberWithInt:recordIdx], nil]];
    [thread start];
}

- (void)downloadVoiceMailThread:(NSArray *)data
{
    NSString *filePath = [data objectAtIndex:0];
    int recordIdx = [[data objectAtIndex:1] intValue];
    
    NSLog(@"downloadFileThread started");
    NSLog(@"download url = %@", filePath);
    NSURL *url = [NSURL URLWithString:filePath];
    NSData *fileData = [NSData dataWithContentsOfURL:url];

    if (!fileData)
    {
        [self performSelectorOnMainThread:@selector(downloadVoiceMailCompleted:)
                               withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], nil, nil, nil]
                            waitUntilDone:YES];
    }
    
    //Success
    NSString *voiceFilePath = [FileManager GetVoiceFilePath:[filePath MD5]];
    if (![FileManager WriteDataToFilePath:voiceFilePath fileData:fileData])
    {
        NSLog(@"write data to file path: %@ failed", voiceFilePath);
        return;
    }
    [self performSelectorOnMainThread:@selector(downloadVoiceMailCompleted:)
                           withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:0], voiceFilePath, [NSNumber numberWithInt:recordIdx], nil]
                        waitUntilDone:YES];
}

- (void)downloadVoiceMailCompleted:(NSArray *)data
{
    int errorcode = [[data objectAtIndex:0] intValue];
    NSString *filePath = [data objectAtIndex:1];
    int recordIdx = [[data objectAtIndex:2] intValue];
    
    [self.delegate downloadVoiceMailResultWithErrorCode:errorcode filePath:filePath recordIdx:recordIdx];
}

@end
