//
//  ZMHelper.h
//  ZMHelper
//
//  Created by francis zhuo on 31/03/2018.
//  Copyright © 2018 fenfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMHelperProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface ZMHelper : NSObject <ZMHelperProtocol>
@end
