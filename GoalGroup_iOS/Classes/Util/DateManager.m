//
//  DateManager.m
//
//  Created by JinYongHao on 9/27/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import "DateManager.h"

@implementation DateManager

+ (DateManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gDateManager == nil)
            gDateManager = [[DateManager alloc] init];
    }
    return gDateManager;
}

+ (NSInteger)SecondsDiffFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    return [toDate timeIntervalSinceDate:fromDate];
}

+ (NSInteger)DaysDiffFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    return (int)[toDate timeIntervalSinceDate:fromDate] / 86400;
}

+ (NSInteger)hoursDiffFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    return (int)[toDate timeIntervalSinceDate:fromDate] / 3600;
}

+ (NSString *)StringDateWithFormat:(NSString *)format date:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:format];
    return [df stringFromDate:date];
}

+ (NSDate *)DateFromString:(NSString *)string
{
    if (string == nil)
        return nil;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate *d = [df dateFromString:string];
    return [df dateFromString:string];
}

@end
