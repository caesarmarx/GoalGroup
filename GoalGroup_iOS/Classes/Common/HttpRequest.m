//
//  HttpRequest.m
//  iFMW_v20
//
//  Created by System Administrator on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HttpRequest.h"
#import  <CommonCrypto/CommonDigest.h>
#import "NSData+Base64.h"
#import "Constants.h"
#import "ggaAppDelegate.h"
#import "FileManager.h"

@implementation HttpRequest

@synthesize userID, emailAddr, userPassword, deviceToken;
@synthesize oldPassword, mobile, userName, address, description, addImg, delImg;
@synthesize message;
@synthesize gender;
@synthesize city;
@synthesize hobby;
@synthesize comment;
@synthesize birthday;
@synthesize country;
@synthesize clientID;
@synthesize type;

- (id) init {
    self = [super init];
    if (self) {
		
    }
    return self;
}

- (NSString*) base64StringFromString: (NSString*) input {
    return [[input dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}

- (NSString*) md5StringFromString: (NSString*) input {
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5([input UTF8String], [input length], result);
		
	NSMutableString *hash = [NSMutableString string];
	
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[hash appendFormat:@"%02X", result[i]];
	}
	
	return [hash lowercaseString];
}

- (void) requestUploadContent:(int)index
{
    NSString *url = [NSString stringWithFormat:FILE_UPLOAD_URL, SERVER_IP_ADDRESS, _PORT];
    
    NSString *              bodyPrefixStr = @"";
    NSString *              bodySuffixStr = @"";
    unsigned long long      bodyLength;
    BOOL isDir = NO;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:addImg isDirectory:&isDir] && !isDir)
    {
        NSString* imageType = @"application/octet-stream"; //@"image/png";
        NSString* boundary = @"---------------------------7da31c351a0420";
        NSString* contentType;
        
        if(type == 1)
            contentType = [NSString stringWithFormat:@"multipart/form-data; type=img; boundary=%@", boundary, index];
        else
            contentType = [NSString stringWithFormat:@"multipart/form-data; type=aud; boundary=%@; server_idx=%d", boundary, index];
        
        
        NSString *tmp = [addImg stringByDeletingPathExtension];
        
        bodyPrefixStr = [bodyPrefixStr stringByAppendingFormat:@"--%@\r\nContent-Disposition: form-data; name=\"image_data\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", boundary, tmp, imageType];
        
        assert(bodyPrefixStr != nil);
        
        bodySuffixStr = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];
        assert(bodySuffixStr != nil);
        
        NSData *dataFromFile;
        if (type == 1)
        {
            UIImage *image = [UIImage imageWithContentsOfFile:addImg];
            dataFromFile = UIImageJPEGRepresentation(image, 0.75);
        }
        else
        {
            dataFromFile = [FileManager GetDataFromFilePath:addImg];
        }
        
        NSMutableData* myPostData = [NSMutableData data];
        [myPostData appendData:[bodyPrefixStr dataUsingEncoding:NSUTF8StringEncoding]];
        [myPostData appendData:dataFromFile];
        [myPostData appendData:[bodySuffixStr dataUsingEncoding:NSUTF8StringEncoding]];
        
        bodyLength = [myPostData length];
        
        ggaAppDelegate * appDelegate = (ggaAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.httpClientForUpload requestPOSTContent:url body:myPostData type:contentType length:bodyLength];

    }
}

- (void) requestChangeProfile: (OPChangeProfileType) type
{
	NSString *url = [PROTOCAL_NAME stringByAppendingFormat:@"%@%@%@", portalAddr, API_ADDRESS, CHANGE_ACCOUNT_API];	
	NSString *param = nil;
	if (type == OPChangeProfileTypeChangeImage) {
        NSString *              bodyPrefixStr;
        NSString *              bodySuffixStr;
        unsigned long long      bodyLength;
        BOOL isDir = NO;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:addImg isDirectory:&isDir] && !isDir)
        {
            NSString* imageType = [NSString stringWithString:@"image/png"];
            NSString* boundary = [NSString stringWithString:@"---------------------------7da31c351a0420"];
            NSString* contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            
            bodyPrefixStr = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"userid\"\r\n\r\n%@\r\n", boundary, userID];
            bodyPrefixStr = [bodyPrefixStr stringByAppendingFormat:@"--%@\r\nContent-Disposition: form-data; name=\"old_passwd\"\r\n\r\n%@\r\n", boundary, [self md5StringFromString:oldPassword]];
            bodyPrefixStr = [bodyPrefixStr stringByAppendingFormat:@"--%@\r\nContent-Disposition: form-data; name=\"mobile\"\r\n\r\n%@\r\n", boundary, mobile];
            bodyPrefixStr = [bodyPrefixStr stringByAppendingFormat:@"--%@\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\n%@\r\n", boundary, [self base64StringFromString: userName]];
            bodyPrefixStr = [bodyPrefixStr stringByAppendingFormat:@"--%@\r\nContent-Disposition: form-data; name=\"address\"\r\n\r\n%@\r\n", boundary, [self base64StringFromString: address]];
            
            bodyPrefixStr = [bodyPrefixStr stringByAppendingFormat:@"--%@\r\nContent-Disposition: form-data; name=\"uploadfile\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", boundary, [addImg stringByDeletingPathExtension], imageType];
            
            NSString * del_img_data = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"del_img\"\r\n\r\n%d\r\n", boundary, delImg];

            assert(bodyPrefixStr != nil);
            
            bodySuffixStr = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];
            assert(bodySuffixStr != nil);
                        
            UIImage *image = [UIImage imageWithContentsOfFile:addImg];
            NSData *dataFromFile = UIImageJPEGRepresentation(image, 0.1);

            NSMutableData* myPostData = [NSMutableData data];
            [myPostData appendData:[bodyPrefixStr dataUsingEncoding:NSUTF8StringEncoding]];
            [myPostData appendData:dataFromFile];
            [myPostData appendData:[del_img_data dataUsingEncoding:NSUTF8StringEncoding]];
            [myPostData appendData:[bodySuffixStr dataUsingEncoding:NSUTF8StringEncoding]];
            
            bodyLength = [myPostData length];
//            iFMW_v20AppDelegate * appDelegate = (iFMW_v20AppDelegate *)[[UIApplication sharedApplication] delegate];
//            [appDelegate.g_httpClientOP requestPOSTContent:url body:myPostData type:contentType length:bodyLength];
            return;
        }
	}
}

@end
