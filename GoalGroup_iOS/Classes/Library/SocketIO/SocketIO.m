
#import "SocketIO.h"

#import "ASIHTTPRequest.h"
#import "WebSocket.h"
#import "RegexKitLite.h"
#import "JSONKit.h"
#import "Constants.h"
#import "ASIFormDataRequest.h"




# pragma mark -
# pragma mark SocketIO's private interface

@interface SocketIO (FP_Private) <WebSocketDelegate>

- (void) log:(NSString *)message;

- (void) setTimeout;
- (void) onTimeout;

- (void) onConnect:(SocketIOPacket *)packet;
- (void) onDisconnect;

- (void) sendDisconnect;
- (void) sendHearbeat;
- (void) send:(SocketIOPacket *)packet;

- (NSString *) addAcknowledge:(SocketIOCallback)function;
- (void) removeAcknowledgeForKey:(NSString *)key;

@end


# pragma mark -
# pragma mark SocketIO implementation

@implementation SocketIO

@synthesize isConnected = _isConnected, isConnecting = _isConnecting;

- (id) initWithDelegate:(id<SocketIODelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
        
        _queue = [[NSMutableArray alloc] init];
        
        _ackCount = 0;
        _acks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) connectToHost:(NSString *)host onPort:(NSInteger)port
{
    [self connectToHost:host onPort:port withParams:nil withNamespace:@""];
}

- (void) connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params
{
    [self connectToHost:host onPort:port withParams:params withNamespace:@""];
}

- (void) connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params withNamespace:(NSString *)endpoint
{
    if (!_isConnected && !_isConnecting) 
    {
        _isConnecting = YES;
        
        _host = [host retain];
        _port = port;
        _endpoint = [endpoint copy];
        
        // create a query parameters string
        NSMutableString *query = [[NSMutableString alloc] initWithString:@""];
        [params enumerateKeysAndObjectsUsingBlock: ^(id key, id value, BOOL *stop) {
            [query appendFormat:@"&%@=%@",key,value];
        }];
        
        // do handshake via HTTP request
        NSString *s = [NSString stringWithFormat:HANDSHAKE_URL, _host, _port, rand(), query];
        [self log:[NSString stringWithFormat:@"Connecting to socket with URL: %@",s]];
        NSURL *url = [NSURL URLWithString:s];
        [query release];
        
        //the first request to COOKIE_URL is to receive and save the cookies
        NSString *cookie = [NSString stringWithFormat:COOKIE_URL, _host, _port];
        __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL: [NSURL URLWithString:cookie]];
        [request setCompletionBlock:^{
            //this second request is the actual request for the handshake
            ASIHTTPRequest *request2 = [ASIHTTPRequest requestWithURL:url];
            [request2 setDelegate:self];
            [request2 startAsynchronous]; //requestFinished and requestFailed methods are the callbacks for this request
        }];
        [request setFailedBlock:^{
            NSError *error = [request error];
            NSLog(@"ERROR: %@", [error localizedDescription]);
            _isConnecting = NO;
        }];
        [request startAsynchronous];

    }
}

- (void) disconnect
{
    [self sendDisconnect];
}

- (void) tryDisconnect
{
    
}

- (void) sendMessage:(NSString *)data
{
    [self sendMessage:data withAcknowledge:nil];
}

- (void) sendMessage:(NSString *)data withAcknowledge:(SocketIOCallback)function
{
    SocketIOPacket *packet = [[SocketIOPacket alloc] initWithType:@"message"];
    packet.data = data;
    packet.pId = [self addAcknowledge:function];
    [self send:packet];
    [packet release];
}

- (void) sendJSON:(NSDictionary *)data
{
    [self sendJSON:data withAcknowledge:nil];
}

- (void) sendJSON:(NSDictionary *)data withAcknowledge:(SocketIOCallback)function
{
    SocketIOPacket *packet = [[SocketIOPacket alloc] initWithType:@"json"];
    packet.data = [data JSONString];
    packet.pId = [self addAcknowledge:function];
    [self send:packet];
    [packet release];
}

