//
//  NSWeek.h
//  GoalGroup
//
//  Created by KCHN on 3/6/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSWeek : NSObject

+ (NSString *)stringWithIntegerWeek:(int)intWeek;
+ (NSInteger) intWithStringWeek:(NSString *)strWeek;
+ (NSString *)stringWithLinearIntegerWeek:(int)intWeek;

@end
