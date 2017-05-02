//
//  PhotoViewer.m
//  OMTelephone
//
//  Created by JinYongHao on 8/25/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import "MyPhoto.h"

@implementation MyPhoto

@synthesize URL=_URL;
@synthesize caption=_caption;
@synthesize image=_image;
@synthesize size=_size;
@synthesize failed=_failed;

- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName image:(UIImage*)aImage{
	
	if (self = [super init]) {
        
		_URL=aURL;
		_caption=aName;
		_image=aImage;
		
	}
	
	return self;
}

- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName{
	return [self initWithImageURL:aURL name:aName image:nil];
}

- (id)initWithImageURL:(NSURL*)aURL{
	return [self initWithImageURL:aURL name:nil image:nil];
}

- (id)initWithImage:(UIImage*)aImage{
	return [self initWithImageURL:nil name:nil image:aImage];
}

- (void)dealloc{
	
	_URL=nil;
	_image=nil;
	_caption=nil;

}


@end
