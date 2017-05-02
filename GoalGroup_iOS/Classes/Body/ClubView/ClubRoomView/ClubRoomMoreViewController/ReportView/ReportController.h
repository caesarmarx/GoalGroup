//
//  ReportController.h
//  GoalGroup
//
//  Created by KCHN on 3/6/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"

@class ReportController;
ReportController *gReportController;

@interface ReportController : UIViewController<HttpManagerDelegate, UITextViewDelegate>

- (id)initWithTitle:(NSString *)title;
@end
