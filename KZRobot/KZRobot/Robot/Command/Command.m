//
//  Command.m
//  KMStompJMS
//
//  Created by pkhanal on 7/30/14.
//
//

#import "Command.h"

@implementation Command {
    NSString *_name;
}

- (CommandKind) kind {
    NSException *exception = [NSException exceptionWithName:@"InvalidOperationException"
                                                     reason:@"Abstract method"
                                                   userInfo:nil];
    @throw exception;
}

- (void) setName:(NSString *)name {
    _name = name;
}

- (NSString *) name {
    return _name;
}

@end
