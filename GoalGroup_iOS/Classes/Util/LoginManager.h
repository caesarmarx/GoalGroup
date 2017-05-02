//
//  LoginManager.h
//
//  Created by JinYongHao on 9/26/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import <Foundation/Foundation.h>



@class LoginManager;
LoginManager *gLoginManager;



@interface LoginManager : NSObject

+ (LoginManager *)sharedInstance;
+ (BOOL)checkIsAlreadyLogin;
- (BOOL)logOut;
- (void)setIsAlreadyLoginWithNickname:(NSString *)user password:(NSString *)pass uid:(int)uid;

@end
