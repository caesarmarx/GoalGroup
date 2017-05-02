//
//  NSWeek.m
//  GoalGroup
//
//  Created by KCHN on 3/6/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "NSWeek.h"
#import "Common.h"

@implementation NSWeek

+ (NSString *)stringWithIntegerWeek:(int)intWeek
{
    NSString *workDay = @"";
    for (int i = 6; i >= 0 ; i--)
    {
        if ((int)(intWeek / pow(2,i)) == 1)
        {
            NSString *tmp = [DAYS objectAtIndex:i];
            workDay = [tmp stringByAppendingString:workDay];
            workDay = [@"," stringByAppendingString:workDay];
            intWeek = intWeek - pow(2, i);
        }
    }
    
    if (workDay.length > 1)
        workDay = [workDay substringFromIndex:1];
    return workDay;
}

+ (NSInteger)intWithStringWeek:(NSString *)strWeek
{
    NSArray *workDayArray = [strWeek componentsSeparatedByString:@","];
    int workDate = 0;
    for (int i= 0; i < workDayArray.count;  i++) {
        for (int j= 0; j < 7; j ++) {
            NSString *workDayItem = [workDayArray objectAtIndex:i];
            if ([workDayItem  isEqual:[DAYS objectAtIndex:j]]) {
                workDate += pow(2, j);
            }
        }
    }
    return workDate;
}

+ (NSString *)stringWithLinearIntegerWeek:(int)intWeek
{
    return [DAYSDI objectAtIndex:intWeek];
}
@end
