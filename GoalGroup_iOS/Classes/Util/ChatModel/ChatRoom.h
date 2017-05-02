#import <Foundation/Foundation.h>
//#import "ChattingViewController.h"

@class ChattingViewController;

@interface ChatRoom : NSObject {
    
}

@property int unreadMessageCount;
@property (nonatomic, retain) NSString * chatRoomID;
@property (nonatomic, retain) NSMutableArray *participants;
@property (nonatomic, retain) NSMutableArray *chatMessages;
//@property (nonatomic, strong) ChattingViewController *chattingVC;

@end
