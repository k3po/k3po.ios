//
//  XCRoboticTestCase.h
//  KMStompJMS
//
//  Created by pkhanal on 7/29/14.
//
//

#import <XCTest/XCTest.h>

@interface XCRoboticTestCase : XCTestCase

- (void) prepare:(NSString *)script;

- (void) join;

- (void) initializeScriptRoot;

@end
