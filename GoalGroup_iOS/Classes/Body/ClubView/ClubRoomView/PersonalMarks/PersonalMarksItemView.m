//
//  PsersonalMarksItemView.m
//  GoalGroup
//
//  Created by KCHN on 2/13/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "PersonalMarksItemView.h"
#import "Common.h"

@implementation PersonalMarksItemView
{
    NSArray *titles;
    NSArray *marks;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        titles = [NSArray arrayWithObjects:LANGUAGE(@"ClubMarkItem_Title_1"),
                  LANGUAGE(@"Enter Game"),
                  LANGUAGE(@"ClubMarkItem_Title_5"),
                  LANGUAGE(@"HELP ATTACK"),
                  LANGUAGE(@"GameDetailCell Label 1"),
                  nil];

    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    tagIndex = 0;
    
    NSInteger width = rect.size.width;
    NSInteger itemStartX = 0;
    NSInteger itemStartY = 0;
    int w[5] = {0};
    
    w[0] = width / 6.f * 1.5f;
    w[1] = width / 6.f;
    w[2] = width / 6.f;
    w[3] = width / 6.f;
    w[4] = width / 6.f * 1.5f;
    
    int height = width / 8;
    
    [[UIColor ggaTextColor] setFill];
    
    UIFont *font;
    if (width <= 220)
        font = [UIFont systemFontOfSize:12.f];
    else
        font = [UIFont systemFontOfSize:16.f];
    
    UILabel *label = [[UILabel alloc] init];
    label.tag = tagIndex;
    tagIndex ++;
    
//    if ([marks count] == 0)
//    {
//        UILabel *nolabel = [[UILabel alloc] init];
//        nolabel.tag = 100;
//        nolabel.font = font;
//        nolabel.textAlignment = NSTextAlignmentCenter;
//        nolabel.lineBreakMode = NSLineBreakByCharWrapping;
//        nolabel.text = LANGUAGE(@"ClubMarkItem_Label");
//        nolabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, height);
//        nolabel.textColor = [UIColor whiteColor];
//        [self addSubview:nolabel];
//        return;
//    }
    
    // 타이틀 그리기
    for (int i = 0; i < 5; i++ )
    {
        label = [[UILabel alloc] init];
        label.text = [titles objectAtIndex:i];
        label.frame = CGRectMake(itemStartX, itemStartY, w[i], height);
        label.font = font;
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.textColor = [UIColor whiteColor];
        label.tag = tagIndex;
        tagIndex ++;
        itemStartX += w[i];
        [self addSubview:label];
    }
    
    //성적 그리기
    for (int i = 0; i < [marks count]; i++)
    {
        NSArray *m = [marks objectAtIndex:i];

        itemStartY += height;
        itemStartX = 0;
        
        if (i % 2 != 0) {
            UIView *subLayer = [[UIView alloc] initWithFrame: CGRectMake(0, itemStartY, width, height)];
            subLayer.backgroundColor = [UIColor colorWithRed:129.f/255.f green:207.f/255.f blue:164.f/255.f alpha:1.0f];
            subLayer.tag = tagIndex;
            tagIndex ++;
            [self addSubview: subLayer];
        }
        
        for (int j = 0; j < 5; j++)
        {
            if (j == 0) {
                UIView *subLayer = [[UIView alloc] initWithFrame:CGRectMake(itemStartX + 10, itemStartY + 8, w[0] - 20, height - 16)];
                subLayer.backgroundColor = [UIColor colorWithRed:52.f/255.f green:140.f/255.f blue:92.f/255.f alpha:1.0f];
                subLayer.layer.cornerRadius = (height - 16) / 2;
                subLayer.tag = tagIndex;
                tagIndex ++;
                [self addSubview:subLayer];
            }
            label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"%@", [m objectAtIndex:j]];
            label.frame = CGRectMake(itemStartX, itemStartY, w[j], height);
            label.font = font;
            label.lineBreakMode = NSLineBreakByCharWrapping;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [self selectColor:j];
            label.tag = tagIndex;
            tagIndex ++;
            itemStartX += w[j];
            [self addSubview:label];
        }
        
    }
    
}

- (void)drawPersonalMarks:(NSArray *)psMarks
{
    marks = psMarks;
    
    if (marks.count != 0)
    {
        UIView *v = [self viewWithTag:100];
        v.hidden = YES;
    }
    [self setNeedsDisplay];
}

- (UIColor *) selectColor : (int) index
{
    if (index != 2) {
        return [UIColor whiteColor];
    }
    
    return [UIColor yellowColor];
}

@end
