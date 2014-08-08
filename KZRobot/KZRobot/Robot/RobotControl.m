//
//  RobotControl.m
//  KMStompJMS
//
//  Created by pkhanal on 7/29/14.
//
//

#import "RobotControl.h"
#import "PreparedEvent.h"
#import "StartedEvent.h"
#import "ErrorEvent.h"
#import "FinishedEvent.h"
#import "StartCommand.h"
#import "PrepareCommand.h"
#import "AbortCommand.h"

NSString *const HEADER_PATTERN = @"([a-z\\-]+):([^\n]+)";

@implementation RobotControl

static NSRegularExpression* regex;

+ (void)initialize {
    regex= [NSRegularExpression regularExpressionWithPattern:HEADER_PATTERN options:0 error:nil];
}

- (void) writeCommand:(Command *)command {
    
    switch ([command kind]) {
        case PREPARE:
            [self writePrepareCommand:(PrepareCommand *)command];
            break;
        case START:
            [self writeStartCommand:(StartCommand *)command];
            break;
        case ABORT:
            [self writeAbortCommand:(AbortCommand *)command];
            break;
            
        default:
        {
            NSException *exception = [NSException exceptionWithName:@"IllegalStateException"
                                                             reason:[NSString stringWithFormat:@"Invalid command: %d", [command kind]]
                                                           userInfo:nil];
            @throw exception;
        }
    }
    
}

- (CommandEvent *) readEvent {
    NSString *eventKind = [self readLine];
    NSLog(@"Inbound Event: %@", eventKind);
    unichar event = [eventKind characterAtIndex:0];
    switch (event) {
        case 'P':
            if ([eventKind isEqualToString:@"PREPARED"]) {
                return [self readPreparedEvent];
            }
            break;
        case 'S':
            if ([eventKind isEqualToString:@"STARTED"]) {
                return [self readStartedEvent];
            }
            break;
        case 'E':
            if ([eventKind isEqualToString:@"ERROR"]) {
                return [self readErrorEvent];
            }
            break;
        case 'F':
            if ([eventKind isEqualToString:@"FINISHED"]) {
                return [self readFinishedEvent];
            }
            break;
    }
    
    NSException *exception = [NSException exceptionWithName:@"IllegalStateException"
                                                     reason:[NSString stringWithFormat:@"Invalid Event: %@", eventKind]
                                                   userInfo:nil];
    @throw exception;
}

//------------Private Methods-------------------------//

