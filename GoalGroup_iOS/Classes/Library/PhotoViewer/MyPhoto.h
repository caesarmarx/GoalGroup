//
//  PhotoViewer.h
//  OMTelephone
//
//  Created by JinYongHao on 8/25/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "EGOPhotoGlobal.h"


@interface MyPhoto : NSObject<EGOPhoto>{
    
    NSURL *_URL;
	NSString *_caption;
	CGSize _size;
	UIImage *_image;
	
	BOOL _failed;
}

- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName image:(UIImage*)aImage;
- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName;
- (id)initWithImageURL:(NSURL*)aURL;
- (id)initWithImage:(UIImage*)aImage;

@end