- (void) sendEvent:(NSString *)eventName withData:(NSDictionary *)data
{
    [self sendEvent:eventName withData:data andAcknowledge:nil];
}

- (void) sendEvent:(NSString *)eventName withData:(NSDictionary *)data andAcknowledge:(SocketIOCallback)function
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:eventName forKey:@"name"];
    if (data != nil) // do not require arguments
//        [dict setObject:data forKey:@"args"];
        [dict setObject:[NSArray arrayWithObject:data] forKey:@"args"];
    
    SocketIOPacket *packet = [[SocketIOPacket alloc] initWithType:@"event"];
    packet.data = [dict JSONString];
    packet.pId = [self addAcknowledge:function];
    if (function) 
    {
        packet.ack = @"data";
    }
    [self send:packet];
    [packet release];
}

- (void)sendAcknowledgement:(NSString *)pId withArgs:(NSArray *)data {
    SocketIOPacket *packet = [[SocketIOPacket alloc] initWithType:@"ack"];
    packet.data = [data JSONString];
    packet.pId = pId;
    packet.ack = @"data";
    
    [self send:packet];
    [packet release];
}

# pragma mark -
# pragma mark private methods

- (void) openSocket
{
    NSString *url = [NSString stringWithFormat:SOCKET_URL, _host, _port, _sid];
    
    [_webSocket release];
    _webSocket = nil;
    
    _webSocket = [[WebSocket alloc] initWithURLString:url delegate:self];
    [self log:[NSString stringWithFormat:@"Opening %@", url]];
    [_webSocket open];
    
}

- (void) sendDisconnect
{
    SocketIOPacket *packet = [[SocketIOPacket alloc] initWithType:@"disconnect"];
    [self send:packet];
    [packet release];
    _delegate = nil;
}

- (void) sendConnect
{
    SocketIOPacket *packet = [[SocketIOPacket alloc] initWithType:@"connect"];
    [self send:packet];
    [packet release];
}

- (void) sendHeartbeat
{
    SocketIOPacket *packet = [[SocketIOPacket alloc] initWithType:@"heartbeat"];
    [self send:packet];
    [packet release];
}

- (void) send:(SocketIOPacket *)packet
{   
    [self log:@"send()"];
    NSNumber *type = [packet typeAsNumber];
    NSMutableArray *encoded = [NSMutableArray arrayWithObject:type];
    
    NSString *pId = packet.pId != nil ? packet.pId : @"";
    if ([packet.ack isEqualToString:@"data"])
    {
        pId = [pId stringByAppendingString:@"+"];
    }
    
    // Do not write pid for acknowledgements
    if ([type intValue] != 6) {
        [encoded addObject:pId];
    }
    
    // Add the end point for the namespace to be used, as long as it is not
    // an ACK, heartbeat, or disconnect packet
    if ([type intValue] != 6 && [type intValue] != 2 && [type intValue] != 0) {
        [encoded addObject:_endpoint];
    } else {
        [encoded addObject:@""];
    }
    
    if (packet.data != nil)
    {
        NSString *ackpId = @"";
        // This is an acknowledgement packet, so, prepend the ack pid to the data
        if ([type intValue] == 6) {
            ackpId = [NSString stringWithFormat:@":%@%@", packet.pId, @"+"];
        }
        
        [encoded addObject:[NSString stringWithFormat:@"%@%@", ackpId, packet.data]];
    }
    
    NSString *req = [encoded componentsJoinedByString:@":"];
    if (!_isConnected) 
    {
        NSLog(@"%@ 노드서버에 접속되지 않음", LOGTAG);
        [self log:[NSString stringWithFormat:@"queue >>> %@", req]];
        
/*
 채팅서버접속이 불량인 경우 채팅파케트들을 보관했다가 접속되는 순간에 발송하는 함수
 현재 자료기지에 보관하였다가 발송하므로 대기렬을 사용하지 않습니다.
        [_queue addObject:packet];
 */
    }
    else 
    {
        NSLog(@"%@노드서버에 접속됨", LOGTAG);
        [self log:[NSString stringWithFormat:@"send() >>> %@", req]];
        [_webSocket send:req];
        
        if ([_delegate respondsToSelector:@selector(socketIO:didSendMessage:)])
        {
            [_delegate socketIO:self didSendMessage:packet];
        }
    }
}

