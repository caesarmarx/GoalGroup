//
//  MakingDiscussController.h
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"
#import "MakingDiscussItemView.h"


#define DISCUSSITEM_TAG     170

@protocol MakingDiscussControllerDelegate <NSObject>

@optional
- (void)makingDiscussSuccess;

@end

@interface MakingDiscussController : UIViewController<UITextViewDelegate, HttpManagerDelegate, MakingDiscussItemViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    int selectedItem;
}

- (id)initWithDelegate:(id<MakingDiscussControllerDelegate>)delegate;
@property (nonatomic, retain) id<MakingDiscussControllerDelegate> delegate;
@end
