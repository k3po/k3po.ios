//
//  ScriptRunner.h
//  KMStompJMS
//
//  Created by pkhanal on 7/30/14.
//
//

#import <Foundation/Foundation.h>
#import "RoboticLatch.h"

@interface ScriptRunner : NSObject

- (id) initWithName:(NSString *)name expectedScript:(NSString *)script latch:(RoboticLatch *)latch;

- (void) start;

- (void) join;

- (void) abort;

- (NSString *) observedScript;

- (NSString *) expectedScript;

@end