- (void) onData:(NSString *)data 
{
    [self log:[NSString stringWithFormat:@"onData %@", data]];
    
    // data arrived -> reset timeout
    [self setTimeout];
    
    // check if data is valid (from socket.io.js)
    NSString *regex = @"^([^:]+):([0-9]+)?(\\+)?:([^:]+)?:?(.*)?$";
    NSString *regexPieces = @"^([0-9]+)(\\+)?(.*)";
    NSArray *test = [data arrayOfCaptureComponentsMatchedByRegex:regex];
    
    // valid data-string arrived
    if ([test count] > 0) 
    {
        NSArray *result = [test objectAtIndex:0];
        
        int idx = [[result objectAtIndex:1] intValue];
        SocketIOPacket *packet = [[SocketIOPacket alloc] initWithTypeIndex:idx];
        
        packet.pId = [result objectAtIndex:2];
        
        packet.ack = [result objectAtIndex:3];
        packet.endpoint = [result objectAtIndex:4];        
        packet.data = [result objectAtIndex:5];
        
        [self log:[NSString stringWithFormat:@"data idx --- %d",idx]];
        //
        switch (idx) 
        {
            case 0:
                [self log:@"disconnect"];
                [self onDisconnect];
                break;
                
            case 1:
                [self log:@"connect"];
                // from socket.io.js ... not sure when data will contain sth?! 
                // packet.qs = data || '';
                [self onConnect:packet];
                break;
                
            case 2:
                [self log:@"heartbeat"];
                [self sendHeartbeat];
                break;
                
            case 3:
                [self log:@"message"];
                if (packet.data && ![packet.data isEqualToString:@""])
                {
                    if ([_delegate respondsToSelector:@selector(socketIO:didReceiveMessage:)]) 
                    {
                        [_delegate socketIO:self didReceiveMessage:packet];
                    }
                }
                break;
                
            case 4:
                [self log:@"json"];
                if (packet.data && ![packet.data isEqualToString:@""])
                {
                    if ([_delegate respondsToSelector:@selector(socketIO:didReceiveJSON:)]) 
                    {
                        [_delegate socketIO:self didReceiveJSON:packet];
                    }
                }
                break;
                
            case 5:
                [self log:@"event"];
                if (packet.data && ![packet.data isEqualToString:@""])
                { 
                    NSDictionary *json = [packet dataAsJSON];
                    packet.name = [json objectForKey:@"name"];
                    packet.args = [json objectForKey:@"args"];
                    if ([_delegate respondsToSelector:@selector(socketIO:didReceiveEvent:)]) 
                    {
                        [_delegate socketIO:self didReceiveEvent:packet];
                    }
                }
                break;
                
            case 6:
                [self log:@"ack"];
                NSArray *pieces = [packet.data arrayOfCaptureComponentsMatchedByRegex:regexPieces];
                
                if ([pieces count] > 0) 
                {
                    NSArray *piece = [pieces objectAtIndex:0];
                    int ackId = [[piece objectAtIndex:1] intValue];
                    [self log:[NSString stringWithFormat:@"ack id found: %d", ackId]];
                    
                    NSString *argsStr = [piece objectAtIndex:3];
                    id argsData = nil;
                    if (argsStr && ![argsStr isEqualToString:@""])
                    {
                        argsData = [argsStr objectFromJSONString];
                        if ([argsData count] > 0)
                        {
                            argsData = [argsData objectAtIndex:0];
                        }
                    }
                    
                    // get selector for ackId
                    NSString *key = [NSString stringWithFormat:@"%d", ackId];
                    SocketIOCallback callbackFunction = [_acks objectForKey:key];
                    if (callbackFunction != nil)
                    {
                        callbackFunction(argsData);
                        [self removeAcknowledgeForKey:key];
                    }
                }
                
                break;
                
            case 7:
                [self log:@"error"];
                break;
                
            case 8:
                [self log:@"noop"];
                break;
                
            default:
                [self log:@"command not found or not yet supported"];
                break;
        }
        
        [packet release];
    }
    else
    {
        [self log:@"ERROR: data that has arrived wasn't valid"];
    }
}


