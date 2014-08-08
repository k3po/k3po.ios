//
//  CommandEvent.h
//  KMStompJMS
//
//  Created by pkhanal on 7/30/14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    PREPARED,
    STARTED,
    ERROR,
    FINISHED
} EventKind;

@interface CommandEvent : NSObject

- (EventKind) kind;

- (void) setName:(NSString *)name;

- (NSString *) name;

@end
