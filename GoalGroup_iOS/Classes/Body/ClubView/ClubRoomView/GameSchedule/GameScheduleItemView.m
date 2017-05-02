//
//  GameScheduleItemView.m
//  GoalGroup
//
//  Created by KCHN on 2/12/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "GameScheduleItemView.h"
#import "Common.h"

@implementation GameScheduleItemView
{
    UIImage *scheduleImage;
    NSString *scheduleTimeStr;
    NSString *scheduleTeamStr;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];

    self.backgroundColor = [UIColor whiteColor];
}

- (void)drawWithImage:(UIImage *)image Time:(NSString *)timeStr Team:(NSString *)teamStr
{
    [self setNeedsDisplay];
}
@end
