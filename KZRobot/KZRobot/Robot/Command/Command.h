//
//  Command.h
//  KMStompJMS
//
//  Created by pkhanal on 7/30/14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    PREPARE,
    START,
    ABORT
} CommandKind;

@interface Command : NSObject

- (CommandKind) kind;

- (void) setName:(NSString *)name;

- (NSString *) name;

@end
