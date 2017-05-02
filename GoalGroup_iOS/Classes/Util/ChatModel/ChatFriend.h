#import <Foundation/Foundation.h>

@interface ChatFriend : NSObject {
}

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * pictureURL;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * statusMessage;
@property (nonatomic, retain) NSString * nickName;

@property BOOL favorite;

@end
