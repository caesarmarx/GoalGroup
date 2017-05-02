//
//  MessageView.m
//  FaceBoardDome
//
//  Created by kangle1208 on 13-12-12.
//  Copyright (c) 2013年 Blue. All rights reserved.
//

#import "MessageDrawView.h"
#import "ClubRoomViewController.h"

#define FACE_ICON_NAME      @"^[0][0-8][0-5]$"


@implementation MessageDrawView

@synthesize data;

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)showMessage:(NSArray *)message
{
    data = (NSMutableArray *)message;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	if ( data )
    {
        NSLog(@"emoticon repair !!!!!!!!!!");
        NSDictionary *faceMap = [[NSDictionary alloc] init];
        UIFont *font = [UIFont systemFontOfSize:14.0f];
        isLineReturn = NO;
        upX = VIEW_LEFT;
        upY = VIEW_TOP;
        int dataCount= [data count];
		for (int index = 0; index < dataCount; index++) {
            
			NSString *str = [data objectAtIndex:index];
			if ( [str hasPrefix:FACE_NAME_HEAD] ) {
                
                NSArray *imageNames = [faceMap allKeysForObject:str];
                NSString *imageName = nil;
                
                if ( imageNames.count > 0 ) {
                    
                    imageName = [imageNames objectAtIndex:0];
                }
                
                UIImage *image = [UIImage imageNamed:imageName];
                
                if ( image ) {
                    
                    if ( upX > ( VIEW_WIDTH_MAX ) ) {
                        
                        isLineReturn = YES;
                        
                        upX = VIEW_LEFT;
                        upY += VIEW_LINE_HEIGHT;
                    }
                    
                    [image drawInRect:CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight)];
                    
                    upX += KFacialSizeWidth;
                    
                    lastPlusSize = KFacialSizeWidth;
                }
                else {
                    
                    [self drawText:str withFont:font];
                }
			}
            else {
                
                [self drawText:str withFont:font];
			}
        }
	}
}

- (void)drawText:(NSString *)string withFont:(UIFont *)font{

    for ( int index = 0; index < string.length; index++) {

        NSString *character = [string substringWithRange:NSMakeRange( index, 1 )];
        CGSize size = [character sizeWithFont:font
                            constrainedToSize:CGSizeMake(VIEW_WIDTH_MAX, VIEW_LINE_HEIGHT * 1.5)];

        if ( upX > ( VIEW_WIDTH_MAX - KCharacterWidth ) ) {

            isLineReturn = YES;

            upX = VIEW_LEFT;
            upY += VIEW_LINE_HEIGHT;
        }

        [character drawInRect:CGRectMake(upX, upY, size.width, self.bounds.size.height) withFont:font];
        upX += size.width;

        lastPlusSize = size.width;
    }
}


- (BOOL)isStrValid:(NSString *)srcStr forRule:(NSString *)ruleStr {
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:ruleStr
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:nil];
    
    NSUInteger numberOfMatch = [regularExpression numberOfMatchesInString:srcStr
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, srcStr.length)];

    
    return ( numberOfMatch > 0 );
}

- (void)dealloc {

    
}

+ (CGSize)sizeOfMessageView:(NSArray *)message
{
    CGSize size;
    if ( message )
    {
        NSLog(@"emoticon repair !!!!!!!!!!");
        NSDictionary *faceMap = [[NSDictionary alloc] init];
        UIFont *font = [UIFont systemFontOfSize:14.0f];
        
        int isLineReturn = NO;
        
        int upX = VIEW_LEFT;
        int upY = VIEW_TOP;
        int dataCount= [message count];
		for (int index = 0; index < dataCount; index++)
        {
			NSString *str = [message objectAtIndex:index];
			if ([str hasPrefix:FACE_NAME_HEAD])
            {
                NSArray *imageNames = [faceMap allKeysForObject:str];
                NSString *imageName = nil;
                
                if ( imageNames.count > 0 ) {
                    
                    imageName = [imageNames objectAtIndex:0];
                }
                
                UIImage *image = [UIImage imageNamed:imageName];
                
                if ( image ) {
                    
                    if ( upX > ( VIEW_WIDTH_MAX ) ) {
                        
                        isLineReturn = YES;
                        
                        upX = VIEW_LEFT;
                        upY += VIEW_LINE_HEIGHT;
                    }
                    
//                    [image drawInRect:CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight)];
                    
                    upX += KFacialSizeWidth;
                    
//                    lastPlusSize = KFacialSizeWidth;
                }
                else {
                    for ( int index = 0; index < str.length; index++) {
                        
                        NSString *character = [str substringWithRange:NSMakeRange( index, 1 )];
                        CGSize size = [character sizeWithFont:font
                                            constrainedToSize:CGSizeMake(VIEW_WIDTH_MAX, VIEW_LINE_HEIGHT * 1.5)];
                        
                        if ( upX > ( VIEW_WIDTH_MAX - KCharacterWidth ) ) {
                            
                            isLineReturn = YES;
                            
                            upX = VIEW_LEFT;
                            upY += VIEW_LINE_HEIGHT;
                        }
                        
//                        [character drawInRect:CGRectMake(upX, upY, size.width, self.bounds.size.height) withFont:font];
                        upX += size.width;
                        
//                        lastPlusSize = size.width;
                    }
//                    [self drawText:str withFont:font];
                }
			}
            else {
                for ( int index = 0; index < str.length; index++) {
                    
                    NSString *character = [str substringWithRange:NSMakeRange( index, 1 )];
                    CGSize size = [character sizeWithFont:font
                                        constrainedToSize:CGSizeMake(VIEW_WIDTH_MAX, VIEW_LINE_HEIGHT * 1.5)];
                    
                    if ( upX > ( VIEW_WIDTH_MAX - KCharacterWidth ) ) {
                        
                        isLineReturn = YES;
                        
                        upX = VIEW_LEFT;
                        upY += VIEW_LINE_HEIGHT;
                    }
                    
//                    [character drawInRect:CGRectMake(upX, upY, size.width, self.bounds.size.height) withFont:font];
                    upX += size.width;
                    
//                    lastPlusSize = size.width;
                }
//                [self drawText:str withFont:font];
			}
        }
        if (isLineReturn == YES)
        {
            int x = VIEW_WIDTH_MAX;
            int y = upX == 0?upY: upY + VIEW_LINE_HEIGHT;
            size = CGSizeMake(x, y);
        }else
        {
            int x = upX + 10;
            int y = upY + VIEW_LINE_HEIGHT;
            size = CGSizeMake(x, y);
        }
	}
    return size;
}
@end
