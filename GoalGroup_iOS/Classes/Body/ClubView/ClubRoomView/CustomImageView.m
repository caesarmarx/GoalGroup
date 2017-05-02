//
//  CustomImageView.m
//  PicturePoster
//
//  Created by System Administrator on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomImageView.h"
#import "Constants.h"
#import "CustomImageView.h"
#import "Constants.h"
#import "ClubRoomViewController.h"


@implementation CustomImageView

@synthesize view,imageView;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"CustomImageView" owner:self options:nil];
    [self addSubview:self.view];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (IBAction)backgroundButtonClicked:(id)sender
{
    int imageIdx = self.tag - 10000;
    [delegate clickedImage:imageIdx andIsSelect:YES];
    
}

@end