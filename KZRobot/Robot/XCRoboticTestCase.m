//
//  XCRoboticTestCase.m
//  KMStompJMS
//
//  Created by pkhanal on 7/29/14.
//
//

#import "XCRoboticTestCase.h"
#import "ScriptRunner.h"


NSString *const SCRIPT_EXTENSION = @".rpt";

@implementation XCRoboticTestCase {
    ScriptRunner *_scriptRunner;
    NSString *_scriptRoot;
}

- (void) initializeScriptRoot {
    _scriptRoot = nil;
}

- (id) init {
    self = [super init];
    if (self) {
        [self initializeScriptRoot];
    }
    return self;
}

- (void) prepare:(NSString *)script {
    
    if ([script hasSuffix:SCRIPT_EXTENSION]) {
        script = [script stringByDeletingPathExtension];
    }
    
    NSString *scriptName = @"";
    if (_scriptRoot == nil) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        scriptName = [bundle pathForResource:script ofType:@"rpt"];
    }
    else {
        scriptName = [NSString stringWithFormat:@"%@/%@", _scriptRoot, script];
    }
    
    _scriptRunner = [[ScriptRunner alloc] initWithName:scriptName];
    [_scriptRunner start];
}

- (void) join {
    [_scriptRunner join];
    NSString *expectedScript = [_scriptRunner expectedScript];
    NSString *observedScript = [_scriptRunner observedScript];
    XCTAssertTrue([expectedScript isEqualToString:observedScript], @"Robotic behavior did not match expected");
}

@end
