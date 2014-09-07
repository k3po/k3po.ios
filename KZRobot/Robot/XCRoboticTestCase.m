//
//  XCRoboticTestCase.m
//  KMStompJMS
//
//  Created by pkhanal on 7/29/14.
//
//

#import "XCRoboticTestCase.h"
#import "ScriptRunner.h"

@implementation XCRoboticTestCase {
    ScriptRunner *_scriptRunner;
}

- (void) prepare:(NSString *)script {
    _scriptRunner = [[ScriptRunner alloc] initWithName:script];
    [_scriptRunner start];
}

- (void) join {
    [_scriptRunner join];
    NSString *expectedScript = [_scriptRunner expectedScript];
    NSString *observedScript = [_scriptRunner observedScript];
    XCTAssertTrue([expectedScript isEqualToString:observedScript], @"Robotic behavior did not match expected");
}

@end
