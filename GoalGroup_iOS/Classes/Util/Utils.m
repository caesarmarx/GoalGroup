//
//  Utils.m
//  Kid Health Journal
//
//  Created by System Administrator on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "Constants.h"

#import "ggaAppDelegate.h"
#import "Common.h"

@implementation Utils

+(UIImage *)rotateImage:(UIImage *)image
{
    CGImageRef imgRef = image.CGImage;  
    
    CGFloat width = CGImageGetWidth(imgRef);  
    CGFloat height = CGImageGetHeight(imgRef);  
    
    CGAffineTransform transform = CGAffineTransformIdentity;  
    CGRect bounds = CGRectMake(0, 0, width, height);  
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));  
    CGFloat boundHeight;  
    UIImageOrientation orient = image.imageOrientation;  
    switch(orient) {  
            
        case UIImageOrientationUp: //EXIF = 1  
            transform = CGAffineTransformIdentity;  
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2  
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);  
            transform = CGAffineTransformScale(transform, -1.0, 1.0);  
            break;
            
        case UIImageOrientationDown: //EXIF = 3  
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);  
            transform = CGAffineTransformRotate(transform, M_PI);  
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4  
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);  
            transform = CGAffineTransformScale(transform, 1.0, -1.0);  
            break;  
            
        case UIImageOrientationLeftMirrored: //EXIF = 5  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);  
            transform = CGAffineTransformScale(transform, -1.0, 1.0);  
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
            break;  
            
        case UIImageOrientationLeft: //EXIF = 6  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);  
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeScale(-1.0, 1.0);  
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
            break;  
            
        case UIImageOrientationRight: //EXIF = 8  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);  
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
            break;  
            
        default:  
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];  
            
    }  
    
    UIGraphicsBeginImageContext(bounds.size);  
    
    CGContextRef context = UIGraphicsGetCurrentContext();  
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {  
        CGContextScaleCTM(context, -1, 1);  
        CGContextTranslateCTM(context, -height, 0);  
    }  
    else {  
        CGContextScaleCTM(context, 1, -1);  
        CGContextTranslateCTM(context, 0, -height);  
    }  
    
    CGContextConcatCTM(context, transform);  
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);  
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();  
    
    return imageCopy;
}

+ (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)
                      uuidStringRef];
    CFRelease(uuidStringRef);
    return uuid;
}

+ (void) showAlertMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:message 
                                                   delegate:self 
                                          cancelButtonTitle:LANGUAGE(@"ok")
                                          otherButtonTitles:nil];
    [alert show];
}

+(NSDate *) getDateFromString:(NSString *)strDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    
    NSDate *dobDate = [dateFormatter dateFromString:strDate];
    
    return dobDate;
}

+(NSString *) getStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+(NSString *) getStringFromShortDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM"];
    
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+(NSDate *) getDateTimeFromString:(NSString *)strDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone *timezone = [NSTimeZone defaultTimeZone];
    [dateFormatter setTimeZone:timezone];
    
    [dateFormatter setDateFormat:@"dd MMM yyyy hh:mm a"];
    
    NSDate *dobDate = [dateFormatter dateFromString:strDate];
    
    return dobDate;
}

+(NSString *) getStringFromDateTime:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone *timezone = [NSTimeZone defaultTimeZone];
    [dateFormatter setTimeZone:timezone];
    
    [dateFormatter setDateFormat:@"dd MMM yyyy hh:mm a"];
    
    NSString *strDate = [dateFormatter stringFromDate:date];
    
    return strDate;
}

+ (NSString *)getStringFromTime:(NSDate *)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    
    NSString *timeStr = [formatter stringFromDate:time];
    
    return timeStr;
}

+ (NSDate *)getTimeFromString:(NSString *)strTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];

    NSDate *time = [formatter dateFromString:strTime];
    
    return time;
}

