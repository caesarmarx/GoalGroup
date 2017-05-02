//
//  ClubListRecord.h
//  GoalGroup
//
//  Created by KCHN on 2/1/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClubListRecord : NSObject
{
    int nClubID;
    int nUserType;//1:Admin, 2:Corch, 3:TeamLeader, 4:Normal
    NSString *clubImageUrl;
    NSString *clubName;
    NSInteger membersCount;
    NSInteger activeRate;
    NSInteger averageAge;
    NSString *activeArea;
    int nActiveArea;
    int activeWeek;
    NSString *foundDate;
    int nCity;
    NSString *sponsor;
    NSString *homeStadiumAddr;
    NSString *homeStadiumArea;
    NSString *introduction;
    int yearAllGames;
    int yearVictorGames;
    int yearlossGames;
    int yearDrawGames;

}

//Used in ClubList
- (id) initWithClubID:(int)clubid
            clubImageUrl:(NSString *)imageUrl
            clubname:(NSString *)name;

//Used in ClubMarket
- (id) initWithClubId:(int)c_id
         ClubImageUrl:(NSString *)imageUrl
             clubname:(NSString *)name
              members:(NSInteger)peoles
           activeRate:(NSInteger)rate
           averageAge:(NSInteger)age
           activeArea:(NSString *)area
          activeWeeks:(int)weeks;


//Used in ClubDetail
- (id) initWithClubID:(int)c_id
             userType:(int)u_type
         ClubImageUrl:(NSString *)imageUrl
             clubname:(NSString *)name
              members:(NSInteger)peoles
           activeRate:(NSInteger)rate
           averageAge:(NSInteger)age
           activeArea:(NSString *)area
          activeWeeks:(int)weeks
            foundDate:(NSString *)date
                 city:(NSString *)c
              sponsor:(NSString *)spsr
          homeStadiumArea:(NSString *)stadiumArea
      homeStadiumAddr:(NSString *)stadiumAddr
         introduction:(NSString *)intro
             allGames:(int)all
             vicGames:(int)vic
            lossGames:(int)loss
            drawGames:(int)draw;

- (int)intWithClubID;
- (int)intWithUserType;
- (NSString *)stringWithClubName;
- (NSString *)stringWithClubImageUrl;
- (NSInteger)valueWithMembers;
- (NSInteger)valueWithActiveRate;
- (NSString *)stringWithActiveArea;
- (int)intWithActiveArea;
- (NSInteger)valueWithAverageAge;
- (int)intWithActiveWeeks;
- (NSString *)stringWithFoundDate;
- (NSString *)stringWithCity;
- (int)intWithCity;
- (NSString *)stringWithSponsor;
- (NSString *)stringWithStadiumArea;
- (NSString *)stringWithStadiumAddr;
- (NSString *)stringWithIntroduction;
- (int)intWithAllGames;
- (int)intWithVictoies;
- (int)intWithLoss;
- (int)intWithDraw;


@end
