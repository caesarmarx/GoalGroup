#import "ChatRoom.h"

@implementation ChatRoom

@synthesize unreadMessageCount;
@synthesize chatMessages;
//@synthesize chattingVC;
@synthesize participants;
@synthesize chatRoomID;

- (id) init {
    self.chatMessages = [[NSMutableArray alloc] init];
    self.participants = [[NSMutableArray alloc] init];
//    self.chattingVC = nil;
    
    return self;
}

- (id) initWithChatView:(ChattingViewController *) chattingView {
    self = [self init];
//    self.chattingVC = chattingView;
    return self;
}

@end
