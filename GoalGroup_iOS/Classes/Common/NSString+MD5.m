//
//  MD5.m
//  iOM
//
//  Created by JinYongHao on 7/31/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+MD5.h"

@implementation NSString(MD5)

- (NSString *)MD5
{
    const char *ptr = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++)
        [output appendFormat:@"%02x", md5Buffer[i]];
    return output;
}

@end
