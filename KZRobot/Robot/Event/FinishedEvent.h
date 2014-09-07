//
//  FinishedEvent.h
//  KMStompJMS
//
//  Created by pkhanal on 7/30/14.
//
//

#import "CommandEvent.h"

@interface FinishedEvent : CommandEvent

- (void) setObservedScript:(NSString *)script;

- (NSString *) observedScript;

- (NSString *) expectedScript;

- (void) setExpectedScript:(NSString *)script;

@end
