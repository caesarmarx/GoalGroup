//
//  ConferenceViewCell.h
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConferenceListRecord.h"

@interface ConferenceViewCell : UITableViewCell
{
    UIImageView *thumbSendImage;
    UIImageView *thumbRecvImage;
    
    UILabel *sendClubName;
    UILabel *recvClubName;
    
    UILabel *lastChatLabel;
    UILabel *dateLabel;
    UIView *unreadView;
    UILabel *unreadLabel;
    
    UILabel *playersLabel;
}

- (void)drawConferenceWithRecord:(ConferenceListRecord *)record;

@end
