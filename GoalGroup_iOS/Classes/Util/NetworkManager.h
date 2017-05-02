//
//  NetworkManager.h
//
//  Created by JinYongHao on 10/10/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@class NetworkManager;
NetworkManager *gNetworkManager;

@interface NetworkManager : NSObject
{
    Reachability *internetReachability;
}

@property BOOL internetActive;

+ (NetworkManager *)sharedInstance;
- (void)checkNetworkStatus:(NSNotification *)notice;


@end
