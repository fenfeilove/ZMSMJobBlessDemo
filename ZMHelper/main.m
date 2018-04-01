//
//  main.m
//  ZMHelper
//
//  Created by francis zhuo on 31/03/2018.
//  Copyright © 2018 fenfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <syslog.h>
#import <xpc/xpc.h>
#import "ZMHelperProtocol.h"
#import "ZMHelper.h"

//static void __XPC_Peer_Event_Handler(xpc_connection_t connection, xpc_object_t event) {
//    syslog(LOG_NOTICE, "Received event in helper.");
//
//    xpc_type_t type = xpc_get_type(event);
//
//    if (type == XPC_TYPE_ERROR) {
//        if (event == XPC_ERROR_CONNECTION_INVALID) {
//            // The client process on the other end of the connection has either
//            // crashed or cancelled the connection. After receiving this error,
//            // the connection is in an invalid state, and you do not need to
//            // call xpc_connection_cancel(). Just tear down any associated state
//            // here.
//
//        } else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
//            // Handle per-connection termination cleanup.
//        }
//
//    } else {
//        xpc_connection_t remote = xpc_dictionary_get_remote_connection(event);
//
//        xpc_object_t reply = xpc_dictionary_create_reply(event);
//        xpc_dictionary_set_string(reply, "reply", "Hi there, host application!");
//        xpc_connection_send_message(remote, reply);
//        xpc_release(reply);
//    }
//}
//
//static void __XPC_Connection_Handler(xpc_connection_t connection)  {
//    syslog(LOG_NOTICE, "Configuring message event handler for helper.");
//
//    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
//        __XPC_Peer_Event_Handler(connection, event);
//    });
//
//    xpc_connection_resume(connection);
//}
//
//int main(int argc, const char * argv[]) {
//    xpc_connection_t service = xpc_connection_create_mach_service("com.fenfei.ZMHelper",
//                                                                  dispatch_get_main_queue(),
//                                                                  XPC_CONNECTION_MACH_SERVICE_LISTENER);
//
//    if (!service) {
//        syslog(LOG_NOTICE, "Failed to create service.");
//        exit(EXIT_FAILURE);
//    }
//
//    syslog(LOG_NOTICE, "Configuring connection event handler for helper");
//    xpc_connection_set_event_handler(service, ^(xpc_object_t connection) {
//        __XPC_Connection_Handler(connection);
//    });
//
//    xpc_connection_resume(service);
//
//    dispatch_main();
//
//    xpc_release(service);
//
//    return EXIT_SUCCESS;
//}
@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
    
    // Configure the connection.
    // First, set the interface that the exported object implements.
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ZMHelperProtocol)];
    
    // Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
    ZMHelper *exportedObject = [ZMHelper new];
    newConnection.exportedObject = exportedObject;
    
    // Resuming the connection allows the system to deliver more incoming messages.
    [newConnection resume];
    
    // Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
    return YES;
}

@end

int main(int argc, const char * argv[]) {
    syslog(LOG_NOTICE, "ZMHelper start");
    ServiceDelegate *delegate = [ServiceDelegate new];
    NSXPCListener *listener = [[NSXPCListener alloc] initWithMachServiceName:@"com.fenfei.ZMHelper"];
    listener.delegate = delegate;

    [listener resume];
    [[NSRunLoop currentRunLoop] run];
    syslog(LOG_NOTICE, "ZMHelper end");
//    dispatch_main();
//    while (1) {
//        sleep(0.5);
//    }
    return 1;
}