+ (NSDate *)addDate:(NSDate *)fromDate addType:(int)addType addVal:(int)addVal
{
    NSDate *date;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    
    if(addType == 0) //Year
    {
        [offsetComponents setYear:addVal];
    }
    else if(addType == 1) //Month
    {
        [offsetComponents setMonth:addVal];
    }
    else //Day
    {
        [offsetComponents setDay:addVal];
    }
    
    date = [gregorian dateByAddingComponents:offsetComponents toDate: fromDate options:0];

    
    return date;
}

+ (NSDate *)subDate:(NSDate *)fromDate subType:(int)subType subVal:(int)subVal
{
    NSDate *date;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    
    if(subType == 0) //Year
    {
        [offsetComponents setYear:subVal * (-1)];
    }
    else if(subType == 1) //Month
    {
        [offsetComponents setMonth:subVal * (-1)];
    }
    else //Day
    {
        [offsetComponents setDay:subVal * (-1)];
    }
    
    date = [gregorian dateByAddingComponents:offsetComponents toDate: fromDate options:0];

    
    return date;
}

+(NSString *)calcDateDiffFromNow:(NSDate *)date flag:(BOOL)flag
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date toDate:[NSDate date] options:0];
    
    NSString *retStr;
    
    if(components.year == 0 && components.month == 0 && components.day == 0)
    {
        if(flag)    //Calc Date Of Birthday
            retStr = [NSString stringWithFormat:@"Just born"];
        else        //Calc difference date of medical record created.
            retStr = [NSString stringWithFormat:@"Just born"];
    }
    else if(components.year == 0)
    {
        if(components.month == 0)
            retStr = [NSString stringWithFormat:@"%ld days", components.day];
        else if(components.day == 0)
            retStr = [NSString stringWithFormat:@"%ld months", components.month];
        else
            retStr = [NSString stringWithFormat:@"%ld months %ld days", components.month, components.day];
    }
    else if(components.month == 0)
        retStr = [NSString stringWithFormat:@"%ld years %d month", components.year, 1];
    else
        retStr = [NSString stringWithFormat:@"%ld years %ld months", components.year, components.month];
    
    return retStr;
}

+(NSString *)calcDateDiff:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
    
    NSString *retStr;
    
    if(components.year == 0 && components.month == 0 && components.day == 0)
    {
        retStr = [NSString stringWithFormat:@"Just born"];
    }
    else if(components.year == 0)
    {
        if(components.month == 0)
            retStr = [NSString stringWithFormat:@"%ld days", components.day];
        else if(components.day == 0)
            retStr = [NSString stringWithFormat:@"%ld months", components.month];
        else
            retStr = [NSString stringWithFormat:@"%ld months %ld days", components.month, components.day];
    }
    else if(components.month == 0)
        retStr = [NSString stringWithFormat:@"%ld years %d month", components.year, 1];
    else
        retStr = [NSString stringWithFormat:@"%ld years %ld months", components.year, components.month];
    
    return retStr;
}

+(NSDate *)getNSDateFromTimestamp:(int)timestampVal
{
    NSDate *date;
    
    date = [NSDate dateWithTimeIntervalSince1970:timestampVal];
    
    return date;
}

