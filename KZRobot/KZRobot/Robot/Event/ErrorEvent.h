//
//  ErrorEvent.h
//  KMStompJMS
//
//  Created by pkhanal on 7/30/14.
//
//

#import "CommandEvent.h"

@interface ErrorEvent : CommandEvent

- (void) setSummary:(NSString *)summary;

- (NSString *) summary;

- (void) setDescription:(NSString *)description;

- (NSString *) description;

@end
