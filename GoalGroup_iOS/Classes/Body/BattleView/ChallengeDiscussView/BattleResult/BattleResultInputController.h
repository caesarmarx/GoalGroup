//
//  BattleResultInputController.h
//  GoalGroup
//
//  Created by MacMini on 4/6/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"
#import "ChallengeListRecord.h"
#import "DAOverlayView.h"

@class BattleResultInputController;
BattleResultInputController *gBattleResultInputController;

@interface BattleResultInputController : UIViewController<UITextFieldDelegate, HttpManagerDelegate, DAOverlayViewDelegate>
{
    DAOverlayView *overlayView;
    
    UIImageView *sendClubImage;
    UIImageView *recvClubImage;
    UILabel *sendClubLabel;
    UILabel *recvClubLabel;
    UILabel *gameResultLabel;
    
    UITextField *firstSendMark;
    UITextField *firstRecvMark;
    UITextField *secondSendMark;
    UITextField *secondRecvMark;
    
    int nClubID;
    int nGameID;
    int Match_Result;
    
}
+ (BattleResultInputController *)sharedInstance;

- (void)setClubID:(int)clubID gameID:(int)gameID;

@end
