//
//  FinishedEvent.h
//  KMStompJMS
//
//  Created by pkhanal on 7/30/14.
//
//

#import "CommandEvent.h"

@interface FinishedEvent : CommandEvent

- (void) setScript:(NSString *)script;

- (NSString *) script;

@end
