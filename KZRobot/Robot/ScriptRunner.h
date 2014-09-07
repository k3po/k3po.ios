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

- (id) initWithName:(NSString *)name;

- (void) start;

- (void) join;

- (NSString *) observedScript;

- (NSString *) expectedScript;

@end
