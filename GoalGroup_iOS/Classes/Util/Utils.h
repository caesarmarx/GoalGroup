//
//  Utils.h
//  Kid Health Journal
//
//  Created by System Administrator on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject {
    
}

+ (UIImage *)rotateImage:(UIImage *)image;
+ (NSString *)uuid;
+ (void) showAlertMessage:(NSString *)message;


+ (NSString *)calcDateDiffFromNow:(NSDate *)date flag:(BOOL)flag;
+ (NSString *)calcDateDiff:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSDate *)addDate:(NSDate *)fromDate addType:(int)addType addVal:(int)addVal;
+ (NSDate *)subDate:(NSDate *)fromDate subType:(int)subType subVal:(int)subVal;

+ (NSDate *) getDateFromString:(NSString *)strDate;
+ (NSString *) getStringFromDate:(NSDate *)date;
+ (NSString *) getStringFromShortDate:(NSDate *)date;
+ (NSDate *) getDateTimeFromString:(NSString *)strDate;
+ (NSString *) getStringFromDateTime:(NSDate *)date;
+ (NSString *)getStringFromTime:(NSDate *)time;
+ (NSDate *)getTimeFromString:(NSString *)strTime;
+ (NSString*)stringWithWeekDay:(NSInteger)weekday;

+ (NSDate *)getNSDateFromTimestamp:(int)timestampVal;
+ (NSString *)getTimestampWithTimezone:(NSDate *)date;
+ (NSString *)getDateStrFromTimeStamp:(int)timestampVal;
+ (int)getTimestampFromDateTimeStr:(NSString *)dateStr;
+ (int)getTimestampFromDateStr:(NSString *)dateStr;

+ (BOOL)checkStringIsValidFloatNumber:(NSString *)checkString;
+ (BOOL)checkStringIsValidInteger:(NSString *)checkString;
+ (BOOL)checkStringISMailAddress:(NSString *)checkString;

+ (void)showWarningAlertMsg:(NSString *)message;

+ (double)customRound:(double)value precision:(int)precision;

+ (int)getYearFromDate:(NSDate *)date;
+ (int)getMonthFromDate:(NSDate *)date;
+ (int)getDayFromDate:(NSDate *)date;
+ (int)getHourFromDate:(NSDate *)date;
+ (int)getMinuteFromDate:(NSDate *)date;
+ (int)getSecondFromDate:(NSDate *)date;

+ (void)removeNotificationByDate:(NSString *)dateStr;


@end
