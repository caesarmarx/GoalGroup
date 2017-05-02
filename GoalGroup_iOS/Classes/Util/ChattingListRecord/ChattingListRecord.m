//
//  ChattingListRecord.m
//  GoalGroup
//
//  Created by KCHN on 2/1/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ChattingListRecord.h"
#import "Common.h"
@implementation ChattingListRecord

- (id) initWithChattingName:(NSString *)Name
                      intro:(NSString *)Intro
                       time:(NSString *)Time
                 thumbimage:(UIImage *)Image;
{
    self.chattingName = Name == nil ? @"name": Name;
    self.chattingIntro = Intro == nil? @"intro": Intro;
    self.chattingTime = Time == nil? @"time": Time;
    self.chattingImage = Image == nil? [UIImage imageNamed:@"man_default"]:Image;
    return self;
}

- (NSString *)stringWithIntro
{
    return self.chattingIntro;
}

- (NSString *)stringWithName
{
    return self.chattingName;
}

- (NSString *)stringWithTime
{
    return self.chattingTime;
}

- (UIImage *)imageWithThumbnail
{
    return self.chattingImage;
}
@end

@implementation ChattingManager

+ (ChattingManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gChattingManager == nil)
            gChattingManager = [[ChattingManager alloc] init];
    }
    return gChattingManager;
}



@end