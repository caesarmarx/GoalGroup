//
//  ConferenceController.h
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscussRoomManager.h"
#import "ConferenceListRecord.h"

@class ConferenceController;
ConferenceController *gConferenceController;

@interface ConferenceController : UITableViewController <UIScrollViewDelegate>
{
    NSMutableArray *conferences;
}
+ (ConferenceController *)sharedInstance;
- (void)refreshTableView;
NSInteger stringSort(ConferenceListRecord *arg1, ConferenceListRecord *arg2, void *context);
@end
