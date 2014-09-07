//
//  FinishedEvent.m
//  KMStompJMS
//
//  Created by pkhanal on 7/30/14.
//
//

#import "FinishedEvent.h"

@implementation FinishedEvent {
    NSString *_observedScript;
    NSString *_expectedScript;
}

- (EventKind) kind {
    return FINISHED;
}

- (void) setObservedScript:(NSString *)script {
    _observedScript = script;
}

- (NSString *) observedScript {
    return _observedScript;
}

- (void) setExpectedScript:(NSString *)script {
    _expectedScript = script;
}

- (NSString *) expectedScript {
    return _expectedScript;
}

@end