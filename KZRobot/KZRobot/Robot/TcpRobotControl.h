//
//  TcpRobotControl.h
//  KMStompJMS
//
//  Created by pkhanal on 7/29/14.
//
//

#import "RobotControl.h"

@interface TcpRobotControl : RobotControl<NSStreamDelegate>

- (id) initWithHost:(NSString *)host port:(int)port;

@end
