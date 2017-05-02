//
//  DistrictManager.m
//  GoalGroup
//
//  Created by MacMini on 3/10/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DistrictManager.h"
#import "Common.h"

@implementation DistrictManager

+ (DistrictManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gDistrictManager == nil)
            gDistrictManager = [[DistrictManager alloc] init];
    }
    return gDistrictManager;
}

- (void)setDistrictRecord:(NSArray *)data
{
    record = [data mutableCopy];
}

- (NSArray *)districtsWithCityIndex:(int)index
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *item in record) {
        if ([[item valueForKey:@"city"] intValue] == index)
            [array addObject:item];
    }
    return array;
}

- (NSArray *)districtsWithAllIndex
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *item in record) {
            [array addObject:item];
    }
    return array;
}

- (int)districtIntWithString:(NSString *)string
{
    for (NSDictionary *item in record) {
        if ([[item valueForKey:@"district"] isEqualToString:string])
            return [[item valueForKey:@"id"] intValue];
    }
    return 0;
}
- (NSString *)stringAreaIDsArrayOfAreas:(NSString *)areas InCity:(int)city
{
    NSArray *cityAreas;
    if (city == -1)
        cityAreas = [self districtsWithAllIndex];
    else
        cityAreas = [self districtsWithCityIndex:city];
    
    NSString *areaIDStr = @"";
    
    for (NSDictionary *item in cityAreas) {
        if ([areas rangeOfString: [item objectForKey:@"district"]].location != NSNotFound)
        {
            if ([areaIDStr isEqualToString:@""])
                areaIDStr = [NSString stringWithFormat:@"%@", [item objectForKey:@"id"]];
            else
                areaIDStr = [NSString stringWithFormat:@"%@,%@", areaIDStr, [item objectForKey:@"id"]];
        }
    }
    return areaIDStr;
}

- (NSString *)stringAreaNamesArrayOfAreaIDs:(NSString *)areas
{
    NSArray *allAreas = [self districtsWithAllIndex];
    areas = [areas stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *arrayArea = [areas componentsSeparatedByString:@","];
    NSString *areaNames = @"";
    
    for (NSDictionary *item in allAreas) {
        for (int i = 0; i < arrayArea.count ; i ++)
        {
            if ([[item objectForKey:@"id"] isEqualToString:[arrayArea objectAtIndex:i]])
            {
                if ([areaNames isEqualToString:@""])
                    areaNames = [NSString stringWithFormat:@"%@", [item objectForKey:@"district"]];
                else
                    areaNames = [NSString stringWithFormat:@"%@,%@", areaNames, [item objectForKey:@"district"]];
            }
        }
    }
    return areaNames;
}

/*
 기능: 도시안의 지역정보로부터 지역이름렬을 얻는 함수
 |*/
- (NSString *)stringAreaNamesArrayOfAreaIDs:(NSString *)areas InCity:(NSString *)cityName
{
    NSString *areaNames = @"";
    
    int nCity = -1;
    for (NSDictionary *item in CITYS) {
        if ([[item valueForKey:@"city"] isEqualToString:cityName])
            nCity = [[item valueForKey:@"id"] intValue];
    }
    
    if (nCity == -1)
        return areaNames;
    
    NSArray *allAreas = [self districtsWithCityIndex:nCity];
    areas = [areas stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *arrayArea = [areas componentsSeparatedByString:@","];
    
    for (NSDictionary *item in allAreas) {
        for (int i = 0; i < arrayArea.count ; i ++)
        {
            if ([[item objectForKey:@"id"] isEqualToString:[arrayArea objectAtIndex:i]])
            {
                if ([areaNames isEqualToString:@""])
                    areaNames = [NSString stringWithFormat:@"%@", [item objectForKey:@"district"]];
                else
                    areaNames = [NSString stringWithFormat:@"%@,%@", areaNames, [item objectForKey:@"district"]];
            }
        }
    }
    return areaNames;
}
@end