+(NSString *)getTimestampWithTimezone:(NSDate *)date
{
    NSUInteger createDate = [date timeIntervalSince1970];
    int timezone = (int)[[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
    NSString *timestampStr = @"";
    
    if(timezone > 0)
        timestampStr = [NSString stringWithFormat:@"%ld000+%.2d00", createDate, timezone];
    else
        timestampStr = [NSString stringWithFormat:@"%ld000%.2d00", createDate, timezone];

    return timestampStr;
}

+(NSString *)getDateStrFromTimeStamp:(int)timestampVal
{
    NSDate *date;
    
    date = [NSDate dateWithTimeIntervalSince1970:timestampVal];
    
    NSString *dateStr = [Utils getStringFromDateTime:date];
    
    return dateStr;
}

+ (int)getTimestampFromDateTimeStr:(NSString *)dateStr
{
    NSDate *date = [Utils getDateTimeFromString:dateStr];
    
    int timestampVal = [date timeIntervalSince1970];
    
    return timestampVal;
}

+ (int)getTimestampFromDateStr:(NSString *)dateStr
{
    NSDate *date = [Utils getDateFromString:dateStr];
    
    int timestampVal = [date timeIntervalSince1970];
    
    return timestampVal;
}

+ (NSString*)stringWithWeekDay:(NSInteger)weekday
{
    NSString* week_day[] = {
        LANGUAGE(@"week_sun"),
        LANGUAGE(@"week_mon"),
        LANGUAGE(@"week_tue"),
        LANGUAGE(@"week_web"),
        LANGUAGE(@"week_thu"),
        LANGUAGE(@"week_fri"),
        LANGUAGE(@"week_sat")
    };
    
    if (weekday == 0)
        return week_day[6];
    return week_day[weekday-1];
}

+ (BOOL)checkStringIsValidFloatNumber:(NSString *)checkString
{
    if(checkString == nil)
        return YES;
    
    NSString *filterString = @"[0-9]*\\.?[0-9]*";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filterString];
    
    return [numberTest evaluateWithObject:checkString];
}

+ (BOOL)checkStringIsValidInteger:(NSString *)checkString
{
    NSString *filterString = @"^(0{0,2}[1-9]|0?[1-9][0-9]|[1-9][0-9][0-9])$";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filterString];
    
    return [numberTest evaluateWithObject:checkString];
}

+ (BOOL)checkStringISMailAddress:(NSString *)checkString
{
    if(checkString == nil)
        return NO;
    
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
	NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
	NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:checkString];
}

+ (void)showWarningAlertMsg:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:LANGUAGE(@"ok") otherButtonTitles:nil];
    [alert show];
}

+ (double)customRound:(double)value precision:(int)precision
{
    double val = value, retVal;
	int preci = precision;
	char strB[64];
	memset(strB, 0, 64);
    
	if(precision >= 0)
		sprintf(strB, "%.*f", precision, val);
	else
	{
		while(preci)
		{
			val /= 10;
			preci++;
		}
		sprintf(strB, "%.*f", preci, val);
		val = atof(strB);
		memset(strB, 0, 64);
        
		while(preci != precision)
		{
			val *= 10;
			preci--;
		}
		sprintf(strB, "%.*f", preci, val);
	}
    
	retVal = atof(strB);
    
	return retVal;
}

+ (int)getYearFromDate:(NSDate *)date
{
    if(date == nil)
        return 0;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [gregorian components:units fromDate:date];
    
    int year = [components year];

    return year;
}

+ (int)getMonthFromDate:(NSDate *)date
{
    if(date == nil)
        return 0;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [gregorian components:units fromDate:date];
    
    int month = [components month];
    

    
    return month;
}

+ (int)getDayFromDate:(NSDate *)date
{
    if(date == nil)
        return 0;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [gregorian components:units fromDate:date];
    
    int day = [components day];
    

    
    return day;
}

+ (int)getHourFromDate:(NSDate *)date
{
    if(date == nil)
        return 0;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [gregorian components:units fromDate:date];
    
    int hour = [components hour];
    

    
    return hour;
}

+ (int)getMinuteFromDate:(NSDate *)date
{
    if(date == nil)
        return 0;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [gregorian components:units fromDate:date];
    
    int min = [components minute];
    

    
    return min;
}

+ (int)getSecondFromDate:(NSDate *)date
{
    if(date == nil)
        return 0;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [gregorian components:units fromDate:date];
    
    int sec = [components second];
    
 
    
    return sec;
}
+ (void)removeNotificationByDate:(NSString *)dateStr
{
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    NSDate *date = [Utils getDateTimeFromString:dateStr];
    
    for (int i = 0; i < [allNotifications count]; i++)
    {
        UILocalNotification *notification = [allNotifications objectAtIndex:i];
        if([notification.fireDate isEqualToDate:date])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            break;
        }
    }
}

@end