- (void) doQueue 
{
    [self log:[NSString stringWithFormat:@"doQueue() >> %d", [_queue count]]];
    
    // TODO send all packets at once ... not as seperate packets
    while ([_queue count] > 0) 
    {
        SocketIOPacket *packet = [_queue objectAtIndex:0];
        [self send:packet];
        [_queue removeObject:packet];
    }
}

- (void) onConnect:(SocketIOPacket *)packet
{
    [self log:@"onConnect()"];
    
    _isConnected = YES;
    
    // Send the connected packet so the server knows what it's dealing with.
    // Only required when endpoint/namespace is present
    if ([_endpoint length] > 0) {
        // Make sure the packet we received has an endpoint, otherwise send it again
        if (![packet.endpoint isEqualToString:_endpoint]) {
            [self log:@"onConnect() >> End points do not match, resending connect packet"];
            [self sendConnect];
            return;
        }
    }
    
    _isConnecting = NO;
    
    if ([_delegate respondsToSelector:@selector(socketIODidConnect:)]) 
    {
        [_delegate socketIODidConnect:self];
    }
    
    // send any queued packets
    [self doQueue];
    
    [self setTimeout];
}

- (void) onDisconnect 
{
    [self log:@"onDisconnect()"];
    BOOL wasConnected = _isConnected;
    
    _isConnected = NO;
    _isConnecting = NO;
    _sid = nil;
    
    [_queue removeAllObjects];
    
    // Kill the heartbeat timer
    if (_timeout != nil) {
        [_timeout invalidate];
        _timeout = nil;
    }
    
    // Disconnect the websocket, just in case
    if (_webSocket != nil && [_webSocket connected]) {
        [_webSocket close];
    }
    
    if (wasConnected && [_delegate respondsToSelector:@selector(socketIODidDisconnect:)]) 
    {
        [_delegate socketIODidDisconnect:self];
    }
    
    [self connectToHost:SERVER_IP_ADDRESS onPort:PORT];
}

# pragma mark -
# pragma mark Acknowledge methods

- (NSString *) addAcknowledge:(SocketIOCallback)function
{
    if (function)
    {
        ++_ackCount;
        NSString *ac = [NSString stringWithFormat:@"%d", _ackCount];
        [_acks setObject:[function copy] forKey:ac];
        return ac;
    }
    return nil;
}

- (void) removeAcknowledgeForKey:(NSString *)key
{
    [_acks removeObjectForKey:key];
}

# pragma mark -
# pragma mark Heartbeat methods

- (void) onTimeout 
{
    [self log:@"Timed out waiting for heartbeat."];
    [self onDisconnect];
}

- (void) setTimeout 
{
    [self log:@"setTimeout()"];
    if (_timeout != nil) 
    {   
        [[self retain] autorelease]; //Prevent self from being dealloc'd if _timeout is the only one retaining it
        [_timeout invalidate];
        [_timeout release];
        _timeout = nil;
    }
    
    _timeout = [[NSTimer scheduledTimerWithTimeInterval:_heartbeatTimeout
                                                 target:self 
                                               selector:@selector(onTimeout) 
                                               userInfo:nil 
                                                repeats:NO] retain];
}


