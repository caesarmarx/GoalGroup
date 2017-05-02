//
//  NetworkManager.m
//
//  Created by JinYongHao on 10/10/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import "NetworkManager.h"
#import "Common.h"

@implementation NetworkManager

+ (NetworkManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gNetworkManager == nil)
            gNetworkManager = [[NetworkManager alloc] init];
    }
    return gNetworkManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //JHG
        self.internetActive = NO;
        //self.internetActive = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkNetworkStatus:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        internetReachability = [Reachability reachabilityForInternetConnection];
        [internetReachability startNotifier];
    }
    return self;
}

- (void)checkNetworkStatus:(NSNotification *)notice
{
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"Ther internet is down.");
            self.internetActive = NO;
        //    self.internetActive = YES;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            break;
        }
            
        default:
            break;
    }
}

@end
