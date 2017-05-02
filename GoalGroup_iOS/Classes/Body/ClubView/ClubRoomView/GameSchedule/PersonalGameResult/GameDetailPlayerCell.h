//
//  GameDetailPlayerCell.h
//  GoalGroup
//
//  Created by MacMini on 4/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameDetailPlayerCell;

@protocol GameDetailPlayerCellDelegate <NSObject>
@optional
- (void)playerDetailClick:(GameDetailPlayerCell *)cell;
@end

@interface GameDetailPlayerCell : UITableViewCell
{
    UIImageView *playerImage;
    UILabel *playerNameLabel;
    UILabel *goalLabel;
    UILabel *assistantLabel;
    UILabel *pointLabel;
}

@property(nonatomic, strong) id<GameDetailPlayerCellDelegate> delegate;

- (void)drawPlayerWithName:(NSString *)name image:(NSString *)imageUrl goal:(NSString *)goal assist:(NSString *)assist overall:(NSString *)point;
@end