# pragma mark -
# pragma mark Handshake callbacks

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"cookies: %@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]);
    
    
    NSString *responseString = [request responseString];
    [self log:[NSString stringWithFormat:@"requestFinished() %@", responseString]];
    NSArray *data = [responseString componentsSeparatedByString:@":"];
    
    _sid = [[data objectAtIndex:0] retain];
    [self log:[NSString stringWithFormat:@"sid: %@", _sid]];
    
    // add small buffer of 7sec (magic xD)
    _heartbeatTimeout = [[data objectAtIndex:1] floatValue] + 7.0;
    [self log:[NSString stringWithFormat:@"heartbeatTimeout: %f", _heartbeatTimeout]];
    
    // index 2 => connection timeout
    
    NSString *t = [data objectAtIndex:3];
    NSArray *transports = [t componentsSeparatedByString:@","];
    [self log:[NSString stringWithFormat:@"transports: %@", transports]];
    
    [self openSocket];
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"ERROR: handshake failed ... %@", [error localizedDescription]);
    
    _isConnected = NO;
    _isConnecting = NO;
    
    if ([_delegate respondsToSelector:@selector(socketIOHandshakeFailed:)])
    {
        [_delegate socketIOHandshakeFailed:self];
    }
}

# pragma mark -
# pragma mark WebSocket Delegate Methods

- (void) webSocketDidClose:(WebSocket*)webSocket 
{
    [self log:[NSString stringWithFormat:@"Connection closed."]];
    [self onDisconnect];
}

- (void) webSocketDidOpen:(WebSocket *)ws 
{
    [self log:[NSString stringWithFormat:@"Connection opened."]];
}

- (void) webSocket:(WebSocket *)ws didFailWithError:(NSError *)error 
{
    NSLog(@"ERROR: Connection failed with error ... %@", [error localizedDescription]);
    // Assuming this resulted in a disconnect
    [self onDisconnect];
}

- (void) webSocket:(WebSocket *)ws didReceiveMessage:(NSString*)message 
{
    [self onData:message];
}

# pragma mark -

- (void) log:(NSString *)message 
{
#if DEBUG_LOGS
    NSLog(@"%@", message);
#endif
}


- (void) dealloc
{
    [_host release];
    [_sid release];
    [_endpoint release];
    
    [_webSocket release];
    
    [_timeout invalidate];
    [_timeout release];
    
    [_queue release];
    [_acks release];
    
    [super dealloc];
}


@end


# pragma mark -
# pragma mark SocketIOPacket implementation

@implementation SocketIOPacket

@synthesize type, pId, name, ack, data, args, endpoint;

- (id) init
{
    self = [super init];
    if (self)
    {
        _types = [[NSArray arrayWithObjects: @"disconnect", 
                   @"connect", 
                   @"heartbeat", 
                   @"message", 
                   @"json", 
                   @"event", 
                   @"ack", 
                   @"error", 
                   @"noop", 
                   nil] retain];
    }
    return self;
}

- (id) initWithType:(NSString *)packetType
{
    self = [self init];
    if (self)
    {
        self.type = packetType;
    }
    return self;
}

- (id) initWithTypeIndex:(int)index
{
    self = [self init];
    if (self)
    {
        self.type = [self typeForIndex:index];
    }
    return self;
}

- (id) dataAsJSON
{
    return [self.data objectFromJSONString];
}

- (NSNumber *) typeAsNumber
{
    int index = [_types indexOfObject:self.type];
    NSNumber *num = [NSNumber numberWithInt:index];
    return num;
}

- (NSString *) typeForIndex:(int)index
{
    return [_types objectAtIndex:index];
}

- (void)dealloc
{
    [_types release];
    
    [type release];
    [pId release];
    [name release];
    [ack release];
    [data release];
    [args release];
    [endpoint release];
    
    [super dealloc];
}

@end