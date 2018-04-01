//
//  ZMHelper.m
//  ZMHelper
//
//  Created by francis zhuo on 31/03/2018.
//  Copyright © 2018 fenfei. All rights reserved.
//

#import "ZMHelper.h"
#import <syslog.h>

@implementation ZMHelper

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
- (void)upperCaseString:(NSString *)aString withReply:(void (^)(NSString *))reply {
    syslog(LOG_NOTICE, "ZMHelper upperCaseString");
    NSString *response = [aString uppercaseString];
    reply(response);
}

@end
