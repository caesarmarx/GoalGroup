//
//  ClubMarksItemView.m
//  GoalGroup
//
//  Created by KCHN on 2/13/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubMarksItemView.h"
#import "Common.h"

@implementation ClubMarksItemView
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
                  LANGUAGE(@"ClubMarkItem_Title_2"),
                  LANGUAGE(@"ClubMarkItem_Title_3"),
                  LANGUAGE(@"ClubDetail_Draw"),
                  LANGUAGE(@"ClubMarkItem_Title_4"),
                  LANGUAGE(@"ClubMarkItem_Title_5"),
                  LANGUAGE(@"ClubMarkItem_Title_6"),
                  LANGUAGE(@"ClubMarkItem_Title_7"),
                  nil];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSInteger width = rect.size.width;
    NSInteger itemStartX = 5;
    NSInteger itemStartY = 0;
    int w[8] = {0};
    
    w[0] = width / 9.f * 1.5f;
    w[1] = width / 9.f * 1.f;
    w[2] = width / 9.f * 1.f;
    w[3] = width / 9.f * 1.f;
    w[4] = width / 9.f * 1.f;
    w[5] = width / 9.f * 1.f;
    w[6] = width / 9.f * 1.f;
    w[7] = width / 9.f * 1.2f;

    //int height = rect.size.height / ([marks count] + 1);
    int height = width / 8;
    //[[UIColor ggaTextColor] setFill];
    
    UIFont *font;
    if (width <= 220)
        font = [UIFont systemFontOfSize:12.f];
    else
        font = [UIFont systemFontOfSize:16.f];
        
    UILabel *label = [[UILabel alloc] init];
    
    if ([titles count] == 0)
    {
        label.font = font;
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.text = LANGUAGE(@"ClubMarkItem_Label"); 
        label.frame = CGRectMake(0, 0, 200, 10);
        [self addSubview:label];
        return;
    }
    
    //draw titles
    for (int i = 0; i < 8; i++)
    {
        label = [[UILabel alloc] init];
        label.text = [titles objectAtIndex:i];
        label.frame = CGRectMake(itemStartX, itemStartY, w[i], height);
        label.font = font;
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.textColor = [UIColor whiteColor];
       
        itemStartX += w[i];
        [self addSubview:label];
        if (i == 1) {
            UIView *subLayer = [[UIView alloc] initWithFrame:CGRectMake(itemStartX, itemStartY + 5, w[i] * 3 - 2, height - 10)];
            subLayer.backgroundColor = [UIColor ggaThemeColor];
            subLayer.layer.cornerRadius = (height - 10) / 2;
            [self addSubview:subLayer];
        }
    }
    
    //draw marks
    for (int i = 0; i < [marks count]; i++)
    {
        NSArray *m = [marks objectAtIndex:i];
        
        itemStartY += height;
        itemStartX = 5;
       
        if (i % 2 != 0) {
            UIView *subLayer = [[UIView alloc] initWithFrame: CGRectMake(0, itemStartY, width, height)];
            subLayer.backgroundColor = [UIColor colorWithRed:129.f/255.f green:207.f/255.f blue:164.f/255.f alpha:1.0f];
            [self addSubview: subLayer];
        }
        
        for (int j = 0; j < 8; j++)
        {
            if (j == 0) {
                UIView *subLayer = [[UIView alloc] initWithFrame:CGRectMake(itemStartX, itemStartY + 8, w[0], height - 16)];
                subLayer.backgroundColor = [UIColor colorWithRed:52.f/255.f green:140.f/255.f blue:92.f/255.f alpha:1.0f];
                subLayer.layer.cornerRadius = (height - 16) / 2;
                [self addSubview:subLayer];
            }
            label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"%@", [m objectAtIndex:j]];
            label.frame = CGRectMake(itemStartX, itemStartY, w[j], height);
            label.font = font;
            label.lineBreakMode = NSLineBreakByCharWrapping;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [self selectColor:j];
            itemStartX += w[j];
            
            [self addSubview:label];
        }
        CGContextRef curretContext = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(curretContext, 1.f);
    }
}

- (void)drawClubMarks:(NSArray *)clubMarks
{
    marks = clubMarks;
    [self setNeedsDisplay];
}

- (UIColor *) selectColor : (int) index
{
    UIColor *selColor = [[UIColor alloc] init];
    switch (index) {
        case 2:
            selColor = [UIColor yellowColor];
            break;
        case 3:
            selColor = [UIColor ggaGreenBlackColor];
            break;
        case 4:
            selColor = [UIColor redColor];
            break;
        default:
            selColor = [UIColor whiteColor];
            break;
    }
    
    return selColor;
}
@end
