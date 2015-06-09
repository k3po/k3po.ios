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
#import <Foundation/Foundation.h>
#import "K3poCommandDispatcher.h"
#import "K3poEventManager.h"

@interface K3poController : NSObject<NSStreamDelegate>

- (id) initWithURL:(NSURL *)url;

- (K3poCommandDispatcher *) commandDispatcher;

- (K3poEventManager *) eventManager;

- (void) connect;

- (BOOL) isConnected;

- (void) disconnect;

- (NSData *) readBlock:(int)length;

- (NSString *) readLine;

- (void) write:(NSData *)data;

@end
