//
//  SystemConferenceItemView.h
//  GoalGroup
//
//  Created by MacMini on 4/20/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SystemConferenceListRecord.h"

@interface SystemConferenceItemView : NSObject

@property (readonly, nonatomic, strong) UIView *view;
@property (nonatomic, strong) SystemConferenceListRecord *record;

- (id)initWithSystemConferenceRecord:(SystemConferenceListRecord *)record;
@end
