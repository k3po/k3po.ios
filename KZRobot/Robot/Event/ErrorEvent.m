//
//  ErrorEvent.m
//  KMStompJMS
//
//  Created by pkhanal on 7/30/14.
//
//

#import "ErrorEvent.h"

@implementation ErrorEvent {
    NSString *_summary;
    NSString *_description;
}

- (EventKind) kind {
    return ERROR;
}

- (void) setSummary:(NSString *)summary {
    _summary = summary;
}

- (NSString *) summary {
    return _summary;
}

- (void) setDescription:(NSString *)description {
    _description = description;
}

- (NSString *) description {
    return _description;
}

@end
