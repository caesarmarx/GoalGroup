//
//  Language.h
//
//  Created by JinYongHao on 9/25/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Language;
Language *gLanguage;

@interface Language : NSObject

+ (Language *)sharedInstance;
+ (NSString *)GetStringByKey:(NSString *)key;
+ (NSString *)stringWithInteger:(int)key;

@end