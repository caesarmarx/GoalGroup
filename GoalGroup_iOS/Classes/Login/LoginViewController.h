//
//  LoginViewController.h
//
//  Created by JinYongHao on 9/25/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDiscreetNotificationView.h"
#import "HttpManager.h"



@interface LoginViewController : UIViewController <UITextFieldDelegate, HttpManagerDelegate>
{
    BOOL                    isKeyboardDidShow;
    
    UITextField             *usTextField;
	UITextField             *pwTextField;
    UIButton                *loginButton;
    UIButton                *registerButton;
    
    GCDiscreetNotificationView *dnv;
    
    IBOutlet UIScrollView *scrollView; //Added By Jiaxing.2015/05/02
}
@property (nonatomic,retain) UIScrollView *scrollView; //Added By Jiaxing.2015/05/02

@end
