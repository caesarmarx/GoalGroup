//
//  MessageView.h
//  FaceBoardDome
//
//  Created by kangle1208 on 13-12-12.
//  Copyright (c) 2013年 Blue. All rights reserved.
//


#import <UIKit/UIKit.h>


#define KFacialSizeWidth    14

#define KFacialSizeHeight   14

#define KCharacterWidth     0


#define VIEW_LINE_HEIGHT    18

#define VIEW_LEFT           0

#define VIEW_RIGHT          16

#define VIEW_TOP            0


#define VIEW_WIDTH_MAX      220

#define FACE_NAME_HEAD  @"/s"
#define FACE_NAME_LEN   5

@interface MessageDrawView : UILabel {

    CGFloat upX;

    CGFloat upY;

    CGFloat lastPlusSize;

    CGFloat viewWidth;

    CGFloat viewHeight;

    BOOL isLineReturn;
    
    NSMutableArray *data;
}


@property (nonatomic, strong) NSMutableArray *data;



+ (CGSize)sizeOfMessageView:(NSArray *)message;
- (void)drawText:(NSString *)string withFont:(UIFont *)font;
- (void)showMessage:(NSArray *)message;


@end
