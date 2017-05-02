//
//  StadiumListRecord.m
//  GoalGroup
//
//  Created by KCHN on 3/6/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "StadiumListRecord.h"

@implementation StadiumListRecord

- (id)initWithStadiumId:(int)s_id name:(NSString *)name area:(NSString *)area
{
    nStadiumID = s_id;
    stadiumName = name;
    stadiumArea = area;
    return self;
}

- (int)intWithID
{
    return nStadiumID;
}

- (NSString *)stringWithStadiumArea
{
    return stadiumArea;
}

- (NSString *)stringWithStadiumName
{
    return stadiumName;
}
@end
