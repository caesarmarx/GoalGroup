//
//  PlayerListRecord.m
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "PlayerListRecord.h"
#import "Common.h"

@implementation PlayerListRecord

- (id)init
{
    self = [super init];
    nPlayerID = 0;
    return self;
}

- (id) initWithPlayerID:(int)p_id playerImageUrl:(NSString *)imageUrl playerName:(NSString *)name age:(int)age footballage:(int)footballage height:(int)h weight:(int)w position:(int)pos week:(int)week area:(NSString *)area health:(BOOL)health
{
    nPlayerID = p_id;
    playerImageUrl = imageUrl;
    playerName = name;
    playerAge = age;
    footballAge = footballage;
    playerArea = area;
    playerPosition = pos;
    playerWeek = week;
    playerHeight = h;
    playerWeight = w;
    healthState = health;
    tempState = 0;
    return self;
}

- (id)initWithPlayerID:(int)p_id PlayerImageUrl:(NSString *)imageUrl playerName:(NSString *)name position:(int)pos date:(NSString *)date
{
    playerImageUrl = imageUrl;
    playerName = name;
    playerPosition = pos;
    bookingDate = date;
    nPlayerID = p_id;
    tempState = 0;
    return self;
}

- (id)initWithPlayerID:(int)p_id PlayerImageUrl:(NSString *)imageUrl playerName:(NSString *)name position:(int)pos goals:(int)goal assists:(int)assist points:(int)pint
{
    playerImageUrl = imageUrl;
    playerName = name;
    playerPosition = pos;
    nPlayerID = p_id;
    goals = goal;
    assists = assist;
    overalls = pint;
    tempState = 0;
    return self;
}

- (id)initWithPlayerID:(int)p_id userType:(int)u_type playerImageUrl:(NSString *)imageUrl playerName:(NSString *)name positionInGame:(int)position health:(BOOL)health tempState:(int)temp
{
    nPlayerID = p_id;
    nUserType = u_type;
    playerImageUrl = imageUrl;
    playerName = name;
    positionInGame = position;
    healthState = health;
    tempState = temp;
    return self;
}

- (id)initWithPlayerID:(int)p_id
            playerName:(NSString *)name
              imageUrl:(NSString *)imageUrl
             playerSex:(int)sex
         playerBithday:(NSString *)birthday
          playerHeight:(int)height
          playerWeight:(int)weight
           footballAge:(int)age
        playerPosition:(int)position
            playerCity:(NSString *)city
            playerWeek:(int)time
            activeArea:(NSString *)area
                 phone:(NSString *)phone
{
    nPlayerID = p_id;
    playerName = name;
    playerImageUrl = imageUrl;
    playerSex = sex;
    playerBirthday = birthday;
    playerHeight = height;
    playerWeight = weight;
    footballAge = age;
    playerPosition= position;
    playerCity = city;
    playerWeek = time;
    phoneNumber = phone;
    playerArea = area;
    tempState = 0;

//    for (NSDictionary *item in DISTRICTS) {
//        if (area == [[item valueForKey:@"id"] intValue])
//            playerArea = [item valueForKey:@"district"];
//    }
    return self;
}

- (int)intWithPlayerID
{
    return nPlayerID;
}

- (NSString *)stringWithPlayerName
{
    return playerName;
}

- (NSString *)imageUrlWithPlayerImage
{
    return playerImageUrl;
}

- (int) valueWithAge
{
    return playerAge;
}

- (int) valueWithFootballAge
{
    return footballAge;
}

- (int) valueWithHeight
{
    return playerHeight;
}

- (int) valueWithWeight
{
    return playerWeight;
}

- (int) intWithPosition
{
    return playerPosition;
}

- (int) intWithWeek
{
    return playerWeek;
}

- (NSString *) stringWithArea
{
    return playerArea;
}

- (BOOL) valueWithHealth
{
    return healthState;
}

- (NSString *)stringWithBookingDate
{
    return bookingDate;
}

- (int)valueWithPositionInGame
{
    return positionInGame;
}

- (int)intWithUserType
{
    return nUserType;
}

- (int)intWithSex
{
    return playerSex;
}

- (NSString *)stringWithBirthday
{
    return playerBirthday;
}

- (NSString *)stringWithCity
{
    return playerCity;
}

- (NSString *)stringWithPhone
{
    return phoneNumber;
}

- (int)intWithGoals
{
    return goals;
}

- (int)intWithAssists
{
    return assists;
}

- (int)intwithPoints
{
    return overalls;
}

- (int)intWithTempState
{
    return tempState;
}

- (void) setPositionInGameWithInt:(int)position
{
    positionInGame = position;
}

- (void) setUserTypeWithInt:(int)userType
{
    nUserType = userType;
}

@end

@implementation PlayerListManager

+ (PlayerListManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gPlayerListManager == nil)
            gPlayerListManager = [[PlayerListManager alloc] init];
    }
    return gPlayerListManager;
}

@end
