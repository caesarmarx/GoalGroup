//
//  SystemConferenceListRecord.h
//  GoalGroup
//
//  Created by MacMini on 4/20/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemConferenceListRecord : NSObject
{
    NSString *strUser;
    NSString *strDate;
    NSString *strTime;
    NSString *strWeekDay;
    NSString *strAppeal;
    NSString *strAnswer;
}

- (id)initWithUser:(NSString *)user
              date:(NSString *)date
              time:(NSString *)time
           weekDay:(int)weekday
           appeal:(NSString *)appeal
            answer:(NSString *)answer;
- (NSString *)stringUserName;
- (NSString *)stringDate;
- (NSString *)stringTime;
- (NSString *)stringWeekDay;
- (NSString *)stringAppeal;
- (NSString *)stringAnswer;
@end
