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

- (void) notifyException:(NSException *)exception;

@end
