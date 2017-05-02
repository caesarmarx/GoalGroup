
#import <Foundation/Foundation.h>

#define TIMEOUT_SEC                             30.0
#define SHORT_TIMEOUT_SEC                       10.0
#define IPHONE_AGENT_VALUE                      @"iFMW_iPhone"
#define HTTPCLIENT_ETAG_FILENAME_FORMAT         @"%@.etag"

@protocol HttpClientEventHandler

@optional

- (void)requestSucceeded:(NSString *)data;
- (void)downloadSucceeded:(NSData *)data;
- (void)requestFailed:(NSError*)error;

@end

@class Reachability204;

@interface HttpClient : NSObject <UIAlertViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    
    NSURLConnection*        connection;
    NSMutableData*          recievedData;
	int                     statusCode;	
	
    
	id                      delegate;
	Reachability204*           hostReachable;
	BOOL                    networkChecked;
	
    long long               iTotalLength;
    long long               iReceivedLength;
	BOOL                    isFileDownload;
    BOOL                    hasEtag;
    NSString*               mDownloadPath;
    NSFileHandle*           mDownloadFile;
    
    BOOL                    need_nouser;
}

@property (readonly)            NSMutableData*      recievedData;
@property (nonatomic, readwrite) int                 statusCode;
@property (readonly)            long long           iTotalLength;
@property (readonly)            long long           iReceivedLength;

@property (nonatomic)           BOOL                isFileDownload;
@property (nonatomic)           BOOL                hasEtag;
@property (nonatomic)           BOOL                need_nouser;

@property (nonatomic, retain)   NSString*           mDownloadPath;
@property (nonatomic, retain)   NSFileHandle*       mDownloadFile;
@property (nonatomic, retain)   id                  delegate;

- (NSMutableURLRequest*)makeRequest:(NSString*)url;
- (void)prepareWithRequest:(NSMutableURLRequest*)request;
- (NSString*)getETagValueFrom:(NSString*) filePath;

- (void)requestDownload:(NSString *)remoteUrl LocalSavePath:(NSString*)localPath;
- (void)requestGET:(NSString*)url;
- (void)requestShortGET:(NSString*)url;
- (void)requestPOST:(NSString*)url body:(NSString*)body;
- (void)requestPOSTContent:(NSString*)url body:(NSData*)body type:(NSString*) contentType length: (unsigned long long) bodyLength;
- (void)requestSyncGET:(NSString*)url;
- (void)requestSyncPOST:(NSString*)url body:(NSString*)body;

- (void)cancelTransaction;

- (void)reset;

- (BOOL)checkNetworkStatus; 


- (void) launchLogin;

@end
