
#import "HttpClient.h"
#import "Reachability204.h"

@implementation HttpClient

@synthesize recievedData, statusCode;
@synthesize delegate;

@synthesize hasEtag, isFileDownload;
@synthesize mDownloadFile, mDownloadPath;
@synthesize iTotalLength, iReceivedLength;
@synthesize need_nouser;

- (id)init {
    
    self = [super init];
	if (self) {
		[self reset];
        self.need_nouser = NO;
        self.delegate = nil;
        self->networkChecked = NO;
    }
    
    return self;
}

- (void)reset {
	recievedData = [[NSMutableData alloc] init];
    [connection cancel];
	connection = nil;
	statusCode = 0;	
	networkChecked = NO;

    mDownloadPath = nil;
    [mDownloadFile closeFile];
}


#pragma mark -
#pragma mark HTTP Request creating methods

- (NSMutableURLRequest*)makeRequest:(NSString*)url {
//	NSString *encodedUrl = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8);
    NSString *encodedUrl = url;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:encodedUrl]];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[request setTimeoutInterval:TIMEOUT_SEC];
	[request setHTTPShouldHandleCookies:FALSE];
    [request setValue:IPHONE_AGENT_VALUE forHTTPHeaderField:@"User-Agent"];
	return request;
}

- (NSMutableURLRequest*)makeShortRequest:(NSString*)url {
//	NSString *encodedUrl = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8);
    NSString *encodedUrl = url;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:encodedUrl]];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[request setTimeoutInterval:SHORT_TIMEOUT_SEC];
	[request setHTTPShouldHandleCookies:FALSE];
    [request setValue:IPHONE_AGENT_VALUE forHTTPHeaderField:@"User-Agent"];
	return request;
}

- (void)prepareWithRequest:(NSMutableURLRequest*)request {
	
    if (!isFileDownload)
        return;
        
    NSString* etag = [self getETagValueFrom:mDownloadPath];
    if (etag != nil) {
        
        UInt64 size = [[[NSFileManager defaultManager] attributesOfItemAtPath:mDownloadPath error:nil] fileSize];
        [request setValue:etag forHTTPHeaderField:@"If-Range"];
        [request setValue:[NSString stringWithFormat:@"bytes=%d-", size] forHTTPHeaderField:@"Range"];
        iReceivedLength = size;
        hasEtag = YES;
    }
    else {
        hasEtag = NO;
        iReceivedLength = 0;
    }  
}

- (NSString*)getETagValueFrom:(NSString*) filePath {

    NSString* etagFile = [NSString stringWithFormat:HTTPCLIENT_ETAG_FILENAME_FORMAT, filePath];
    
    NSString *etag = [NSString stringWithContentsOfFile:etagFile 
                                           usedEncoding:NULL 
                                                  error:NULL];
    return etag;
}

#pragma mark -
#pragma mark HTTP Transaction management methods

- (void)requestDownload:(NSString *)remoteUrl LocalSavePath:(NSString*)localPath{
	
	[self reset];
    
    isFileDownload = YES;
	mDownloadPath = [localPath copy];
    
	NSMutableURLRequest *request = [self makeRequest:remoteUrl];
	[self prepareWithRequest:request];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [connection start];
}

