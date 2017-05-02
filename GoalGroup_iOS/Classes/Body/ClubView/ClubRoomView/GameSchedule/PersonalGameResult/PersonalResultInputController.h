//
//  PersonalResultInputController.h
//  GoalGroup
//
//  Created by MacMini on 4/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersonalResultInputController;
PersonalResultInputController *gPersonalResultInputController;

@protocol PersonalResultInputControllerDelegate <NSObject>
@optional
- (void)inputFinished:(int)goal assist:(int)assist point:(int)point;
@end

@interface PersonalResultInputController : UIViewController<UITextFieldDelegate>
{
    UILabel *goalLabel;
    UILabel *assistLabel;
    UILabel *pointLabel;
    
    UITextField *goalTextField;
    UITextField *assistTextField;
    UITextField *pointTextField;
}

@property(nonatomic, strong) id<PersonalResultInputControllerDelegate> delegate;

+ (PersonalResultInputController *)sharedInstance;
- (void)setGoal:(int)goal assist:(int)assist point:(int)point title:(NSString *)title;
@end
