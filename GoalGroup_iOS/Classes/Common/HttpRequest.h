//
//  HttpRequest.h
//  iFMW_v20
//
//  Created by System Administrator on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PROTOCAL_NAME			@"http://"
#define API_ADDRESS				@"/webapi30/iphone/"
#define API_MAIL_ADDRESS        @"/webapi30/mailer/"

#define LOGIN_API				@"login.php"
#define SIGNUP_API				@"signup.php"
#define CHANGE_ACCOUNT_API		@"change_profile.php"
#define GET_PROFILE_API			@"get_profile.php"
#define FORGET_PASSWORD_API		@"forgotten_password.php"
#define COMPLAINT_API			@"complaint.php"
#define CHECK_USER_API          @"check_user.php"
#define REG_CUSTOMER_API        @"regcustomer.php"
#define REQ_SERVER_MAIL_API     @"icloud_mail_request.php"
#define REQ_SET_CLOUDSERVER_API @"set_cloudserver_request.php"
#define SET_CLOUDSERVER_API     @"set_cloudserver.php"
#define GET_CLOUDSERVER_LIST    @"get_cloudserver_list.php"

#define GET_PHOTO_API           @"/contents/user/"
#define LOCAL_PHOTO_PATH        [DOCUMENTS_DIRECTORY_PATH stringByAppendingPathComponent:@"Photo"]
enum {
	OPChangeProfileTypeDefault,
	OPChangeProfileTypePassword,
	OPChangeProfileTypeChangeImage,
};

typedef NSUInteger 	OPChangeProfileType;

@interface HttpRequest : NSObject {

//server
	NSString * portalAddr;
//Login
	NSString * userID;
	NSString * emailAddr;
	NSString * userPassword;
	NSString * deviceToken;
//change profile
	NSString * oldPassword;
	NSString * mobile;
	NSString * userName;
	NSString * address;
	NSString * description;
	NSString * addImg; // file path
	NSUInteger delImg;
    
    NSString * photoPath;
	
//complaint
	NSString * message;
    
//regcustomer
    NSInteger gender;
    NSString * city;
    NSString * hobby;
    NSString * comment;
    NSString * birthday;
    NSString * country;
    
    NSString *clientID;
    
    //
    int      type;
    //
}

@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * deviceToken;
@property (nonatomic, retain) NSString * emailAddr;
@property (nonatomic, retain) NSString * userPassword;

@property (nonatomic, retain) NSString * oldPassword;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * description;
@property (nonatomic, retain) NSString * addImg;
@property (nonatomic) NSUInteger delImg;

@property (nonatomic, retain) NSString * message;

@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * hobby;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * country;

@property (nonatomic, retain) NSString *clientID;

@property int                           type;

- (id) init;
- (void) dealloc;

- (NSString*) base64StringFromString: (NSString*) input;
- (NSString*) md5StringFromString: (NSString*) input;

- (void) requestChangeProfile: (OPChangeProfileType) type;
- (void) requestUploadContent: (int)index;

@end
