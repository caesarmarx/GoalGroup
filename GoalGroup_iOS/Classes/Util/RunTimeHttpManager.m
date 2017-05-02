//
//  RunTimeHttpManager.m
//  GoalGroup
//
//  Created by MacMini on 5/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "RunTimeHttpManager.h"
#import "DiscussRoomManager.h"
#import "Common.h"

@implementation RunTimeHttpManager
{
    int nTmpInvCount;
    int nTmpTempInvCount; //Added By Boss.2015/05/28
}

#pragma Initialization
+ (RunTimeHttpManager *)newInstance
{
    return [[RunTimeHttpManager alloc] init];
}

+ (RunTimeHttpManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gRunTimeHttpManager == nil)
            gRunTimeHttpManager = [[RunTimeHttpManager alloc] init];
    }
    return gRunTimeHttpManager;
}

//GetRuntimeDetail
- (void)getRuntimeDetailWithDelegate:(id<RunTimeHttpManagerDelegate>)delegate data:(NSArray *)data
{
    self.delegate = delegate;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(getRuntimeDetail:) object:data];
    [thread start];
}

- (void)getRuntimeDetail:(NSArray *)data
{
    
#ifdef DEMO_MODE
    NSLog(@"runtimeHttp");
#endif
    NSData *postData = [[NSString stringWithFormat:@"cmd=%@&user_id=%@&club_id=%@&last_time=%@", @"get_runtime_detail", [data objectAtIndex:0], [data objectAtIndex:1], [data objectAtIndex:2]] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [self requestWithData:postData];
    
    NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    int error_code = 0;
    if (!resultData)
    {
        error_code = ProtocolErrorTypeInvalidService;
        
        if ([self.delegate respondsToSelector:@selector(getRuntimeDetailResultWithErrorCode:)])
            [self.delegate getRuntimeDetailResultWithErrorCode:error_code];
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
        error_code = 10;
        
        if ([self.delegate respondsToSelector:@selector(getRuntimeDetailResultWithErrorCode:)])
            [self.delegate getRuntimeDetailResultWithErrorCode:error_code];
        return;
    }
    
    nNewsCount = [[dataObject objectForKey:@"news_cnt"] intValue];
    
    /**Modified By Boss.2015/05/28**/
    nTmpInvCount = [[dataObject objectForKey:@"inv_cnt"] intValue];
    nTmpTempInvCount = [[dataObject objectForKey:@"tempinv_cnt"] intValue];
    
    if (nTmpInvCount != nInvCount) {
        nInvCount = nTmpInvCount;
        
        ggaAppDelegate* appDelegate = APP_DELEGATE;
        ResearchViewController *rsView = (ResearchViewController *)appDelegate.tabBC.childViewControllers[3];
        [rsView refreshCount];
    }
    
    if (nTmpTempInvCount != nTmpInvCount) {
        nTempInvCount = nTmpTempInvCount;
        
        ggaAppDelegate* appDelegate = APP_DELEGATE;
        ResearchViewController *rsView = (ResearchViewController *)appDelegate.tabBC.childViewControllers[3];
        [rsView refreshCount];
    }
    /**********************************/
    
    NSArray *clubs = [[NSMutableArray alloc] initWithArray:[dataObject objectForKey:@"club_info"]];
    [[ClubManager sharedInstance] setClubs:clubs];
    
    NSArray *discussChatArray = [dataObject objectForKey:@"discuss_chat_room"];
    [[DiscussRoomManager sharedInstance] setDiscussChatRooms:discussChatArray];
    
    curSystemTimeStr = [dataObject objectForKey:@"server_time"];
    
#ifdef DEMO_MODE
    NSLog(@"%@현재 체계시간은 %@입니다", LOGTAG, curSystemTimeStr);
#endif
    
    if ([self.delegate respondsToSelector:@selector(getRuntimeDetailResultWithErrorCode:)])
        [self.delegate getRuntimeDetailResultWithErrorCode:error_code];
}

#pragma UserDefined
- (NSMutableURLRequest *)requestWithData:(NSData *)postData;
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postLength = [NSString stringWithFormat:@"%lu", postData.length];
    [request setURL:[NSURL URLWithString:GOALGROUPURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:5];
    return request;
}

@end
