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

@implementation ScriptRunner {
    NSString *_name;
    NSString *_expectedScript;
    RoboticLatch *_latch;
    
    RobotControlFactory *_controlFactory;
    RobotControl *_control;
    NSString *_observedScript;
}

- (id) initWithName:(NSString *)name expectedScript:(NSString *)script latch:(RoboticLatch *)latch {
    self = [super init];
    if (self) {
        _name = name;
        _expectedScript = script;
        _latch = latch;
        
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
            [prepareCommand setScript:_expectedScript];
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
                        // TODO: [_latch notifyException];
                        break;
                    case FINISHED:
                    {
                        FinishedEvent *finishedEvent = (FinishedEvent *)event;
                        _observedScript = [finishedEvent script];
                        [_latch notifyFinished];
                        break;
                    }
                    default:
                        // TODO: throw exception
                        break;
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
}

- (void) join {
    [_latch awaitFinished];
}

- (void) abort {
    
}

- (NSString *) observedScript {
    return _observedScript;
}

- (NSString *) expectedScript {
    return _expectedScript;
}


@end
