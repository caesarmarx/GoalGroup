//
//  CustomImageView.h
//  PicturePoster
//
//  Created by System Administrator on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@protocol CustomImageViewDelegate<NSObject>
- (void)clickedImage:(int)index andIsSelect:(BOOL)isSelect;
@end

@interface CustomImageView : UIView {
    UIView                      *view;
    UIImageView                 *imageView;
    id<CustomImageViewDelegate> delegate;
}

@property (strong, nonatomic) id<CustomImageViewDelegate>       delegate;
@property (nonatomic, strong) IBOutlet UIView                   *view;
@property (nonatomic, strong) IBOutlet UIImageView              *imageView;
- (IBAction)backgroundButtonClicked:(id)sender;

@end
