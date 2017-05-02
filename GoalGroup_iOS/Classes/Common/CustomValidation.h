//
//  Validation.h
//  GoalGroup
//
//  Created by JinYongHao on 2015. 5. 15..
//  Copyright (c) 2015년 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomValidation : NSObject

typedef enum
{
    LENGTH_EQUAL = 1,
    LENGTH_GREAT = 2,
    LENGTH_LESS = 3,
}CUSTOM_VALIDATION;

+(BOOL) isEmpty:(NSString*)value;
+(BOOL) ValidationLength:(NSString*)value length:(NSUInteger)length symbol:(CUSTOM_VALIDATION)symbol;
+(BOOL) ValidationEscape:(NSString*)value bEscape:(BOOL)bInclue;
+(BOOL) ValidateMobile:(NSString *)mobileNum;

@end
