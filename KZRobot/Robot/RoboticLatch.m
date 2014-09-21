//
//  RoboticLatch.m
//  KMStompJMS
//
//  Created by pkhanal on 7/29/14.
//
//

#import "RoboticLatch.h"

typedef enum {
    INIT,
    PREPARED,
    STARTABLE,
    FINISHED
} State;

@implementation RoboticLatch {
    dispatch_semaphore_t _prepared;
    dispatch_semaphore_t _startable;
    dispatch_semaphore_t _finished;

    NSException *_exception;
    
    volatile State _state;
}

- (id) init {
    self = [super init];
    if (self) {
        _state = INIT;
        _prepared = dispatch_semaphore_create(0);
        _startable = dispatch_semaphore_create(0);
        _finished = dispatch_semaphore_create(0);
    }
    return self;
}

- (void) notifyPrepared {
    switch (_state) {
        case INIT:
            _state = PREPARED;
            dispatch_semaphore_signal(_prepared);
            break;
            
        default:
            // TODO: throw exception
            break;
    }
}

- (void) awaitPrepared {
    dispatch_semaphore_wait(_prepared, DISPATCH_TIME_FOREVER);
    if (_exception != nil) {
        @throw _exception;
    }
}

- (void) notifyStartable {
    switch (_state) {
        case PREPARED:
            _state = STARTABLE;
            dispatch_semaphore_signal(_startable);
            break;
            
        default:
            // TODO: throw exception
            break;
    }
}

- (void) awaitStartable {
    dispatch_semaphore_wait(_startable, DISPATCH_TIME_FOREVER);
    if (_exception != nil) {
        @throw _exception;
    }
}

- (void) notifyFinished {
    switch (_state) {
        case STARTABLE:
            _state = FINISHED;
            dispatch_semaphore_signal(_finished);
            break;
            
        default:
            // TODO: throw exception
            break;
    }
}

- (void) awaitFinished {
    dispatch_semaphore_wait(_finished, DISPATCH_TIME_FOREVER);
    if (_exception != nil) {
        @throw _exception;
    }
}

- (void) awaitFinishedWithTimeout:(int)timeout {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, timeout * 1000000000);
    long timedOut = dispatch_semaphore_wait(_finished, time);
    if (timedOut != 0) {
        [NSException raise:@"Timeout" format:@"Could not receive FINISH event in %d seconds", timeout];
    }
    if (_exception != nil) {
        @throw _exception;
    }
    
}

- (void) notifyException:(NSException *)exception {
    _exception = exception;
    dispatch_semaphore_signal(_prepared);
    dispatch_semaphore_signal(_startable);
    dispatch_semaphore_signal(_finished);
}


@end
