//
//  NSPosition.m
//  GoalGroup
//
//  Created by KCHN on 3/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "NSPosition.h"
#import "Common.h"

@implementation NSPosition

+ (NSString *)stringDetailWithIntegerPosition:(int)intPosition
{
    NSString *pos = @"";
    for (int i = 10; i >= 0 ; i--)
    {
        if ((int)(intPosition / pow(2,i)) == 1)
        {
            NSString *tmp = [DETAILPOSITIONS objectAtIndex:i];
            pos = [tmp stringByAppendingString:pos];
            pos = [@"," stringByAppendingString:pos];
            intPosition = intPosition - pow(2, i);
        }
    }
    
    if (pos.length > 1)
        pos = [pos substringFromIndex:1];
    return pos;
}

+ (NSString *)stringPrefixDetailWithIntegerPosition:(int)intPosition
{
    NSString *pos = @"";
    for (int i = 10; i >= 0 ; i--)
    {
        if ((int)(intPosition / pow(2,i)) == 1)
        {
            NSString *tmp = [POSITIONS objectAtIndex:i];
            pos = [tmp stringByAppendingString:pos];
            pos = [@"," stringByAppendingString:pos];
            intPosition = intPosition - pow(2, i);
        }
    }
    
    if (pos.length > 1)
        pos = [pos substringFromIndex:1];
    return pos;
}

+ (NSString *)stringFirstWithIntegerPosition:(int)intPosition
{
    if (intPosition == 0)
        return [POSITIONS objectAtIndex: 0];
    NSString *strDetail = [NSPosition stringDetailWithIntegerPosition:intPosition];
    NSArray *strDetailArray = [strDetail componentsSeparatedByString:@","];
    if (strDetailArray == nil)
        return [POSITIONS objectAtIndex: 0];
    int detailPositionIndex = [DETAILPOSITIONS indexOfObject:[strDetailArray objectAtIndex:0]];
    return [POSITIONS objectAtIndex:detailPositionIndex];
}

+ (NSInteger)intDetailWithStringPosition:(NSString *)strPosition
{
    NSArray *positions = [strPosition componentsSeparatedByString:@","];
    int pos = 0;
    for (int i= 0; i < positions.count;  i++) {
        for (int j= 0; j < 11; j ++) {
            NSString *workDayItem = [positions objectAtIndex:i];
            if ([workDayItem  isEqual:[DETAILPOSITIONS objectAtIndex:j]]) {
                pos += pow(2, j);
            }
        }
    }
    return pos;
}

+ (NSInteger)intWithStringPosition:(NSString *)strPosition
{
    int ret = 0;
    
    NSArray *inputPosition = [strPosition componentsSeparatedByString:@","];
    for (int j = 0; j < inputPosition.count ; j++)
    {
        for (int i = 0; i < ((NSArray *)POSITIONS).count; i ++) {
            NSString *str = [POSITIONS objectAtIndex:i];
            if ([[inputPosition objectAtIndex:j] isEqualToString:str])
                ret = ret + (int)pow(2, i);
        }
    }
    
    return ret == 0? 2047: ret;
}

+ (NSString *)stringPositionWithIntegerPosition:(int)intPosition
{
    NSString *pos = @"";
    for (int i = 10; i >= 0 ; i--)
    {
        if ((int)(intPosition / pow(2,i)) == 1)
        {
            NSString *tmp = [POSITIONS objectAtIndex:i];
            pos = [tmp stringByAppendingString:pos];
            pos = [@"," stringByAppendingString:pos];
            intPosition = intPosition - pow(2, i);
        }
    }
    
    if (pos.length > 1)
        pos = [pos substringFromIndex:1];
    return pos;
}

+ (NSString *)formattedStringFromPLAYERDETAIL_POSITION:(NSString *)strPosition
{
    NSString *resultString = strPosition;
    NSArray *prefix_titles = [NSArray arrayWithArray:POSITIONS];
    NSArray *titles = [NSArray arrayWithArray:DETAILPOSITIONS];
    
    NSArray *arrPosition = [strPosition componentsSeparatedByString:@","];
    if (arrPosition == nil || arrPosition.count == 0) {
        return @"";
    }
    
    NSInteger index = -1;
    resultString = @"";
    int posIndex = 0;
    
    for(posIndex = 0; posIndex < arrPosition.count; posIndex ++) { //Modified By Boss.2015/06/03 Because of 前卫,边前卫
        index = [titles indexOfObject:arrPosition[posIndex]];
        if (index < 0 || index == NSNotFound) {
            continue;
        }
        resultString = [resultString stringByAppendingString:[NSString stringWithFormat:@"%@", titles[index]]];
        if (posIndex != (arrPosition.count - 1)) {
            resultString = [resultString stringByAppendingString:@"\r\n"];
        }
    }
    
    return resultString;
}

+ (NSString *)formattedStringFromPLAYERDETAIL_POSITIONInARow:(NSString *)strPosition
{
    NSString *resultString = strPosition;
    NSArray *prefix_titles = [NSArray arrayWithArray:POSITIONS];
    NSArray *titles = [NSArray arrayWithArray:DETAILPOSITIONS];
    
    NSArray *arrPosition = [strPosition componentsSeparatedByString:@","];
    if (arrPosition == nil || arrPosition.count == 0) {
        return @"";
    }
    
    NSInteger index = -1;
    resultString = @"";
    int posIndex = 0;
    
    for(posIndex = 0; posIndex < arrPosition.count; posIndex ++) { //Modified By Boss.2015/06/03 Because of 前卫,边前卫
        index = [titles indexOfObject:arrPosition[posIndex]];
        if (index < 0 || index == NSNotFound) {
            continue;
        }
        resultString = [resultString stringByAppendingString:[NSString stringWithFormat:@"%@", titles[index]]];
    }
    
    return resultString;
}

+ (NSString *)getPLAYERDETAIL_POSITIONFromFormattedString:(NSString *)strPosition
{
    NSString *resultString = strPosition;
    NSArray *prefix_titles = [NSArray arrayWithArray:POSITIONS];
    NSArray *titles = [NSArray arrayWithArray:DETAILPOSITIONS];
    
    for (NSInteger i = 0; i < 11; i++)
    {
        NSString *formattedString = [NSString stringWithFormat:@"%@", titles[i]];
        resultString = [resultString stringByReplacingOccurrencesOfString:formattedString withString:titles[i]];
    }
    
    resultString = [resultString stringByReplacingOccurrencesOfString:@"\r\n" withString:@","];
    
    return resultString;
}


@end
