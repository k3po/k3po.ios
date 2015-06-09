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
#import "K3poEventManager.h"
#import "K3poController.h"
#import "K3poErrorEvent.h"
#import "K3poFinishedEvent.h"
#import "K3poPreparedEvent.h"
#import "K3poStartedEvent.h"

NSString *const HEADER_PATTERN = @"([a-z\\-]+):([^\n]+)";

@implementation K3poEventManager {
    K3poController *_control;
}

static NSRegularExpression* regex;

+ (void)initialize {
    regex= [NSRegularExpression regularExpressionWithPattern:HEADER_PATTERN options:0 error:nil];
}

- (id) initWithController:(K3poController *)controller {
    self = [super init];
    _control = (K3poController* )controller;
    return self;
}

- (void) dealloc {
    _control = nil;
}

- (K3poEvent *) readEvent {
    NSString *eventKind = [_control readLine];
    NSLog(@"Inbound Event: %@", eventKind);
    unichar event = [eventKind characterAtIndex:0];
    switch (event) {
        case 'P':
            if ([eventKind isEqualToString:@"PREPARED"]) {
                return [self readPreparedEvent];
            }
            break;
        case 'S':
            if ([eventKind isEqualToString:@"STARTED"]) {
                return [self readStartedEvent];
            }
            break;
        case 'E':
            if ([eventKind isEqualToString:@"ERROR"]) {
                return [self readErrorEvent];
            }
            break;
        case 'F':
            if ([eventKind isEqualToString:@"FINISHED"]) {
                return [self readFinishedEvent];
            }
            break;
    }
    
    NSException *exception = [NSException exceptionWithName:@"IllegalStateException"
                                                     reason:[NSString stringWithFormat:@"Invalid Event: %@", eventKind]
                                                   userInfo:nil];
    @throw exception;
}

- (K3poErrorEvent *) readErrorEvent {
    K3poErrorEvent *event = [[K3poErrorEvent alloc] init];
    NSString *header;
    int length = 0;
    do {
        header = [_control readLine];
        NSRange   range = NSMakeRange(0, [header length]);
        NSTextCheckingResult *match = [regex firstMatchInString:header options:0 range: range];
        if (match) {
            NSString *headerName = [header substringWithRange:[match rangeAtIndex:1]];
            NSString *value = [header substringWithRange:[match rangeAtIndex:2]];
            if ([headerName isEqualToString:@"name"]) {
                //                [event setName:value];
            }
            else if ([headerName isEqualToString:@"content-length"]) {
                length = [value intValue];
            }
            else if ([headerName isEqualToString:@"summary"]) {
                [event setSummary:value];
            }
            else {
                [NSException raise:NSInvalidArgumentException format:@"Unrecognized event header:%@", headerName];
            }
        }
        
    } while (![header isEqualToString:@""]);
    
    if (length > 0) {
        NSData *content = [_control readBlock:length];
        [event setDescription:[[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding]];
    }
    
    return event;
}

- (K3poFinishedEvent *) readFinishedEvent {
    K3poFinishedEvent *event = [[K3poFinishedEvent alloc] init];
    NSString *header;
    int length = -1;
    
    do {
        header = [_control readLine];
        NSRange   range = NSMakeRange(0, [header length]);
        NSTextCheckingResult *match = [regex firstMatchInString:header options:0 range: range];
        if (match) {
            NSString *headerName = [header substringWithRange:[match rangeAtIndex:1]];
            NSString *headerValue = [header substringWithRange:[match rangeAtIndex:2]];
            if ([headerName isEqualToString:@"name"]) {
                // [event setName:value];
            }
            else if ([headerName isEqualToString:@"content-length"]) {
                length = [headerValue intValue];
            }
            else {
                [NSException raise:NSInvalidArgumentException format:@"Unrecognized event header:%@", headerName];
            }
        }
        
    } while (![header isEqualToString:@""]);
    
    if (length > 0) {
        NSData *content = [_control readBlock:length];
        [event setScript:[[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding]];
    }
    
    return event;
}

- (K3poPreparedEvent *) readPreparedEvent {
    K3poPreparedEvent *event = [[K3poPreparedEvent alloc] init];
    NSString *header;
    int length = -1;
    
    do {
        header = [_control readLine];
        NSRange   range = NSMakeRange(0, [header length]);
        NSTextCheckingResult *match = [regex firstMatchInString:header options:0 range: range];
        if (match) {
            NSString *headerName = [header substringWithRange:[match rangeAtIndex:1]];
            NSString *headerValue = [header substringWithRange:[match rangeAtIndex:2]];
            if ([headerName isEqualToString:@"name"]) {
                // [event setName:value];
            }
            else if ([headerName isEqualToString:@"content-length"]) {
                length = [headerValue intValue];
            }
            else {
                [NSException raise:NSInvalidArgumentException format:@"Unrecognized event header:%@", headerName];
            }
        }
        
    } while (![header isEqualToString:@""]);
    
    if (length > 0) {
        NSData *content = [_control readBlock:length];
        [event setScript:[[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding]];
    }
    
    return event;
}

- (K3poStartedEvent *) readStartedEvent {
    K3poStartedEvent *event = [[K3poStartedEvent alloc] init];
    NSString *header;
    
    do {
        header = [_control readLine];
        
        NSRange               range = NSMakeRange(0, [header length]);
        NSTextCheckingResult *match = [regex firstMatchInString:header options:0 range: range];
        
        if (match) {
            NSString *headerName = [header substringWithRange:[match rangeAtIndex:1]];
            NSString *headerValue = [header substringWithRange:[match rangeAtIndex:2]];
            if ([headerName isEqualToString:@"name"]) {
                // [event setName:headerValue];
            }
            else {
                NSException *exception = [NSException exceptionWithName:@"IllegalStateException"
                                                                 reason:[NSString stringWithFormat:@"Invalid header: '%@'", headerName]
                                                               userInfo:nil];
                @throw exception;
            }
        }
        
    } while (![header isEqualToString:@""]);
    
    return event;
}

@end
