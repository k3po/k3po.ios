//
//  RoboticLatch.h
//  KMStompJMS
//
//  Created by pkhanal on 7/29/14.
//
//

#import <Foundation/Foundation.h>

@interface RoboticLatch : NSObject

- (void) notifyPrepared;

- (void) awaitPrepared;

- (void) notifyStartable;

- (void) awaitStartable;

- (void) notifyFinished;

- (void) awaitFinished;

// timeoout in seconds
- (void) awaitFinishedWithTimeout:(int)timeout;

- (void) notifyException:(NSException *)exception;

@end
