//
//  RobotControlFactory.m
//  KMStompJMS
//
//  Created by pkhanal on 7/29/14.
//
//

#import "RobotControlFactory.h"
#import "TcpRobotControl.h"

@implementation RobotControlFactory

- (RobotControl *) newClient:(NSURL *)url {
    NSString *scheme = [url scheme];
    
    if ([scheme isEqualToString:@"tcp"]) {
        return [[TcpRobotControl alloc] initWithHost:[url host] port:[[url port] intValue]];
    }
    
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"'%@' scheme is not supported", scheme]
                                 userInfo:nil];
}

@end