/* Sending the Http Request for "GET" */
- (void)requestGET:(NSString*)url {
	
	//Reseting the http client
	[self reset];
	isFileDownload = NO;
	
	//Sending the http requqest
	NSMutableURLRequest *request = [self makeRequest:url];
	[self prepareWithRequest:request];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

/* Sending the Http Request for "GET" */
- (void)requestShortGET:(NSString*)url {
	
	//Reseting the http client
	[self reset];
	isFileDownload = NO;
	
	//Sending the http requqest
	NSMutableURLRequest *request = [self makeShortRequest:url];
	[self prepareWithRequest:request];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

/* Sending the Http Request for "POST" */
- (void)requestPOST:(NSString*)url body:(NSString*)body{
	
	//Reseting the http client
	[self reset];
	isFileDownload = NO;
	
	//Sending the http requqest
	NSMutableURLRequest *request = [self makeRequest:url];
    [request setHTTPMethod:@"POST"];

	if (body) {
		[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[self prepareWithRequest:request];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)requestPOSTContent:(NSString*)url body:(NSData*)body type:(NSString*) contentType length: (unsigned long long) bodyLength{
	
	//Reseting the http client
	[self reset];
	isFileDownload = NO;
	
	//Sending the http requqest
	NSMutableURLRequest *request = [self makeRequest:url];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%llu", bodyLength] forHTTPHeaderField:@"Content-Length"];
    
    if (body) {
		[request setHTTPBody:body];
	}
	[self prepareWithRequest:request];
    
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    //
//    NSURLResponse *response;
//    NSError *err;
//    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
//    if (response)
//        [self connection:nil didReceiveResponse:response];
//    if (result)
//        [self connection:nil didReceiveData:result];
//    
//    if (!err)
//        [self connectionDidFinishLoading:nil];
//    else
//        [self connection:nil didFailWithError:err];
//    //
}

/* Sending the Http Request for "GET" */
- (void)requestSyncGET:(NSString*)url {
	
	//Reseting the http client
	[self reset];
	isFileDownload = NO;
	
	//Sending the http requqest
	NSMutableURLRequest *request = [self makeRequest:url];
	[self prepareWithRequest:request];

    NSURLResponse *response;
    NSError *err;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    if (response)
        [self connection:nil didReceiveResponse:response];
    if (result)
        [self connection:nil didReceiveData:result];
    if (err)
        [self connectionDidFinishLoading:nil];
    else
        [self connection:nil didFailWithError:err];
}

/* Sending the Http Request for "POST" */
- (void)requestSyncPOST:(NSString*)url body:(NSString*)body{
	
	//Reseting the http client
	[self reset];
	isFileDownload = NO;
	
	//Sending the http requqest
	NSMutableURLRequest *request = [self makeRequest:url];
    [request setHTTPMethod:@"POST"];
    //	if (type != nil && ![type isEqualToString:@""])
    //		[request setValue:type forHTTPHeaderField:@"Content-Type"];	
	if (body) {
		[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[self prepareWithRequest:request];

    NSURLResponse *response;
    NSError *err;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    if (response)
        [self connection:nil didReceiveResponse:response];
    if (result)
        [self connection:nil didReceiveData:result];
    if (err)
        [self connectionDidFinishLoading:nil];
    else
        [self connection:nil didFailWithError:err];
}

/* Canceling the HTTP Transaction */
- (void)cancelTransaction {
	[connection cancel];
	[self reset];
    need_nouser = NO;
}

#pragma mark -
#pragma mark NSURLConnectionDelegate methods

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSURLResponse *)response {
    
	statusCode = [(NSHTTPURLResponse*)response statusCode];
    
    if (statusCode == 503 || statusCode == 406/* || statusCode == 500*/) {
        [self reset];
        need_nouser = NO;
    }
    
    if (statusCode == 206 && isFileDownload) { // this is "RESUME" case
        mDownloadFile = [[NSFileHandle fileHandleForWritingAtPath:mDownloadPath] copy];
        [mDownloadFile seekToFileOffset:[mDownloadFile seekToEndOfFile]];
        
        NSDictionary* headers = [(NSHTTPURLResponse*)response allHeaderFields];
        NSString* contentLengthString = (NSString*)[headers valueForKey:@"Content-Length"];
        if (!contentLengthString) {
            [self connection:_connection didFailWithError:nil];
            return;
        }
        
        iTotalLength = [contentLengthString integerValue];
        iTotalLength += iReceivedLength;

        statusCode = 200;
    }
    else if (statusCode == 200 && isFileDownload) {
        
        [[NSFileManager defaultManager] removeItemAtPath:mDownloadPath error:nil];   
        BOOL res = [[NSFileManager defaultManager] createFileAtPath: mDownloadPath contents: nil attributes: nil];
        
        if (!res) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[mDownloadPath stringByDeletingLastPathComponent] 
                                      withIntermediateDirectories:YES 
                                                       attributes:nil 
                                                            error:NULL];

            [[NSFileManager defaultManager] createFileAtPath: mDownloadPath contents: nil attributes: nil];
        }
        
        mDownloadFile = [[NSFileHandle fileHandleForWritingAtPath:mDownloadPath] copy];
        
        NSDictionary* headers = [(NSHTTPURLResponse*)response allHeaderFields];
        NSString* contentLengthString = (NSString*)[headers valueForKey:@"Content-Length"];
        if (!contentLengthString) {
            [self connection:_connection didFailWithError:nil];
            return;
        }

        NSString* newEtag = (NSString*)[headers valueForKey:@"Etag"];
        
        [newEtag writeToFile:[NSString stringWithFormat:HTTPCLIENT_ETAG_FILENAME_FORMAT, mDownloadPath] 
                  atomically:YES 
                    encoding:NSASCIIStringEncoding 
                       error:nil];
        
        iTotalLength = [contentLengthString integerValue];
    }
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didReceiveResponse:)]){
        [self.delegate performSelector:@selector(didReceiveResponse:) withObject:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (isFileDownload && statusCode == 200) {
        iReceivedLength += [data length];
        [mDownloadFile writeData:data];
    }
    else
        [recievedData appendData:data];
    
    if (isFileDownload && statusCode == 200 && self.delegate != nil && [self.delegate respondsToSelector:@selector(didReceiveData:)]){
        [self.delegate performSelector:@selector(didReceiveData:) withObject:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection {

    if (isFileDownload) {
        if (iTotalLength != iReceivedLength) {
            [self connection:_connection didFailWithError:nil];
            return;
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:HTTPCLIENT_ETAG_FILENAME_FORMAT, mDownloadPath] error:nil];
        [mDownloadFile closeFile];
        mDownloadFile = nil;
    }
    
    NSString *data;
    if (recievedData && [recievedData length] > 0)
        data = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
    else
        data = @"";
    
	[self reset];
    need_nouser = NO;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(requestSucceeded:)]){
        [self.delegate performSelector:@selector(requestSucceeded:) withObject:data];
    }
}

- (void)connection:(NSURLConnection *)_connection didFailWithError:(NSError*) error {
    
    if (isFileDownload) {
        [mDownloadFile closeFile];
        mDownloadFile = nil;
    }
    
    [self reset];
    need_nouser = NO;
    
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(requestFailed:)]){
		[self.delegate performSelector:@selector(requestFailed:) withObject:error];
	}
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}


//check network status chages
- (BOOL)checkNetworkStatus
{
	BOOL res = NO;
	Reachability204* reachability = [Reachability204 reachabilityWithHostName:@""];
	NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];	
	
	if(remoteHostStatus == NotReachable)
		res = NO;
	else if (remoteHostStatus == ReachableViaWWAN)
		res = YES;
	else if (remoteHostStatus == ReachableViaWiFi)
		res = YES;
	
	return res;
}


- (void) launchLogin {
    
}

@end
