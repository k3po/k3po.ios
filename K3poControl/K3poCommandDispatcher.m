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
#import "K3poCommandDispatcher.h"
#import "K3poController.h"
#import "K3poAbortCommand.h"
#import "K3poPrepareCommand.h"
#import "K3poStartCommand.h"

@implementation K3poCommandDispatcher {
    K3poController *_controller;
}

- (id) initWithController:(id)controller {
    self = [super init];
    _controller = (K3poController *)controller;
    return self;
}

- (void) dealloc {
    _controller = nil;
}

- (void) writeCommand:(K3poCommand *)command {
    switch ([command kind]) {
        case PREPARE:
            [self writePrepareCommand:(K3poPrepareCommand *)command];
            break;
        case START:
            [self writeStartCommand:(K3poStartCommand *)command];
            break;
        case ABORT:
            [self writeAbortCommand:(K3poAbortCommand *)command];
            break;
            
        default:
        {
            NSException *exception = [NSException exceptionWithName:@"IllegalStateException"
                                                             reason:[NSString stringWithFormat:@"Invalid command: %d", [command kind]]
                                                           userInfo:nil];
            @throw exception;
        }
    }
}

- (void) writeAbortCommand:(K3poAbortCommand *)abortCommand {
    NSLog(@"Outbound Command: ABORT");
    NSMutableString *commandString = [[NSMutableString alloc] initWithString:@"ABORT\n"];
    [commandString appendString:@"\n"];
    [_controller write:[commandString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) writePrepareCommand:(K3poPrepareCommand *)prepareCommand {
    NSLog(@"Outbound Command: PREPARE");
    NSMutableString *commandString = [[NSMutableString alloc] initWithString:@"PREPARE\n"];
    [commandString appendString:@"version:2.0\n"];
    
    NSArray *scripts = [prepareCommand scripts];
    for (NSString *script in scripts) {
        [commandString appendFormat:@"name:%@\n", script];
    }
    
    [commandString appendString:@"\n"];
    [_controller write:[commandString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) writeStartCommand:(K3poStartCommand *)startCommand {
    NSLog(@"Outbound Command: START");
    NSMutableString *commandString = [[NSMutableString alloc] initWithString:@"START\n"];
    [commandString appendString:@"\n"];
    [_controller write:[commandString dataUsingEncoding:NSUTF8StringEncoding]];
}



@end
