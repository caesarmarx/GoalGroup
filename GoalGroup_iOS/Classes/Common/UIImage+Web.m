//
//  UIImage+Web.m
//
//  Created by JinYongHao on 9/29/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import "UIImage+Web.h"

@implementation UIImage (Web)

+ (void)loadFromURL:(NSURL *)url callback:(void (^)(UIImage *))callback
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            callback(image);
        });
    });
}

@end
