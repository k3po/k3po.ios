//
//  PrepareCommand.h
//  KMStompJMS
//
//  Created by pkhanal on 7/30/14.
//
//

#import "Command.h"

@interface PrepareCommand : Command

- (NSString *) script;

- (void) setScript:(NSString *)script;

@end
