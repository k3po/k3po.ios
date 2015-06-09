//
//  K3poControlTests.m
//  K3poControlTests
//
//  Created by Sanjay Saxena on 6/2/15.
//  Copyright (c) 2015 Sanjay Saxena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "K3poController.h"
#import "PrepareCommand.h"
#import "PreparedEvent.h"
#import "StartCommand.h"
#import "StartedEvent.h"

@interface K3poControlTests : XCTestCase

@end

@implementation K3poControlTests

- (void) setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void) testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

// - (void) testConnectDisconnect {
//    K3poController *controller = [[K3poController alloc] initWithHost:@"localhost" port:11642];
//    [controller connect];
//    XCTAssertTrue([controller isConnected], @"Failed to connect");
//
//    [controller disconnect];
// }

// - (void) testPrepareCommandAndPreparedEvent {
//    K3poController *controller = [[K3poController alloc] initWithHost:@"localhost" port:11642];
//    [controller connect];
//    XCTAssertTrue([controller isConnected], @"Failed to connect");
//
//    NSArray *scripts = [NSArray arrayWithObjects:@"org/kaazing/specification/ws/framing/echo.binary.payload.length.0/handshake.response.and.frame", nil];
//    PrepareCommand *prepareCommand = [[PrepareCommand alloc] init];
//    [prepareCommand setScripts:scripts];
//    [[controller commandDispatcher] writeCommand:prepareCommand];
//
//    Event *event = [[controller eventManager] readEvent];
//    XCTAssertEqual(PREPARED, [event kind], @"Incorrect event type");
//
//    [controller disconnect];
//}

@end
