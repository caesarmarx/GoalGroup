//
//  DemandListRecord.m
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DemandListRecord.h"

@implementation DemandListRecord

- (id)initWithClubID:(int)c_id title:(NSString *)title thumbImageUrl:(NSString *)imgUrl date:(NSString *)date time:(NSString *)time read:(BOOL)read
{
    clubID = c_id;
    thumbImageUrl = imgUrl;
    titleStr = title;
    dateStr = date;
    timeStr = time;
    bUnread = read;
    return self;
}

- (NSString *)imageUrlWithDemandLetter
{
    return thumbImageUrl;
}

- (NSString *)stringWithDate
{
    return dateStr;
}

- (NSString *)stringWithTitle
{
    return titleStr;
}

- (NSString *)stringWithTime
{
    return timeStr;
}

- (int)intWithClubID
{
    return clubID;
}
- (BOOL)booleanWithUnread
{
    return bUnread;
}

- (void)itemRead
{
    bUnread = NO;
}
@end


@implementation DemandListManager

+ (DemandListManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gDemandListManager == nil)
            gDemandListManager = [[DemandListManager alloc] init];
    }
    return gDemandListManager;
}
@end