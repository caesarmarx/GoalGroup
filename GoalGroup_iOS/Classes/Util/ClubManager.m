//
//  ClubManager.m
//  GoalGroup
//
//  Created by MacMini on 4/19/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubManager.h"
#import "Common.h"

@implementation ClubManager

+ (ClubManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gClubManager == nil)
            gClubManager = [[ClubManager alloc] init];
    }
    return gClubManager;
}

- (id)init
{
    adminClub = [[NSMutableArray alloc] init];
    clubs = [[NSMutableArray alloc] init];
    return self;
}

- (void)clearClubs
{
    adminClub = [[NSMutableArray alloc] init];
    clubs = [[NSMutableArray alloc] init];
}

- (void)setAdminClub:(NSArray *)array
{
    adminClub = [NSMutableArray arrayWithArray:array];
}

- (void)setClubs:(NSArray *)array
{
    clubs = [NSMutableArray arrayWithArray:array];
    
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    for (NSDictionary *item in clubs) {
        if (([[item valueForKey:@"post"] intValue] & CLUB_USER_POST_CAPTAIN) == CLUB_USER_POST_CAPTAIN) {
            [tmp addObject:item];
        }
    }
    
    adminClub = [NSMutableArray arrayWithArray:tmp];
}

- (BOOL)checkAdminClub:(int)clubID
{
    int r = -1;
    
#ifdef DEMO_MODE
    [FileManager WriteErrorData:[NSString stringWithFormat:@"%@, ClubManager클래스에 등록된 adminClub의 개수는 %lu 개입니다\r\n", LOGTAG, (unsigned long)adminClub.count]];
    NSLog(@"%@, ClubManager클래스에 등록된 adminClub의 개수는 %lu 개입니다", LOGTAG, (unsigned long)adminClub.count);
#endif

    for (NSDictionary *item in adminClub) {
        if ([[item objectForKey:@"club_id"] intValue] == clubID )
        {
#ifdef DEMO_MODE
            [FileManager WriteErrorData:[NSString stringWithFormat:@"%@, 일치되는 구락부는 %d입니다\r\n", LOGTAG, [[item objectForKey:@"club_id"] intValue]]];
            NSLog(@"%@, 일치되는 구락부는 %d입니다", LOGTAG, [[item objectForKey:@"club_id"] intValue]);
#endif

            r = 0;
            break;
        }
    }
    
#ifdef DEMO_MODE
    if (r == -1)
    {
        [FileManager WriteErrorData:[NSString stringWithFormat:@"%@, 일치되는 구락부를 찾지 못하였습니다.\r\n", LOGTAG]];
        NSLog(@"%@, 일치되는 구락부를 찾지 못하였습니다.", LOGTAG);
    }
#endif

    return r == 0? YES: NO;
}

- (BOOL)checkMyClub:(int)clubID
{
    int r = -1;
    for (NSDictionary *item in clubs) {
        if ([[item objectForKey:@"club_id"] intValue] == clubID)
        {
            r = 0;
            break;
        }
    }
    return r == 0? YES: NO;
}

- (BOOL)checkCorchClub:(int)clubID
{
    int r = -1;
    for (NSDictionary *item in clubs) {
        if ([[item objectForKey:@"club_id"] intValue] == clubID &&
            ([[item objectForKey:@"post"] intValue] & CLUB_USER_POST_CORCH) == CLUB_USER_POST_CORCH)
            r = 0;
    }
    return r == 0? YES: NO;
}

- (int)countsAdminClub
{
    return (int)adminClub.count;
}

- (int)countsClubs
{
    return (int)clubs.count;
}

- (void)addAdminClub:(NSDictionary *)item
{
    if (adminClub == nil)
        adminClub = [[NSMutableArray alloc] init];
    
    if ([self checkAdminClub:[[item valueForKey:@"club_id"] intValue]])
        return;
    
    [adminClub addObject:item];
}

- (void)addClubs:(NSDictionary *)item
{
    if (clubs == nil)
        clubs = [[NSMutableArray alloc] init];
    
    [clubs addObject:item];
}

- (void)removeAdminClub:(int)clubID
{
    for (NSDictionary *item in adminClub) {
        if ([[item valueForKey:@"club_id"] intValue] == clubID)
        {
            [adminClub removeObject:item];
            break;
        }
    }
}

- (void)removeClub:(int)clubID
{
    for (NSDictionary *item in clubs) {
        if ([[item valueForKey:@"club_id"] intValue] == clubID)
        {
            [clubs removeObject:item];
            break;
        }
    }
}

- (NSArray *)adminClub
{
    return adminClub;
}

- (NSArray *)clubs
{
    return clubs;
}

- (NSString *)stringClubNameWithID:(int)clubID
{
    for (NSDictionary *item in clubs) {
        if ([[item objectForKey:@"club_id"] intValue] == clubID)
            return [item objectForKey:@"club_name"];
    }
    return @"";
}

- (int)intClubIDWithName:(NSString *)name
{
    for (NSDictionary *item in clubs) {
        if ([[item objectForKey:@"club_name"] isEqualToString:name] )
            return [[item objectForKey:@"club_id"] intValue];
    }
    return 0;
}
- (int)intRoomIDWithClubID:(int)club
{
    for (NSDictionary *item in clubs) {
        if ([[item valueForKey:@"club_id"] intValue] == club)
            return [[item valueForKey:@"room_id"] intValue];
    }
    return -1;
}

- (int)intClubIDWithRoomID:(int)room
{
    for (NSDictionary *item in clubs) {
        if ([[item valueForKey:@"room_id"] intValue] == room)
            return [[item valueForKey:@"club_id"] intValue];
    }
    return -1;
}
@end
