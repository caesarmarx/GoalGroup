//
//  DiscussListRecord.m
//  GoalGroup
//
//  Created by KCHN on 2/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DiscussListRecord.h"

@implementation DiscussListRecord


- (id)initWithID:(int)d_id imageDiscussUrl:(NSString *)img1Url imageOfferUrl:(NSString *)img2Url titleDiscuss:(NSString *)title nameOffer:(NSString *)name introDisucss:(NSString *)intro timeDiscuss:(NSString *)time dicussCount:(int)count
{
    imageDiscussUrl = img1Url;
    imageOfferUrl = img2Url;
    titleDiscuss = title;
    nameOffer = name;
    introDiscuss = intro;
    timeDiscuss = time;
    counts = count;
    discuss_id = d_id;
    return self;
}

- (NSString *) imageWithDiscussUrl
{
    return imageDiscussUrl;
}

- (NSString *)imageWithOfferUrl
{
    return imageOfferUrl;
}

- (NSString *)stringWithTitle
{
    return titleDiscuss;
}

- (NSString *)stringWithOffer
{
    return nameOffer;
}

- (NSString *)stringWithIntroduce
{
    return introDiscuss;
}

- (NSString *)stringWithTime
{
    return timeDiscuss;
}

- (int)intWithDiscussID
{
    return discuss_id;
}

- (int)intWithReplyCount
{
    return counts;
}
@end


@implementation DiscussListManager

+ (DiscussListManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gDiscussListManager == nil)
            gDiscussListManager = [[DiscussListManager alloc] init];
    }
    return gDiscussListManager;
}


@end