//
//  FinishedEvent.m
//  KMStompJMS
//
//  Created by pkhanal on 7/30/14.
//
//

#import "FinishedEvent.h"

@implementation FinishedEvent {
    NSString *_script;
}

- (EventKind) kind {
    return FINISHED;
}

- (void) setScript:(NSString *)script {
    _script = script;
}

- (NSString *) script {
    return _script;
}

@end