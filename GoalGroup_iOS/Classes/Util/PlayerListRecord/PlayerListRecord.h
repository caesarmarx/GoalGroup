//
//  PlayerListRecord.h
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerListRecord : NSObject
{
    int nPlayerID;
    int nUserType;
    int playerHeight;
    int playerWeight;
    int playerAge;
    int footballAge;
    int playerPosition;
    int playerWeek;
    int positionInGame;
    int playerSex;
    int goals;
    int assists;
    int overalls;
    NSString *playerCity;
    BOOL healthState;
    NSString *playerImageUrl;
    NSString *playerName;
    NSString *playerArea;
    NSString *playerBirthday;
    NSString *bookingDate;
    NSString *phoneNumber;
    int tempState;
}

//Used in PlayerMarket
- (id) initWithPlayerID:(int)p_id
            playerImageUrl:(NSString *)imageUrl
             playerName:(NSString *)name
                    age:(int)age
            footballage:(int)footballage
                 height:(int)h
                 weight:(int)w
               position:(int)pos
                   week:(int)week
                   area:(NSString *)area
                 health:(BOOL)health;

//Used in JoiningBook
- (id)initWithPlayerID:(int)p_id
        PlayerImageUrl:(NSString *)imageUrl
            playerName:(NSString *)name
              position:(int)pos
                  date:(NSString *)date;

//Used in ApplyGamePlayers
- (id)initWithPlayerID:(int)p_id
        PlayerImageUrl:(NSString *)imageUrl
            playerName:(NSString *)name
              position:(int)pos
                 goals:(int)goal
               assists:(int)assist
                points:(int)pint;

//Used in Club -> ClubMember
- (id)initWithPlayerID:(int)p_id
              userType:(int)u_type
        playerImageUrl:(NSString *)imageUrl
            playerName:(NSString *)name
        positionInGame:(int)position
                health:(BOOL)health
             tempState:(int)temp;

//Used in PlayerDetail
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
                 phone:(NSString *)phone;

- (NSString *) stringWithPlayerName;
- (NSString *) imageUrlWithPlayerImage;
- (NSString *) stringWithArea;
- (NSString *) stringWithBookingDate;
- (NSString *) stringWithCity;
- (NSString *) stringWithBirthday;
- (NSString *) stringWithPhone;
- (int) valueWithAge;
- (int) valueWithFootballAge;
- (int) valueWithHeight;
- (int) valueWithWeight;
- (int) intWithPosition;
- (int) intWithWeek;
- (BOOL) valueWithHealth;
- (int)valueWithPositionInGame;
- (int)intWithPlayerID;
- (int)intWithUserType;
- (int) intWithSex;
- (int) intWithGoals;
- (int) intWithAssists;
- (int) intwithPoints;
- (int) intWithTempState;
//- (int) intWithCity;

- (void) setPositionInGameWithInt:(int)position;
- (void) setUserTypeWithInt:(int)userType;

@end

@class PlayerListManager;
PlayerListManager *gPlayerListManager;

@interface PlayerListManager : NSObject

+ (PlayerListManager *)sharedInstance;

@end
