//
//  ClubListRecord.m
//  GoalGroup
//
//  Created by KCHN on 2/1/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubListRecord.h"
#import "Common.h"

@implementation ClubListRecord

- (id)initWithClubID:(int)clubid clubImageUrl:(NSString *)imageUrl clubname:(NSString *)name
{
    clubImageUrl = imageUrl;
    clubName = name;
    nClubID = clubid;
    return self;
}

- (id) initWithClubId:(int)c_id ClubImageUrl:(NSString *)imageUrl clubname:(NSString *)name members:(NSInteger)peoles activeRate:(NSInteger)rate averageAge:(NSInteger)age activeArea:(NSString *)area activeWeeks:(int)weeks
{
    nClubID = c_id;
    clubImageUrl = imageUrl;
    clubName = name;
    membersCount = peoles;
    activeRate = rate;
    averageAge = age;
    activeArea = area;
    activeWeek = weeks;
    return self;
}

- (id)initWithClubID:(int)c_id userType:(int)u_type ClubImageUrl:(NSString *)imageUrl clubname:(NSString *)name members:(NSInteger)peoles activeRate:(NSInteger)rate averageAge:(NSInteger)age activeArea:(NSString *)area activeWeeks:(int)weeks foundDate:(NSString *)date city:(NSString *)c sponsor:(NSString *)spsr homeStadiumArea:(NSString *)stadiumArea homeStadiumAddr:(NSString *)stadiumAddr introduction:(NSString *)intro allGames:(int)all vicGames:(int)vic lossGames:(int)loss drawGames:(int)draw
{
    nClubID = c_id;
    nUserType = u_type;
    clubImageUrl = imageUrl;
    clubName = name;
    membersCount = peoles;
    activeRate = rate;
    averageAge = age;
    activeArea = area;
    activeWeek = weeks;
    foundDate = date;
//    city = c;
    
    for (NSDictionary *item in CITYS) {
        if ([[item valueForKey:@"city"] isEqualToString:c]) {
            nCity = [[item valueForKey:@"id"] intValue];
        }
    }
    sponsor = spsr;
    homeStadiumAddr = stadiumAddr;
    homeStadiumArea = stadiumArea;
    introduction = intro;
    yearAllGames = all;
    yearDrawGames = draw;
    yearlossGames = loss;
    yearVictorGames = vic;
    return self;
    
}


- (NSString *)stringWithClubName
{
    return clubName;
}

- (NSString *)stringWithClubImageUrl
{
    return clubImageUrl;
}

- (NSInteger)valueWithMembers
{
    return membersCount;
}

- (NSInteger)valueWithActiveRate
{
    return activeRate;
}

- (NSString *)stringWithActiveArea
{
    return activeArea;
}

- (NSInteger)valueWithAverageAge
{
    return averageAge;
}
- (int)intWithActiveWeeks
{
    return activeWeek;
}

- (int)intWithClubID
{
    return nClubID;
}
- (int)intWithUserType
{
    return nUserType;
}

- (NSString *)stringWithFoundDate
{
    return foundDate;
}
- (NSString *)stringWithCity
{
    NSString *city = @"";
    for (NSDictionary *item in CITYS) {
        if ([[item valueForKey:@"id"] intValue] == nCity)
            city = [item valueForKey:@"city"];
    }
    return city;
}
- (NSString *)stringWithSponsor
{
    return sponsor;
}
- (NSString *)stringWithStadiumAddr
{
    return homeStadiumAddr;
}

- (NSString *)stringWithStadiumArea
{
    return homeStadiumArea;
}
- (NSString *)stringWithIntroduction
{
    return introduction;
}
- (int)intWithAllGames
{
    return yearAllGames;
}
- (int)intWithVictoies
{
    return yearVictorGames;
}
- (int)intWithLoss
{
    return yearlossGames;
}
- (int)intWithDraw
{
    return yearDrawGames;
}

- (int)intWithCity
{
    return nCity;
}


- (int)intWithActiveArea
{
    return nActiveArea;
}
@end


