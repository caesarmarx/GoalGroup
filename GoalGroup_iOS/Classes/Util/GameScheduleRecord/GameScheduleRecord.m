//
//  GameScheduleRecord.m
//  GoalGroup
//
//  Created by MacMini on 3/12/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "GameScheduleRecord.h"
#import "NSWeek.h"

@implementation GameScheduleRecord

- (id)initWithGameListID:(int)gameID gameType:(int)gType vsStatus:(int)status gameDate:(NSString *)date gameTime:(NSString *)time gameDay:(int)day gameResult:(NSString *)result home:(NSString *)home away:(NSString *)away homeImageUrl:(NSString *)homeUrl awayImageUrl:(NSString *)awayUrl homeID:(int)homeid awayID:(int)awayid playerMode:(int)player homePlayer:(int)hplayer awayPlayer:(int)aplayer stadiumArea:(NSString *)stdArea stadiumAddress:(NSString *)stdAddr
{
    nGameListID = gameID;
    nGameType = gType;
    nVsStatus = status;
    strGameDate = date;
    strGameTime = time;
    nGameDay = day;
    strGameResult = result;
    strHomeName = home? home: @"";
    strAwayName = away? away: @"";
    strHomeImageUrl = homeUrl? homeUrl: @"";
    strAwayImageUrl = awayUrl? awayUrl: @"";
    homeID = homeid;
    awayID = awayid;
    playerMode = player;
    homePlayer = hplayer;
    awayPlayer = aplayer;
    strStadiumAddress = stdAddr? stdAddr: @"";
    strStadiumArea = stdArea? stdArea: @"";
    return self;
}

- (int)intWithGameListID
{
    return nGameListID;
}

- (int)intWithGameType
{
    return nGameType;
}

- (int)intWithVsStatus
{
    return nVsStatus;
}

- (NSString *)stringWithWeek
{
    return [NSWeek stringWithLinearIntegerWeek:nGameDay];
}

- (int)intWithHomeID
{
    return homeID;
}

- (int)intWithAwayID
{
    return awayID;
}

- (int)intwithPlayerMode
{
    return playerMode;
}

- (int)intWithHomePlayer
{
    return homePlayer;
}

- (int)intWithAwayPlayer
{
    return awayPlayer;
}

- (NSString *)stringWithGameDate
{
    return strGameDate;
}

- (NSString *)stringWithGameResult
{
    return strGameResult;
}

- (NSString *)stringWithHomeName
{
    return strHomeName;
}

- (NSString *)stringWithAwayName
{
    return strAwayName;
}

- (NSString *)stringWithHomeUrl
{
    return strHomeImageUrl;
}

- (NSString *)stringWithAwayUrl
{
    return strAwayImageUrl;
}

- (NSString *)stringWithGameTime
{
    return strGameTime;
}

- (NSString *)stringWithStadiumAddress
{
    return strStadiumAddress;
}

- (NSString *)stringWithStadiumArea
{
    return strStadiumArea;
}

- (int)intWithGameDay
{
    return nGameDay;
}

- (NSString *)stringWithGameDay
{
    return [NSWeek stringWithLinearIntegerWeek:nGameDay];
}

- (void)increaseAwayPlayer:(int)plus
{
    if (plus == 1)
        awayPlayer++;
    else
        awayPlayer --;
    
    awayPlayer = awayPlayer < 0? 0 : awayPlayer;
}

- (void)increaseHomePlayer:(int)plus
{
    if (plus == 1)
        homePlayer++;
    else
        homePlayer--;
    
    homePlayer = homePlayer < 0? 0 : homePlayer;
}

@end
