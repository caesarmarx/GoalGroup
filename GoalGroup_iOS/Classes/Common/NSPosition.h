//
//  NSPosition.h
//  GoalGroup
//
//  Created by KCHN on 3/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPosition : NSObject

+ (NSString *)stringDetailWithIntegerPosition:(int)intPosition;
+ (NSString *)stringFirstWithIntegerPosition:(int)intPosition;
+ (NSInteger) intDetailWithStringPosition:(NSString *)strPosition;
//+ (NSString *)stringWithLinearIntegerPositon:(int)intPosition;
+ (NSInteger) intWithStringPosition:(NSString *)strPosition;
+ (NSString *)stringPositionWithIntegerPosition:(int)intPosition;
+ (NSString *)stringPrefixDetailWithIntegerPosition:(int)intPosition;
+ (NSString *)formattedStringFromPLAYERDETAIL_POSITION:(NSString *)strPosition;
+ (NSString *)formattedStringFromPLAYERDETAIL_POSITIONInARow:(NSString *)strPosition;
+ (NSString *)getPLAYERDETAIL_POSITIONFromFormattedString:(NSString *)strPosition;

@end