- (void) writePrepareCommand:(PrepareCommand *)prepareCommand {
    NSMutableString *commandString = [[NSMutableString alloc] initWithString:@"PREPARE\n"];
    [commandString appendFormat:@"name:%@\n", [prepareCommand name]];
    [commandString appendFormat:@"content-length:%lu\n", (unsigned long)[[prepareCommand script] length]];
    [commandString appendString:@"\n"];
    [commandString appendString:[prepareCommand script]];
    [self write:[commandString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) writeStartCommand:(StartCommand *)startCommand {
    NSMutableString *commandString = [[NSMutableString alloc] initWithString:@"START\n"];
    [commandString appendFormat:@"name:%@\n", [startCommand name]];
    [commandString appendString:@"\n"];
    [self write:[commandString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) writeAbortCommand:(AbortCommand *)abortCommand {
    NSMutableString *commandString = [[NSMutableString alloc] initWithString:@"ABORT\n"];
    [commandString appendFormat:@"name:%@\n", [abortCommand name]];
    [commandString appendString:@"\n"];
    [self write:[commandString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (PreparedEvent *) readPreparedEvent {
    PreparedEvent *event = [[PreparedEvent alloc] init];
    NSString *header;
    do {
        header = [self readLine];
        NSRange   range = NSMakeRange(0, [header length]);
        NSTextCheckingResult *match = [regex firstMatchInString:header options:0 range: range];
        if (match) {
            NSString *headerName = [header substringWithRange:[match rangeAtIndex:1]];
            NSString *value = [header substringWithRange:[match rangeAtIndex:2]];
            if ([headerName isEqualToString:@"name"]) {
                [event setName:value];
            }
            else {
                // TODO: throw exception
            }
        }
        
    }while (![header isEqualToString:@""]);
    return event;
}

- (StartedEvent *) readStartedEvent {
    StartedEvent *event = [[StartedEvent alloc] init];
    NSString *header;
    do {
        header = [self readLine];
        NSRange   range = NSMakeRange(0, [header length]);
        NSTextCheckingResult *match = [regex firstMatchInString:header options:0 range: range];
        if (match) {
            NSString *headerName = [header substringWithRange:[match rangeAtIndex:1]];
            NSString *value = [header substringWithRange:[match rangeAtIndex:2]];
            if ([headerName isEqualToString:@"name"]) {
                [event setName:value];
            }
            else {
                // TODO: throw exception
            }
        }
        
    }while (![header isEqualToString:@""]);
    return event;

}

- (ErrorEvent *) readErrorEvent {
    ErrorEvent *event = [[ErrorEvent alloc] init];
    NSString *header;
    int length = 0;
    do {
        header = [self readLine];
        NSRange   range = NSMakeRange(0, [header length]);
        NSTextCheckingResult *match = [regex firstMatchInString:header options:0 range: range];
        if (match) {
            NSString *headerName = [header substringWithRange:[match rangeAtIndex:1]];
            NSString *value = [header substringWithRange:[match rangeAtIndex:2]];
            if ([headerName isEqualToString:@"name"]) {
                [event setName:value];
            }
            else if ([headerName isEqualToString:@"content-length"]) {
                length = [value intValue];
            }
            else if ([headerName isEqualToString:@"summary"]) {
                [event setSummary:value];
            }
            else {
                // TODO: throw exception
            }
        }
        
    }while (![header isEqualToString:@""]);
    
    if (length > 0) {
        NSData *content = [self readBlock:length];
        [event setDescription:[[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding]];
    }
    
    return event;

}

- (FinishedEvent *) readFinishedEvent {
    FinishedEvent *event = [[FinishedEvent alloc] init];
    NSString *header;
    int length = 0;
    do {
        header = [self readLine];
        NSRange   range = NSMakeRange(0, [header length]);
        NSTextCheckingResult *match = [regex firstMatchInString:header options:0 range: range];
        if (match) {
            NSString *headerName = [header substringWithRange:[match rangeAtIndex:1]];
            NSString *value = [header substringWithRange:[match rangeAtIndex:2]];
            if ([headerName isEqualToString:@"name"]) {
                [event setName:value];
            }
            else if ([headerName isEqualToString:@"content-length"]) {
                length = [value intValue];
            }
            else {
                // TODO: throw exception
            }
        }
        
    }while (![header isEqualToString:@""]);
    
    if (length > 0) {
        NSData *content = [self readBlock:length];
        [event setScript:[[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding]];
    }
    
    return event;

}


//-------------- Abstract Methods----------------//

- (void) connect {
    NSException *exception = [NSException exceptionWithName:@"InvalidOperationException"
                                                     reason:@"Abstract method"
                                                   userInfo:nil];
    @throw exception;
}

- (void) disconnect {
    NSException *exception = [NSException exceptionWithName:@"InvalidOperationException"
                                                     reason:@"Abstract method"
                                                   userInfo:nil];
    @throw exception;
}

- (NSString *) readLine {
    NSException *exception = [NSException exceptionWithName:@"InvalidOperationException"
                                                     reason:@"Abstract method"
                                                   userInfo:nil];
    @throw exception;
}

- (NSData *) readBlock:(int)length {
    NSException *exception = [NSException exceptionWithName:@"InvalidOperationException"
                                                     reason:@"Abstract method"
                                                   userInfo:nil];
    @throw exception;
}

- (void) write:(NSData *)data {
    NSException *exception = [NSException exceptionWithName:@"InvalidOperationException"
                                                     reason:@"Abstract method"
                                                   userInfo:nil];
    @throw exception;
}

- (void) checkConnected {
    NSException *exception = [NSException exceptionWithName:@"InvalidOperationException"
                                                     reason:@"Abstract method"
                                                   userInfo:nil];
    @throw exception;
}

@end
