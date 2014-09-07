//
//  ScriptRunner.m
//  KMStompJMS
//
//  Created by pkhanal on 7/30/14.
//
//

#import "ScriptRunner.h"
#import "RobotControlFactory.h"
#import "PrepareCommand.h"
#import "StartCommand.h"
#import "CommandEvent.h"
#import "FinishedEvent.h"
#import "AbortCommand.h"
#import "ErrorEvent.h"

@implementation ScriptRunner {
    NSString *_name;
    NSString *_expectedScript;
    RoboticLatch *_latch;
    
    RobotControlFactory *_controlFactory;
    RobotControl *_control;
    NSString *_observedScript;
}

- (id) initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        _latch = [[RoboticLatch alloc] init];
        
        _controlFactory = [[RobotControlFactory alloc] init];
        NSURL *controlUrl = [[NSURL alloc] initWithString:@"tcp://localhost:11642"];
        _control = [_controlFactory newClient:controlUrl];
    }
    return self;
}

- (void) start {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            [_control connect];
            
            // send PREPARE command
            PrepareCommand *prepareCommand = [[PrepareCommand alloc] init];
            [prepareCommand setName:_name];
            [_control writeCommand:prepareCommand];
            
            while (true) {
                CommandEvent *event = [_control readEvent];
                switch ([event kind]) {
                    case PREPARED:
                    {
                        [_latch notifyPrepared];
                        StartCommand *startCommand = [[StartCommand alloc] init];
                        [startCommand setName:_name];
                        [_control writeCommand:startCommand];
                        break;
                    }
                    case STARTED:
                    {
                        [_latch notifyStartable];
                        break;
                    }
                    case ERROR:
                    {
                        ErrorEvent *errorEvent = (ErrorEvent *)event;
                        NSString *errorMessage = [NSString stringWithFormat:@"%@:%@", [errorEvent summary], [errorEvent description]];
                        NSException *exception = [[NSException alloc] initWithName:@"RoboticException" reason:errorMessage userInfo:nil];
                        [_latch notifyException:exception];
                        break;
                    }
                    case FINISHED:
                    {
                        FinishedEvent *finishedEvent = (FinishedEvent *)event;
                        _observedScript = [finishedEvent observedScript];
                        _expectedScript = [finishedEvent expectedScript];
                        [_latch notifyFinished];
                        break;
                    }
                    default:
                    {
                        NSString *errorMessage = [NSString stringWithFormat:@"Invalid event: %u", [event kind]];
                        NSException *exception = [[NSException alloc] initWithName:NSInvalidArgumentException reason:errorMessage userInfo:nil];
                        [_latch notifyException:exception];
                        break;
                    }
                }
            }
        }
        @catch (NSException *exception) {
            [_latch notifyException:exception];
        }
        @finally {
            [_control disconnect];
        }
        
    });
    
    [_latch awaitStartable];
}

- (void) join {
    @try {
        [_latch awaitFinishedWithTimeout:5];
    }
    @catch(NSException *ex) {
        if ([ex.name isEqualToString:@"Timeout"]) {
            [self sendAbortCommand];
        }
    }
    
}

- (NSString *) observedScript {
    return _observedScript;
}

- (NSString *) expectedScript {
    return _expectedScript;
}

- (void) sendAbortCommand {
    AbortCommand *abortCommand = [[AbortCommand alloc] init];
    [abortCommand setName:_name];
    [_control writeCommand:abortCommand];
}


@end
