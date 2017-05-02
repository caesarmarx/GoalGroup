//
//  GameDetailController.h
//  GoalGroup
//
//  Created by MacMini on 4/11/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChallengeListRecord.h"
#import "ChallengeItemView.h"
#import "PersonalResultInputController.h"
#import "HttpManager.h"
#import "GameDetailPlayerCell.h"

@class GameDetailController;
GameDetailController *gGameDetailController;

@interface GameDetailController : UIViewController<UITableViewDelegate, UITableViewDataSource, HttpManagerDelegate, PersonalResultInputControllerDelegate, ChallengeItemViewDelegate, GameDetailPlayerCellDelegate>
{
    ChallengeItemView *gameView;
    UITableView *playerView;
    
    NSMutableArray *players;
    ChallengeListRecord *gameInfo;
    
    int nClubID;
    UIView *saveButtonRegion;
}

+ (GameDetailController *)sharedInstance:(ChallengeListRecord *) gameInfo club:(int)clubID;
- (void)withGameInfo:(ChallengeListRecord *)record club:(int)clubID;
@end
