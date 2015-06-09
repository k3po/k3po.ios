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
#import "K3poClient.h"
#import "K3poController.h"
#import "K3poCommandDispatcher.h"
#import "K3poEventManager.h"
#import "K3poCommand.h"
#import "K3poAbortCommand.h"
#import "K3poStartCommand.h"
#import "K3poPrepareCommand.h"
#import "K3poEvent.h"
#import "K3poErrorEvent.h"
#import "K3poFinishedEvent.h"
#import "K3poPreparedEvent.h"
#import "K3poStartedEvent.h"

@implementation K3poClient {
    K3poController            *_controller;
    NSString                  *_scriptRoot;
    dispatch_semaphore_t      _preparedSemaphore;
    dispatch_semaphore_t      _startableSemaphore;
    dispatch_semaphore_t      _finishedSemaphore;

    volatile K3poAbortStatus  _abortStatus;
    volatile NSString        *_expectedScript;
    volatile NSString        *_observedScript;
    volatile NSException     *_exception;
    volatile BOOL             _prepared;
}

- (id) init {
    NSException *exception = [NSException exceptionWithName:@"InvalidConstructor"
                                                     reason:@"Use initWithScriptRoot:scriptRoot constructor"
                                                   userInfo:nil];
    @throw exception;
}

- (id) initWithScriptRoot:(NSString *)scriptRoot {
    self = [super init];
    _controller = [[K3poController alloc] initWithURL:[NSURL URLWithString:@"tcp://localhost:11642"]];
    [_controller connect];
    
    _scriptRoot = (scriptRoot == nil ? @"" : scriptRoot);
    
    int length = [_scriptRoot length];
    if ((length > 0) && ([_scriptRoot characterAtIndex:length - 1] == '/')) {
        // Remove the trailing forward-slash.
        _scriptRoot = [_scriptRoot substringToIndex:length - 1];
    }

    _abortStatus = NONE;
    _prepared = NO;
    _startableSemaphore = dispatch_semaphore_create(0);
    _finishedSemaphore = dispatch_semaphore_create(0);
    
    return self;
}


- (void) dealloc {
    if (_controller != nil) {
        [_controller disconnect];
    }
    
    _controller = nil;
}

- (void) prepare:(NSString *)script {
    if ((_controller == nil) || ![_controller isConnected]) {
        NSException *exception = [NSException exceptionWithName:@"IllegalStateException"
                                                         reason:@"Not connected to K3PO.  Was '[K3poScripter start]' invoked?"
                                                       userInfo:nil];
        @throw exception;
    }
    
    if ((script == nil) || ([script length] == 0)) {
        NSException *exception = [NSException exceptionWithName:@"IllegalArgumentException"
                                                         reason:@"'script' cannot be nil or an empty string"
                                                       userInfo:nil];
        @throw exception;
    }

    NSString *absoluteScriptPath = [[NSString alloc] initWithFormat:@"%@/%@", _scriptRoot, script];
    _preparedSemaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                        @autoreleasepool {
                            [self handleEvents:absoluteScriptPath];
                        }
                    }
                   );

    // Wait for the PREPARED event to be received before letting the test continue.
    dispatch_semaphore_wait(_preparedSemaphore, DISPATCH_TIME_FOREVER);
    _preparedSemaphore = nil;

    if (_exception != nil) {
        @throw _exception;
    }
    
    _prepared = YES;
}

- (void) finish:(BOOL)success {
    if ((_controller == nil) || ![_controller isConnected]) {
        return;
    }

    if (!_prepared) {
        if ([_controller isConnected]) {
            [_controller disconnect];
            return;
        }
    }

    if (!success) {
        [self abort];
    }

    dispatch_semaphore_signal(_startableSemaphore);
    dispatch_semaphore_wait(_finishedSemaphore, DISPATCH_TIME_FOREVER);
    
    if (_exception != nil) {
        @throw _exception;
    }
    
    BOOL match = [_expectedScript isEqualToString:(NSString *)_observedScript];
    if (!match) {
        NSLog(@"############## Expected Script #################");
        NSLog(@"%@", _expectedScript);
        NSLog(@"################################################");

        NSLog(@"************** Observed Script *****************");
        NSLog(@"%@", _observedScript);
        NSLog(@"************************************************");
        
    }
    
    NSAssert(match, @"Expected script and observed script did not match");
}

- (NSString *) expectedScript {
    return (NSString *) _expectedScript;
}

- (NSString *) observedScript {
    return (NSString *) _observedScript;
}

#pragma Private Methods

- (void) abort {
    if (_abortStatus == NONE) {
        _abortStatus = SCHEDULED;
    }
}

- (void) handleEvents:(id)data {
    @autoreleasepool {
        @try {
            NSString *script = (NSString *) data;
            NSArray  *scripts = [NSArray arrayWithObjects:script, nil];
            K3poPrepareCommand *prepareCommand = [[K3poPrepareCommand alloc] initWithScripts:scripts];
            [[_controller commandDispatcher] writeCommand:prepareCommand];
            
            while (YES) {
                @try {
                    K3poEvent *event = [[_controller eventManager] readEvent];
                    
                    switch ([event kind]) {
                        case ERROR:
                        {
                            K3poErrorEvent  *errorEvent = (K3poErrorEvent *) event;
                            NSString    *summary = [errorEvent summary];
                            NSString    *description = [errorEvent description];
                            NSException *exception = [NSException exceptionWithName:summary
                                                                             reason:description
                                                                           userInfo:nil];
                            _exception = exception;
                            dispatch_semaphore_signal(_preparedSemaphore);
                            return;
                        }
                        case FINISHED:
                        {
                            K3poFinishedEvent *finishedEvent = (K3poFinishedEvent *) event;
                            _observedScript = [finishedEvent script];
                            dispatch_semaphore_signal(_finishedSemaphore);
                            return;
                        }
                        case PREPARED:
                        {
                            K3poPreparedEvent *preparedEvent = (K3poPreparedEvent *) event;
                            _expectedScript = [preparedEvent script];
                            

                            dispatch_semaphore_signal(_preparedSemaphore);
                            dispatch_semaphore_wait(_startableSemaphore, DISPATCH_TIME_FOREVER);

                            if (_abortStatus == SCHEDULED) {
                                [self sendAbort];
                            }
                            else {
                                [self sendStart];
                            }
                            break;
                        }
                        case STARTED:
                            break;
                        default:
                        {
                            NSException *exception = [NSException exceptionWithName:@"IllegalStateException"
                                                                             reason:@"Invalid event"
                                                                           userInfo:nil];
                            _exception = exception;
                            dispatch_semaphore_signal(_preparedSemaphore);
                            return;
                        }
                    }
                }
                @catch (NSException *ex) {
                    if (_abortStatus == SCHEDULED) {
                        [self sendAbort];
                    }

                    _exception = ex;
                    return;
                }
            }
        }
        @catch (NSException *ex) {
            _exception = ex;
        }
        @finally {
            [_controller disconnect];
            _controller = nil;
        }
    }
}

- (void) sendAbort {
    if (_abortStatus == SCHEDULED) {
        K3poAbortCommand *abortCommand = [[K3poAbortCommand alloc] init];
        [[_controller commandDispatcher] writeCommand:abortCommand];
        _abortStatus = ABORTED;
    }
}

- (void) sendStart {
    K3poStartCommand *startCommand = [[K3poStartCommand alloc] init];
    [[_controller commandDispatcher] writeCommand:startCommand];
}

@end
