//
//  CacheManager.h
//
//  Created by JinYongHao on 9/30/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CacheManager;
CacheManager *gCacheManager;

@interface CacheManager : NSObject
{
    NSMutableDictionary *caches;
}

+ (CacheManager *)sharedInstance;
+ (UIImage *)GetCacheImageWithURL:(NSString *)url;
+ (NSFileHandle *)CacheWithData:(NSData *)data filename:(NSString *)filename;
+ (NSFileHandle *)CacheWithImage:(UIImage *)image filename:(NSString *)filename;
- (void)cacheWithImage:(UIImage *)image key:(NSString *)key;
- (UIImage *)imageWithKey:(NSString *)key;
- (void)removeAllProgramCache;
@end
