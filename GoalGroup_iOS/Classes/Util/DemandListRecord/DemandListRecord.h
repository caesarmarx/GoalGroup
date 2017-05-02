//
//  DemandListRecord.h
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DemandListRecord : NSObject
{
    NSString *thumbImageUrl;
    NSString *titleStr;
    NSString *dateStr;
    NSString *timeStr;
    int clubID;
    BOOL bUnread;
}

- (id)initWithClubID:(int)c_id
               title:(NSString *)title
       thumbImageUrl:(NSString *)imgUrl
                date:(NSString *)date
                time:(NSString *)time
                read:(BOOL)read;

- (NSString *)imageUrlWithDemandLetter;
- (NSString *)stringWithTitle;
- (NSString *)stringWithDate;
- (NSString *)stringWithTime;
- (int)intWithClubID;
- (BOOL)booleanWithUnread;
- (void)itemRead;

@end

@class DemandListManager;
DemandListManager *gDemandListManager;

@interface DemandListManager : NSObject

+ (DemandListManager *) sharedInstance;

@end
