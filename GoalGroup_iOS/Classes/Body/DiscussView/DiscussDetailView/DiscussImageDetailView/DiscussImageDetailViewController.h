//
//  DiscussImageDetailViewController.h
//  GoalGroup
//
//  Created by lion on 5/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiscussImageDetailViewController;
DiscussImageDetailViewController *gDiscussImageDetailViewController;

@interface DiscussImageDetailViewController : UIViewController
{
    UIImageView *imageView;
}

+ (id)sharedInstance;
- (void)drawDiscussImageWithUrl:(NSString *)imageUrl;
@end
