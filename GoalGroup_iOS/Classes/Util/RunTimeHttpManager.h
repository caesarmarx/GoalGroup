//
//  RunTimeHttpManager.h
//  GoalGroup
//
//  Created by MacMini on 5/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RunTimeHttpManagerDelegate<NSObject>
@optional
- (void)getRuntimeDetailResultWithErrorCode:(int)errorcode;
@end

@class RunTimeHttpManager;
RunTimeHttpManager *gRunTimeHttpManager;

@interface RunTimeHttpManager : NSObject
{
    NSThread *thread;
}

@property (nonatomic, assign) id<RunTimeHttpManagerDelegate> delegate;

+ (RunTimeHttpManager *)newInstance;
+ (RunTimeHttpManager *)sharedInstance;
- (void)getRuntimeDetailWithDelegate:(id<RunTimeHttpManagerDelegate>)delegate data:(NSArray *)data;

@end
