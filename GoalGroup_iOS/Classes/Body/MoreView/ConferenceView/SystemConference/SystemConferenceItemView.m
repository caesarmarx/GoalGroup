//
//  SystemConferenceItemView.m
//  GoalGroup
//
//  Created by MacMini on 4/20/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "SystemConferenceItemView.h"
#import "Common.h"

@implementation SystemConferenceItemView

@synthesize record = _record;
@synthesize view = _view;

- (id)initWithSystemConferenceRecord:(SystemConferenceListRecord *)record
{
    self.record = record;
    
    UIFont *font = FONT(12.f);
    UIFont *boldFont = [UIFont boldSystemFontOfSize:12.f];
    
    int nWidth = SCREEN_WIDTH - 40;

    NSString *appealString = [record stringAppeal];
    NSString *answerString = [record stringAnswer];
    
    CGSize appealSize = [appealString sizeWithFont:boldFont constrainedToSize:CGSizeMake(nWidth, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    
    CGSize answerSize;
    if ([answerString isEqualToString:@""])
        answerSize = CGSizeMake(0, 0);
    else
        answerSize = [answerString sizeWithFont:font constrainedToSize:CGSizeMake(nWidth, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    
    int nHeight = appealSize.height + answerSize.height + 20;
    if ([answerString isEqualToString:@""])
        nHeight -= 10;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, nHeight)];
    v.backgroundColor = [UIColor ggaLittleGrayBackColor];
    v.layer.cornerRadius = 10.f;
    v.layer.masksToBounds = YES;
    
    UILabel *appeallabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, nWidth, appealSize.height)];
    appeallabel.numberOfLines = 0;
    appeallabel.lineBreakMode = NSLineBreakByCharWrapping;
    appeallabel.text = [record stringAppeal];
    appeallabel.font = boldFont;

    UILabel *answerlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, appealSize.height + 15, nWidth, answerSize.height)];
    answerlabel.numberOfLines = 0;
    answerlabel.lineBreakMode = NSLineBreakByCharWrapping;
    answerlabel.text = [record stringAnswer];
    answerlabel.font = font;

    [v addSubview:appeallabel];
    [v addSubview:answerlabel];
    
    _view = v;
    
    return self;
}

@end
