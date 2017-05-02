//
//  ClubRoomViewController.h
//  GoalGroup
//
//  Created by KCHN on 2/4/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
#import "ChallengeListRecord.h"
#import "HttpManager.h"
#import "ChatMessage.h"
#import "Chat.h"
#import "ConferenceListRecord.h"
#import "RecorderManager.h"
#import "NSBubbleData.h"

@class ClubRoomViewController;
ClubRoomViewController *gClubRoomViewController;

@interface ClubRoomViewController : UIViewController<UIBubbleTableViewDataSource, HttpManagerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, RecordingDelegate, UITextFieldDelegate, ChatDelegate, NSBubbleDataDelegate>
{
    BOOL isRemoveRecord;
    BOOL extendMode;

    int nMineClubID;
    int nOppositClubID;
    int nRoomID;
    
    ChallengeListRecord *gameInfo;
    NSMutableArray *messageList;
    NSArray *subMenuArray;
	NSRange lastSelectedTextRange;
    
    BOOL isRecording;
    UIProgressView *levelMeter;
    UIButton *recordButton;
    UIButton *removeButton;
    NSString *voicemailFilePath;
    
    NSTimer *recordTimer;
    int recordCnt;
    BOOL recording;
}

@property (nonatomic, retain) NSMutableArray *imageList;
@property (nonatomic ,retain) NSDictionary *faceMap;
@property (nonatomic, retain) NSMutableArray *drawedEmoticons;
@property (nonatomic, retain) NSMutableString *inputText;
@property (nonatomic) NSInteger imageLocation;
@property (nonatomic, strong) NSString        *savedFilePath;
@property (nonatomic, strong) UIImageView *thumbImageView;

+ (ClubRoomViewController *)sharedInstance;

- (id)initWithNibName:(NSString *)nibNameOrNil clubID:(int)c_id bundle:(NSBundle *)nibBundleOrNil;
- (id)initWithNibName:(NSString *)nibNameOrNil gameInfo:(ChallengeListRecord *)record type:(int)type clubID:(int)clubID roomID:(int)roomID;
- (id)initWithNibName:(NSString *)nibNameOrNil conference:(ConferenceListRecord *)record;
@end
