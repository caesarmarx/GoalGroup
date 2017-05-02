//
//  ClubManager.h
//  GoalGroup
//
//  Created by MacMini on 4/19/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ClubManager;
ClubManager *gClubManager;

@interface ClubManager : NSObject
{
    NSMutableArray *adminClub;
    NSMutableArray *clubs;
}

+ (ClubManager *)sharedInstance;
- (id)init;
- (void)clearClubs;
- (void)setAdminClub:(NSArray *)array;
- (void)setClubs:(NSArray *)array;
- (BOOL)checkAdminClub:(int)clubID;
- (BOOL)checkMyClub:(int)clubID;
- (BOOL)checkCorchClub:(int)clubID;
- (int)countsAdminClub;
- (int)countsClubs;
- (void)addAdminClub:(NSDictionary *)item;
- (void)addClubs:(NSDictionary *)item;
- (void)removeAdminClub:(int)clubID;
- (void)removeClub:(int)clubID;
- (NSArray *)adminClub;
- (NSArray *)clubs;
- (NSString *)stringClubNameWithID:(int)clubID;
- (int)intClubIDWithName:(NSString *)name;
- (int)intRoomIDWithClubID:(int)club;
- (int)intClubIDWithRoomID:(int)room;

@end
