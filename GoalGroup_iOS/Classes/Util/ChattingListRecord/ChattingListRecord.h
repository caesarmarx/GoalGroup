//
//  ChattingListRecord.h
//  GoalGroup
//
//  Created by KCHN on 2/1/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChattingListRecord : NSObject

@property NSString *chattingName;
@property NSString *chattingIntro;
@property NSString *chattingTime;
@property UIImage   *chattingImage;

- (id) initWithChattingName:(NSString *)Name
                      intro:(NSString *)Intro
                       time:(NSString *)Time
                 thumbimage:(UIImage *)Image;
- (NSString *)stringWithName;
- (NSString *)stringWithIntro;
- (NSString *)stringWithTime;
- (UIImage *)imageWithThumbnail;

@end

@class ChattingManager;
ChattingManager *gChattingManager;

@interface ChattingManager : NSObject

+ (ChattingManager *)sharedInstance;

@end