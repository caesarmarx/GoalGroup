//
//  UIImage+TKUtilities.h
//  App_MultipleContactPick
//
//  Created by Sheikh Mashfiqur Rahman on 7/2/13.
//  Copyright (c) 2013 SmartAppware. All rights reserved.
//

#import <ImageIO/ImageIO.h>

@interface UIImage (Mask)

- (UIImage*)thumbnailImage:(CGSize)targetSize;
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (UIImage *)circleImageWithSize:(CGFloat)size;
- (UIImage *)squareImageWithSize:(CGFloat)size;
- (UIImage *)imageAsCircle:(BOOL)clipToCircle
               withDiamter:(CGFloat)diameter
               borderColor:(UIColor *)borderColor
               borderWidth:(CGFloat)borderWidth
              shadowOffSet:(CGSize)shadowOffset;

@end