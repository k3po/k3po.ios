//
//  RobotControlFactory.h
//  KMStompJMS
//
//  Created by pkhanal on 7/29/14.
//
//

#import "RobotControl.h"

@interface RobotControlFactory : NSObject

- (RobotControl *) newClient:(NSURL *)url;

@end
