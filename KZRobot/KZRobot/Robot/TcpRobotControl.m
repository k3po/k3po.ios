//
//  TcpRobotControl.m
//  KMStompJMS
//
//  Created by pkhanal on 7/29/14.
//
//

#import "TcpRobotControl.h"

@implementation TcpRobotControl {
    NSString *_host;
    int _port;
    CFReadStreamRef _readStream;
    CFWriteStreamRef _writeStream;
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    
    dispatch_semaphore_t _inputStreamOpened;
    dispatch_semaphore_t _outputStreamOpened;
    BOOL _connected;
}

- (id) initWithHost:(NSString *)host port:(int)port {
    self = [super init];
    if (self) {
        _host = host;
        _port = port;
        
        _inputStreamOpened = dispatch_semaphore_create(0);
        _outputStreamOpened = dispatch_semaphore_create(0);
        
        _connected = NO;
    }
    return self;
}

- (void) connect {
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) _host, _port, &_readStream, &_writeStream);
    
    // Indicate that we want socket to be closed whenever streams are closed.
    CFReadStreamSetProperty(_readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(_writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    _inputStream = (__bridge NSInputStream *)_readStream;
    _outputStream = (__bridge NSOutputStream *)_writeStream;
    
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [self performSelector:@selector(scheduleInCurrentThread) onThread:[[self class] networkThread] withObject:nil waitUntilDone:YES];
    
    dispatch_semaphore_wait(_inputStreamOpened, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(_outputStreamOpened, DISPATCH_TIME_FOREVER);
    
    if (!_connected) {
        [NSException raise:@"SocketException" format:@"Cannot connect to %@:%d. Is the Robot Server running?", _host, _port];
    }
    
}

- (void) disconnect {
    [_inputStream close];
    CFReadStreamClose(_readStream);
    CFRelease(_readStream);
    
    [_outputStream close];
    CFWriteStreamClose(_writeStream);
    CFRelease(_writeStream);
}

- (NSString *) readLine {
    NSMutableString *line = [[NSMutableString alloc] initWithString:@""];
    while (true) {
        uint8_t byte;
        long len = [_inputStream read:&byte maxLength:1];
        
        if (len > 0) {
            if (byte == '\n') {
                return line;
            }
            else {
                [line appendFormat:@"%c", byte];
            }
        }
        else {
            // TODO: throw exception
        }
    }
    return line;
}

- (NSData *) readBlock:(int)length {
    NSMutableData *block = [[NSMutableData alloc] init];
    long bytesRead = 0;
    uint8_t buf[length];
    long len = 0;
    do {
        len = [_inputStream read:buf maxLength:length - bytesRead];
        if (len > 0) {
            bytesRead += len;
            [block appendBytes:buf length:len];
        }
        else {
            // TODO: throw exception
        }
        
    } while (bytesRead != length);
    
    return block;
}

- (void) write:(NSData *)data {
    long dataLength = [data length];
    int dataWritten = 0;
    uint8_t buf[dataLength];
    do {
        NSRange range = NSMakeRange(dataWritten, dataLength - dataWritten);
        [data getBytes:buf range:range];
        long len = [_outputStream write:buf maxLength:dataLength - dataWritten];
        if (len > 0) {
            dataWritten += len;
        }
        else {
            // TODO: throw exception
        }
    }
    while (dataWritten != dataLength);
}

- (void) checkConnected {
    
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	switch (streamEvent) {
		case NSStreamEventOpenCompleted:
			NSLog(@"***************Stream opened*************************");
            if ([theStream isKindOfClass:[NSInputStream class]]) {
                dispatch_semaphore_signal(_inputStreamOpened);
            }
            else if ([theStream isKindOfClass:[NSOutputStream class]]) {
                dispatch_semaphore_signal(_outputStreamOpened);
            }
            _connected = YES;
			break;
		case NSStreamEventHasBytesAvailable:
			break;
		case NSStreamEventErrorOccurred:
			NSLog(@"********Can not connect to the host!***********");
            if ([theStream isKindOfClass:[NSInputStream class]]) {
                dispatch_semaphore_signal(_inputStreamOpened);
            }
            else if ([theStream isKindOfClass:[NSOutputStream class]]) {
                dispatch_semaphore_signal(_outputStreamOpened);
            }
            _connected = NO;
			break;
		case NSStreamEventEndEncountered:
            NSLog(@"***************End of Stream*******************");
			break;
		default:
			NSLog(@"**************Unknown event********************");
	}
}

+ (NSThread *) networkThread {
    static NSThread *networkThread = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        networkThread =
        [[NSThread alloc] initWithTarget:self
                                selector:@selector(networkThreadMain:)
                                  object:nil];
        [networkThread start];
    });
    
    return networkThread;
}

+ (void) networkThreadMain:(id)unused {
    do {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    } while (YES);
}

- (void)scheduleInCurrentThread
{
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_inputStream open];
    [_outputStream open];
}

@end
