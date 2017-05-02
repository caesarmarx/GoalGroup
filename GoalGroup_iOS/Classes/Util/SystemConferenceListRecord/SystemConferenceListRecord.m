//
//  SystemConferenceListRecord.m
//  GoalGroup
//
//  Created by MacMini on 4/20/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "SystemConferenceListRecord.h"
#import "WeekSelectController.h"
#import "Common.h"

@implementation SystemConferenceListRecord

- (id)initWithUser:(NSString *)user date:(NSString *)date time:(NSString *)time weekDay:(int)weekday appeal:(NSString *)appeal answer:(NSString *)answer
{
    strUser = user == nil? @"" : user;
    strDate = date == nil? @"" : date;
    strTime = time == nil? @"" : time;
    strWeekDay = [DAYSDI objectAtIndex:weekday];
    strAppeal = appeal == nil? @"" : appeal;
    strAnswer = answer == nil? @"" : answer;

    return self;
}

- (NSString *)stringUserName
{
    return strUser;
}

- (NSString *)stringDate
{
    return strDate;
}

- (NSString *)stringTime
{
    return strTime;
}

- (NSString *)stringWeekDay
{
    return strWeekDay;
}

- (NSString *)stringAppeal
{
    return strAppeal;
}

- (NSString *)stringAnswer
{
    return strAnswer;
}
@end
