//
//  DistrictManager.h
//  GoalGroup
//
//  Created by MacMini on 3/10/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DistrictManager;
DistrictManager *gDistrictManager;

@interface DistrictManager : NSObject
{
    NSArray *record;
}

+ (DistrictManager *)sharedInstance;
- (void)setDistrictRecord:(NSArray *)data;
- (NSArray *)districtsWithCityIndex:(int)index;
- (NSArray *)districtsWithAllIndex;
- (int)districtIntWithString:(NSString *)string;
- (NSString *)stringAreaIDsArrayOfAreas:(NSString *)areas InCity:(int)city;
- (NSString *)stringAreaNamesArrayOfAreaIDs:(NSString *)areas;
- (NSString *)stringAreaNamesArrayOfAreaIDs:(NSString *)areas InCity:(NSString *)cityName;
@end
