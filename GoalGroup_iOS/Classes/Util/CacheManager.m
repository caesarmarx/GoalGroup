//
//  CacheManager.m
//
//  Created by JinYongHao on 9/30/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import "CacheManager.h"
#import "Common.h"

@implementation CacheManager

+ (CacheManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gCacheManager == nil)
            gCacheManager = [[CacheManager alloc] init];
    }
    return gCacheManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        caches = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (UIImage *)GetCacheImageWithURL:(NSString *)url
{
    NSString *cacheFileName = [url MD5];
    UIImage *cacheInMemory = [[CacheManager sharedInstance] imageWithKey:cacheFileName];
    if (cacheInMemory)
        return cacheInMemory;
    NSData *cacheData = [FileManager GetDataFromFilePath:[FileManager GetCacheFilePathWithFileName:cacheFileName]];
    if (cacheData)
    {
        UIImage *image = [UIImage imageWithData:cacheData];
        [[CacheManager sharedInstance] cacheWithImage:image key:cacheFileName];
        return image;
    }
    return nil;
}

+ (NSFileHandle *)CacheWithData:(NSData *)data filename:(NSString *)filename
{
    return [FileManager WriteDataToFilePath:[FileManager GetCacheFilePathWithFileName:filename] fileData:data];
}

+ (NSFileHandle *)CacheWithImage:(UIImage *)image filename:(NSString *)filename
{
    NSString *cacheFileName = [filename MD5];
    [[CacheManager sharedInstance] cacheWithImage:image key:cacheFileName];
    return [CacheManager CacheWithData:UIImagePNGRepresentation(image) filename:cacheFileName];
}

- (void)cacheWithImage:(UIImage *)image key:(NSString *)key
{
    id cache = [caches objectForKey:key];
    if (cache || image == nil) //Modified By Boss.2015/05/13
        return;
    [caches setObject:image forKey:key];
}

- (UIImage *)imageWithKey:(NSString *)key
{
    return [caches objectForKey:key];
}

- (void)removeAllProgramCache
{
    [caches removeAllObjects];
}
@end

