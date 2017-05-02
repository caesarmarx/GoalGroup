//
//  StadiumListRecord.h
//  GoalGroup
//
//  Created by KCHN on 3/6/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StadiumListRecord : NSObject
{
    int nStadiumID;
    NSString *stadiumName;
    NSString *stadiumArea;
}

- (id)initWithStadiumId:(int)s_id
                   name:(NSString *)name
                   area:(NSString *)area;

- (int)intWithID;
- (NSString *)stringWithStadiumName;
- (NSString *)stringWithStadiumArea;

@end
