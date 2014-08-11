//
//  XCRoboticTestCase.m
//  KMStompJMS
//
//  Created by pkhanal on 7/29/14.
//
//

#import "XCRoboticTestCase.h"
#import "ScriptRunner.h"
#import "RoboticLatch.h"

@implementation XCRoboticTestCase {
    RoboticLatch *_latch;
    ScriptRunner *_scriptRunner;
}

- (void) prepare:(NSString *)script {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *dataFile = [bundle pathForResource:script ofType:@"rpt"];
    NSString *expectedScript = [NSString stringWithContentsOfFile:dataFile encoding:NSUTF8StringEncoding error:nil];
    
    _latch = [[RoboticLatch alloc] init];
    _scriptRunner = [[ScriptRunner alloc] initWithName:script expectedScript:expectedScript latch:_latch];
    [_scriptRunner start];
    [_latch awaitStartable];
}

- (void) join {
    [_latch awaitFinished];
    NSString *expectedScript = [_scriptRunner expectedScript];
    NSString *observedScript = [_scriptRunner observedScript];
    XCTAssertTrue([expectedScript isEqualToString:observedScript], @"Robotic behavior did not match expected");
}

@end
