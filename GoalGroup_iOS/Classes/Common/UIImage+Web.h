//
//  UIImage+Web.h
//
//  Created by JinYongHao on 9/29/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Helpers)

+ (void)loadFromURL:(NSURL *)url callback:(void (^)(UIImage *image))callback;

@end
