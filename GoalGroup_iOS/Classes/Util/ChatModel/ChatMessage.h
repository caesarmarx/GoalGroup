#import <Foundation/Foundation.h>

#define YuChatTextMessage 1
#define YuChatLocalPicture 2
#define YuChatAudioMessage  3

#define YuChatRemotePicture 4

@interface ChatMessage : NSObject { 

}


@property (nonatomic,retain) NSString * msg ;
@property NSInteger senderId ;
@property NSInteger roomId;
@property (nonatomic, strong) NSString *sendTime;
@property (nonatomic, strong) NSString *senderName;
@property (nonatomic, strong) NSString *userPhoto;
@property (nonatomic, strong) NSString *thumbImageUrl;
@property (nonatomic, strong) NSString *contentIcon;
@property (nonatomic, strong) NSString *img_name;
@property int readState;
@property int sendState;
@property int type;


+ (int)addChatMessage:(ChatMessage *)chatmessage;
+ (NSMutableArray *)getMessageByroomId:(int)roomId;
+ (NSMutableArray *)getUnreadMessageByroomId:(int)roomId;
+ (NSMutableArray *)getUnsendMessage;
@end
