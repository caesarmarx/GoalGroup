//
//  ImageData.h
//  PicturePoster
//
//  Created by System Administrator on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CustomImageView;

@interface ImageData : NSObject
{
    CustomImageView         *customImageView;    
    NSString                *imagePath;
   }

@property (nonatomic, strong) CustomImageView       *customImageView;
@property (nonatomic, strong) NSString              *imagePath;
@property (nonatomic, strong) UIImageView           *imageView;
@property (nonatomic) NSInteger                     imageLocation;

- (void)getMessageRange:(NSString*)message :(NSMutableArray*)array;



@end
