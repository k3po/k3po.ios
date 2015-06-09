/**
 * Copyright (c) 2007-2015 Kaazing Corporation. All rights reserved.
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
#import "K3poController.h"


@implementation K3poController {
    K3poCommandDispatcher  *_commandDispatcher;
    K3poEventManager       *_eventManager;
    NSString               *_host;
    int                     _port;
    CFReadStreamRef         _readStream;
    CFWriteStreamRef        _writeStream;
    NSInputStream          *_inputStream;
    NSOutputStream         *_outputStream;
    
    dispatch_semaphore_t    _inputStreamOpened;
    dispatch_semaphore_t    _outputStreamOpened;
    BOOL                    _connected;
}

- (id) initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _host = url.host;
        _port = [url.port intValue];
        _commandDispatcher = [[K3poCommandDispatcher alloc] initWithController:self];
        _eventManager = [[K3poEventManager alloc] initWithController:self];
        
        _inputStreamOpened = dispatch_semaphore_create(0);
        _outputStreamOpened = dispatch_semaphore_create(0);
        
        _connected = NO;
    }
    return self;
}

- (void) dealloc {
    _commandDispatcher = nil;
    _eventManager = nil;
    [self disconnect];
}

- (K3poCommandDispatcher *) commandDispatcher {
    return _commandDispatcher;
}

- (K3poEventManager *) eventManager {
    return _eventManager;
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
    
    // Wait for streams to open.
    dispatch_semaphore_wait(_inputStreamOpened, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(_outputStreamOpened, DISPATCH_TIME_FOREVER);
    
    if (!_connected) {
        [NSException raise:@"SocketException" format:@"Cannot connect to %@:%d. Is K3PO Server running?", _host, _port];
    }
}

- (BOOL) isConnected {
    return _connected;
}

- (void) disconnect {
    _connected = NO;
    
    if (_readStream != nil) {
        [_inputStream close];
        [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream setDelegate:nil];
        _inputStream = nil;
        
        CFReadStreamClose(_readStream);
        CFRelease(_readStream);
        _readStream = nil;
    }
    
    if (_writeStream != nil) {
        [_outputStream close];
        [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_outputStream setDelegate:nil];
        _outputStream = nil;
        
        CFWriteStreamClose(_writeStream);
        CFRelease(_writeStream);
        _writeStream = nil;
    }
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

- (void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    switch (streamEvent) {
        case NSStreamEventOpenCompleted:
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
            if ([theStream isKindOfClass:[NSInputStream class]]) {
                dispatch_semaphore_signal(_inputStreamOpened);
            }
            else if ([theStream isKindOfClass:[NSOutputStream class]]) {
                dispatch_semaphore_signal(_outputStreamOpened);
            }
            _connected = NO;
            break;
        case NSStreamEventEndEncountered:
            break;
        default:;
            
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

- (void) scheduleInCurrentThread
{
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_inputStream open];
    [_outputStream open];
}

@end
