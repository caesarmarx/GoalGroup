//
//  LoginManager.m
//
//  Created by JinYongHao on 9/26/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import "LoginManager.h"
#import "FileManager.h"
#import "Common.h"

@implementation LoginManager

+ (LoginManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gLoginManager == nil)
            gLoginManager = [[LoginManager alloc] init];
    }
    return gLoginManager;
}

+ (BOOL)checkIsAlreadyLogin
{
    NSString *filePath = [FileManager GetLoginFilePath];
    NSData *fileData = [FileManager GetDataFromFilePath:filePath];
    if (!fileData)
        return NO;
    NSString *loginData = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSArray *loginDataItems = [loginData componentsSeparatedByString:@"¶"];

    [[NSUserDefaults standardUserDefaults] setObject:[loginDataItems objectAtIndex:0] forKey:@"LOGIN_DATA_USER"];
    [[NSUserDefaults standardUserDefaults] setObject:[loginDataItems objectAtIndex:1] forKey:@"LOGIN_DATA_PASS"];
    [[NSUserDefaults standardUserDefaults] setObject:[loginDataItems objectAtIndex:2] forKey:@"LOGIN_DATA_UID" ];

    UID = [[loginDataItems objectAtIndex:2] intValue];
    MyDeviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DEVICE_TOKEN"];
    if (MyDeviceToken == nil) {
        MyDeviceToken = @"";
    }
    
    return YES;
}

- (BOOL)logOut
{
    NSString *filePath = [FileManager GetLoginFilePath];
    BOOL result = [FileManager DeleteFile:filePath];
    if (result == NO)
        return NO;
    
    return YES;
}

- (void)setIsAlreadyLoginWithNickname:(NSString *)user password:(NSString *)pass uid:(int)uid
{
    NSString *loginFilePath = [FileManager GetLoginFilePath];
    NSString *loginData = [NSString stringWithFormat:@"%@¶%@¶%i", user, pass, uid];
    [FileManager WriteDataToFilePath:loginFilePath fileData:[loginData dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
