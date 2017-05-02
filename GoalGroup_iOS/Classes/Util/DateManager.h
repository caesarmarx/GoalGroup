//
//  DateManager.h
//
//  Created by JinYongHao on 9/27/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATE_TIME_FORMAT          @"yyyy-MM-dd HH:mm"
#define ALL_DATE_TIME_FORMAT      @"yyyy/MM/dd HH:mm:ss"

@class DateManager;
DateManager *gDateManager;

@interface DateManager : NSObject

+ (DateManager *)sharedInstance;
+ (NSInteger)SecondsDiffFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSInteger)DaysDiffFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSInteger)hoursDiffFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSString *)StringDateWithFormat:(NSString *)format date:(NSDate *)date;
+ (NSDate *)DateFromString:(NSString *)string;

@end
