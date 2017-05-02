//
//  ClubMemberListViewCell.h
//  GoalGroup
//
//  Created by KCHN on 3/2/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerListRecord.h"

@class ClubMemberListViewCell;
@protocol ClubMemberListViewCellDelegate <NSObject>
- (void)memberIconClick:(ClubMemberListViewCell *)cell;
@end

@interface ClubMemberListViewCell : UITableViewCell
{
    UIImageView *thumbImage;
    UILabel *nameLabel;
}

- (void)drawListWithData:(PlayerListRecord *)record;

@property(nonatomic, retain) id<ClubMemberListViewCellDelegate> delegate;
@property(nonatomic, retain) PlayerListRecord *record;
@property(nonatomic) BOOL corchSelectMode;

@end
