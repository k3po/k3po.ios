//
//  RobotControl.h
//  KMStompJMS
//
//  Created by pkhanal on 7/29/14.
//
//

#import <Foundation/Foundation.h>
#import "Command.h"
#import "CommandEvent.h"

@interface RobotControl : NSObject

- (void) connect;

- (void) disconnect;

- (NSString *) readLine;

- (NSData *) readBlock:(int)length;

- (void) write:(NSData *)data;

- (void) checkConnected;

- (void) writeCommand:(Command *)command;

- (CommandEvent *) readEvent;

@end
