//
//  ResearchViewController.h
//  GoalGroup
//
//  Created by KCHN on 1/30/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResearchViewController : UIViewController
{
    NSArray *rscLabelsMono;
    NSArray *rscLabelsDi;
    NSArray *rscLabelsTri;
    NSArray *rscLabelsTetra;
    NSArray *rscLabelsPenta;
    
    UIView *playerMarketView;
    UIView *clubMarketView;
    UIView *inviteLetterView;
    UIView *tmpLetterView;
    
    UILabel *playerMarketLabel;
    UILabel *clubMarketLabel;
    UILabel *inviteLetterLabel;
    UILabel *tmpLetterLabel;
    
    UILabel *inviteCountLabel;
    UILabel *tmpCountLabel;
}
- (void)refreshCount;
@end
