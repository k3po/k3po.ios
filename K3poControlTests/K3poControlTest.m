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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "K3poControl.h"

@interface K3poControlTest : XCTestCase

@end

@implementation K3poControlTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

// - (void) testConnectDisconnect {
//    K3poController *controller = [[K3poController alloc] initWithURL:[NSURL URLWithString:@"tcp://localhost:11642"]];
//
//    [controller connect];
//    XCTAssertTrue([controller isConnected], @"Failed to connect");
//
//    [controller disconnect];
// }

// - (void) testPrepareCommandAndPreparedEvent {
//    K3poController *controller = [[K3poController alloc] initWithURL:[NSURL URLWithString:@"tcp://localhost:11642"]];
//    [controller connect];
//    XCTAssertTrue([controller isConnected], @"Failed to connect");
//
//    NSArray *scripts = [NSArray arrayWithObjects:@"org/kaazing/specification/ws/framing/echo.binary.payload.length.0/handshake.response.and.frame", nil];
//    K3poPrepareCommand *prepareCommand = [[K3poPrepareCommand alloc] initWithScripts:scripts];
//    [[controller commandDispatcher] writeCommand:prepareCommand];
//
//    K3poEvent *event = [[controller eventManager] readEvent];
//    XCTAssertEqual(PREPARED, [event kind], @"Incorrect event type");
//
//    [controller disconnect];
//}

//- (void) testK3poClient {
//    BOOL success = YES;
//
//    // This can be moved into setup method.
//    K3poClient *k3poClient = [[K3poClient alloc] initWithScriptRoot:@"org/kaazing/specification/ws/opening"];
//
//    @try {
//        [k3poClient prepare:@"connection.established/handshake.response"];
//
//         // Code to initialize WebSocket and connect goes here.
//
//         // XCT assertions generate failures and not exceptions. This means that they cannot be caught using
//         // @catch. Also, XCTest does not offer any other mechanism to figure out whether there was any failure
//         // while executing Client library calls. Till XCTest becomes more extensible, we will have to live with
//         // this workaround. This will allow us to pass either YES or NO into K3poClient's finish selector.
//    }
//    @catch (NSException *ex) {
//        success = NO;
//    }
//    @finally {
//        [k3poClient finish:success];
//    }
//}


@end
