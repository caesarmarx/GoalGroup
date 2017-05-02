//
//  PersonalGameResultRecord.h
//  GoalGroup
//
//  Created by MacMini on 4/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonalGameResultRecord : NSObject
{
    int nPlayerID;
    NSString *playerName;
    NSString *playerImageUrl;
    int goals;
    int assists;
    int overallPoints;
}

- (id)initWithPlayerId:(int)playerID
            playerName:(NSString *)name
        playerImageUrl:(NSString *)imageUrl
                  goal:(int)goal
                assist:(int)assist
                 point:(int)point;

- (void)setGoal:(int)goal assist:(int)assist point:(int)point;
- (int)intWithPlayerID;
- (int)intWithPlayerGoals;
- (int)intWithPlayerAssists;
- (int)intWithOverallPoints;
- (NSString *)stringWithPlayerName;
- (NSString *)stringWithPlayerImageUrl;

@end
