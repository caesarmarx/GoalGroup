//
//  GameScheduleRecord.h
//  GoalGroup
//
//  Created by MacMini on 3/12/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameScheduleRecord : NSObject
{
    int nGameType;               //0:challenge, 1:notice, 2:custom
    int nGameListID;
    int nVsStatus;
    int nGameDay;
    int homeID;
    int awayID;
    int playerMode;
    int homePlayer;
    int awayPlayer;
    NSString *strGameDate;
    NSString *strGameTime;
    NSString *strGameResult;
    NSString *strHomeName;
    NSString *strAwayName;
    NSString *strHomeImageUrl;
    NSString *strAwayImageUrl;
    NSString *strStadiumArea;
    NSString *strStadiumAddress;
}

- (id)initWithGameListID:(int)gameID
                gameType:(int)gType
                vsStatus:(int)status
                gameDate:(NSString *)date
                gameTime:(NSString *)time
                 gameDay:(int)day
              gameResult:(NSString *)result
                    home:(NSString *)home
                    away:(NSString *)away
            homeImageUrl:(NSString *)homeUrl
            awayImageUrl:(NSString *)awayUrl
                  homeID:(int)homeid
                  awayID:(int)awayid
              playerMode:(int)player
              homePlayer:(int)hplayer
              awayPlayer:(int)aplayer
             stadiumArea:(NSString *)stdArea
          stadiumAddress:(NSString *)stdAddr;

- (int)intWithGameListID;
- (int)intWithGameType;
- (int)intWithVsStatus;
- (int)intWithHomeID;
- (int)intWithAwayID;
- (int)intwithPlayerMode;
- (int)intWithHomePlayer;
- (int)intWithAwayPlayer;
- (int)intWithGameDay;
- (NSString *)stringWithGameDate;
- (NSString *)stringWithGameResult;
- (NSString *)stringWithHomeName;
- (NSString *)stringWithAwayName;
- (NSString *)stringWithHomeUrl;
- (NSString *)stringWithAwayUrl;
- (NSString *)stringWithWeek;
- (NSString *)stringWithGameTime;
- (NSString *)stringWithStadiumArea;
- (NSString *)stringWithStadiumAddress;
- (NSString *)stringWithGameDay;
- (void)increaseHomePlayer:(int)plus;
- (void)increaseAwayPlayer:(int)plus;
@end
