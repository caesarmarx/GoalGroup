//
//  DiscussListRecord.h
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscussListRecord : NSObject
{
    NSString *imageDiscussUrl;
    NSString *imageOfferUrl;
    NSString *titleDiscuss;
    NSString *nameOffer;
    NSString *introDiscuss;
    NSString *timeDiscuss;
    int counts;
    int discuss_id;
}

- initWithID:(int)d_id imageDiscussUrl:(NSString *)img1Url
            imageOfferUrl:(NSString *)img2Url
          titleDiscuss:(NSString *)title
             nameOffer:(NSString *)name
          introDisucss:(NSString *)intro
           timeDiscuss:(NSString *)time
              dicussCount:(int)count;

- (NSString *)imageWithDiscussUrl;
- (NSString *)imageWithOfferUrl;
- (NSString *)stringWithTitle;
- (NSString *)stringWithOffer;
- (NSString *)stringWithIntroduce;
- (NSString *)stringWithTime;
- (int)intWithReplyCount;
- (int)intWithDiscussID;

@end

@class DiscussListManager;
DiscussListManager *gDiscussListManager;

@interface DiscussListManager : NSObject

+ (DiscussListManager *)sharedInstance;

@end

