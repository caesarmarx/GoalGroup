//
//  MakingDiscussItemView.m
//  GoalGroup
//
//  Created by MacMini on 3/18/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "MakingDiscussItemView.h"
#import "Common.h"

@implementation MakingDiscussItemView

- (id)initWithFrame:(CGRect)rect WithItemID:(int)item withDelegate:(id<MakingDiscussItemViewDelegate>)delegate
{
    item_id = item;
    self.delegate = delegate;
    return [self initWithFrame:rect];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self layoutComponents];
    }
    return self;
}

- (void)layoutComponents
{
    UIView *imageRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    discussImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    discussImage.image = IMAGE(@"addicon");
    [imageRegion addSubview:discussImage];
    
    discussText = [[UITextView alloc] initWithFrame:CGRectMake(100, 10, SCREEN_WIDTH - 110, 80)];
    discussText.layer.borderColor = [UIColor ggaGrayBorderColor].CGColor;
    discussText.autocorrectionType = UITextAutocorrectionTypeNo;
    discussText.returnKeyType = UIReturnKeyDone;
    discussText.textAlignment = NSTextAlignmentLeft;
    discussText.layer.borderWidth = 1.f;
    discussText.layer.cornerRadius = 4.f;
    discussText.font = FONT(14.f);
    discussText.delegate = self;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePhotoClick:)];
    
    [imageRegion addGestureRecognizer:gesture];
    
    self.backgroundColor = [UIColor ggaGrayBackColor];
    [self addSubview:imageRegion];
    [self addSubview:discussText];
}
- (void)drawRect:(CGRect)rect
{
}

- (void)takePhotoClick:(UITapGestureRecognizer *)tapGesture
{
    [self.delegate takePhotoClickItemView:item_id];
}

- (NSString *)discussContent
{
    return discussText.text == nil? @"": discussText.text;
}

- (NSString *)discussImageUrl
{
    return @"";
}

- (UIImage *)discussImage
{
    return discussImage.image;
}

- (void)setImage:(UIImage *)image
{
    discussImage.image = [[UIImage alloc] init];
    discussImage.image = image;
    [self setNeedsDisplay];
}

#pragma UITextView
- (void)textViewDidBeginEditing:(UITextView *)textView
{
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text != nil &&![textView.text isEqual:@""])
    {
        if (textView.text.length == 1)
            [self.delegate emptyItemView:item_id];
        else
            [self.delegate nonEmptyItemView:item_id];
            
    }
}
@end
