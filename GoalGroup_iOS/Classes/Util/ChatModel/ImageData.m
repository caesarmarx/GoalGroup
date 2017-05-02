//
//  ImageData.m
//  PicturePoster
//
//  Created by System Administrator on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageData.h"
//#import "CustomImageView.h"
#import "Constants.h"
#import <ImageIO/ImageIO.h>
#import "MessageDrawView.h"

@implementation ImageData

@synthesize customImageView, imagePath, imageLocation, imageView;

- (void)getMessageRange:(NSString*)message :(NSMutableArray*)array {
    
	NSRange range = [message rangeOfString:FACE_NAME_HEAD];
    
    if ( range.length > 0 ) {
        
        if ( range.location > 0 ) {
            
            [array addObject:[message substringToIndex:range.location]];
            
            message = [message substringFromIndex:range.location];
            
            if ( message.length > FACE_NAME_LEN ) {
                
                [array addObject:[message substringToIndex:FACE_NAME_LEN]];
                
                message = [message substringFromIndex:FACE_NAME_LEN];
                [self getMessageRange:message :array];
            }
            else
                
                if ( message.length > 0 ) {
                    
                    [array addObject:message];
                }
        }
        else {
            
            if ( message.length > FACE_NAME_LEN ) {
                
                [array addObject:[message substringToIndex:FACE_NAME_LEN]];
                
                message = [message substringFromIndex:FACE_NAME_LEN];
                [self getMessageRange:message :array];
            }
            else
                
                if ( message.length > 0 ) {
                    
                    [array addObject:message];
                }
        }
    }
    else {
        
        [array addObject:message];
    }
}



@end

