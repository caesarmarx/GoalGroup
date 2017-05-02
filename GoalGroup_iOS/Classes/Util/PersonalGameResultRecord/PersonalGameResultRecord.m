//
//  PersonalGameResultRecord.m
//  GoalGroup
//
//  Created by MacMini on 4/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "PersonalGameResultRecord.h"

@implementation PersonalGameResultRecord

- (id)initWithPlayerId:(int)playerID playerName:(NSString *)name playerImageUrl:(NSString *)imageUrl goal:(int)goal assist:(int)assist point:(int)point
{
    nPlayerID = playerID;
    playerName = name? name: @"";
    playerImageUrl = imageUrl? imageUrl:@"";
    goals = goal? goal : 0;
    assists = assist? assist: 0;
    overallPoints = point ? point : 0.f;
    return self;
}

- (int)intWithPlayerAssists
{
    return assists;
}

- (int)intWithPlayerGoals
{
    return goals;
}

- (int)intWithPlayerID
{
    return nPlayerID;
}

- (int)intWithOverallPoints
{
    return overallPoints;
}

- (NSString *)stringWithPlayerImageUrl
{
    return playerImageUrl;
}

- (NSString *)stringWithPlayerName
{
    return playerName;
}

- (void)setGoal:(int)goal assist:(int)assist point:(int)point
{
    goals = goal;
    assists = assist;
    overallPoints = point;
}
@end

