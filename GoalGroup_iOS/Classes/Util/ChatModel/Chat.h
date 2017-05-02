#import <Foundation/Foundation.h>
#import "ChatMessage.h"
#import "SocketIO.h"

#define TEST_MODE 1

#ifndef YUCHAT_DEBUG_LOG
#define YUCHAT_DEBUG_LOG NSLog
#endif

#ifndef YUCHAT_HOST
#define YUCHAT_HOST @"http://ec2-107-21-148-54.compute-1.amazonaws.com:3000/"
#endif

#ifndef YUCHAT_HOST_UPLOAD
#define YUCHAT_HOST_UPLOAD @"http://ec2-107-21-148-54.compute-1.amazonaws.com:3000/upload"
#endif

@class Chat;

@protocol VerifyCodeDelegate <NSObject>
@optional
- (void) yuChat:(Chat *)yuChat receiveVerifyResponse:(NSString *)response;
@end

@protocol ChatDelegate <NSObject, NSFileManagerDelegate>
@optional
- (void)addChattingMessageToVCWithMessage:(ChatMessage *)chMsg recordIdx:(int)recordIdx;
@end

@interface Chat : NSObject <SocketIODelegate> {
    NSMutableDictionary * chatRooms;
    NSMutableArray * friends;
}

+ (id)sharedInstance;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize ;

- (id)init;
- (void)setDelegate:(id<ChatDelegate>) delegate;
- (void)closeConnection;
- (void)tryConnection;

- (void) receiveMessage:(NSMutableArray *)message;
- (void) receivePhotoMessage:(NSMutableArray *)photomessage;
- (void) receiveAudioMessage:(NSMutableArray *)audiomessage;

- (void) sendChatMessage:(ChatMessage *)message withDelegate:(id<ChatDelegate>)delegate;
- (void) sendMessage:(NSString *)data;
- (void) sendMessage:(NSString *)data withAcknowledge:(SocketIOCallback)function;
- (void) sendJSON:(NSDictionary *)data;
- (void) sendJSON:(NSDictionary *)data withAcknowledge:(SocketIOCallback)function;
- (void) sendEvent:(NSString *)eventName withData:(NSDictionary *)data;
- (void) sendEvent:(NSString *)eventName withData:(NSDictionary *)data andAcknowledge:(SocketIOCallback)function;

- (void) setVerifyCodeDelegate:(id)delegate;
- (BOOL) chatEnable;

@property (nonatomic, retain) id<ChatDelegate, VerifyCodeDelegate> delegate;
@property (nonatomic,retain) NSString * username;
@property (nonatomic,retain) SocketIO * socketIO;

@end
