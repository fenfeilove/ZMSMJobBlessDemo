//
//  AppDelegate.m
//  ZMSMJobBlessDemo
//
//  Created by francis zhuo on 31/03/2018.
//  Copyright © 2018 fenfei. All rights reserved.
//

#import "AppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>
#import "ZMHelperProtocol.h"

@interface AppDelegate ()

@property (assign) IBOutlet NSWindow *window;
@property (strong) NSXPCConnection* connectionToService;
@end

@implementation AppDelegate
#define kSMJobHelperBunldeID @"com.fenfei.ZMHelper"
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    if (![self blessHelperWithLabel:kSMJobHelperBunldeID error:nil]) {
        return;
    }
    NSLog(@"success");
//    xpc_connection_t connection = xpc_connection_create_mach_service("com.fenfei.ZMHelper", NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
//
//    if (!connection) {
//        NSLog(@"Failed to create XPC connection.");
//        return;
//    }
//
//    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
//        xpc_type_t type = xpc_get_type(event);
//
//        if (type == XPC_TYPE_ERROR) {
//
//            if (event == XPC_ERROR_CONNECTION_INTERRUPTED) {
//                NSLog(@"XPC connection interupted.");
//
//            } else if (event == XPC_ERROR_CONNECTION_INVALID) {
//                NSLog(@"XPC connection invalid, releasing.");
//                xpc_release(connection);
//
//            } else {
//                NSLog(@"Unexpected XPC connection error.");
//            }
//
//        } else {
//            NSLog(@"Unexpected XPC connection event.");
//        }
//    });
//
//    xpc_connection_resume(connection);
//
//    xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
//    const char* request = "Hi there, helper service.";
//    xpc_dictionary_set_string(message, "request", request);
//
//    NSLog(@"%@",[NSString stringWithFormat:@"Sending request: %s", request]);
//
//    xpc_connection_send_message_with_reply(connection, message, dispatch_get_main_queue(), ^(xpc_object_t event) {
//        const char* response = xpc_dictionary_get_string(event, "reply");
//        NSLog(@"%@",[NSString stringWithFormat:@"Received response: %s.", response]);
//    });
//    _connectionToService = [[NSXPCConnection alloc] initWithServiceName:@"com.fenfei.ZMHelper" ];
    self.connectionToService = [[NSXPCConnection alloc] initWithMachServiceName:@"com.fenfei.ZMHelper" options:(NSXPCConnectionPrivileged)];
    if(!_connectionToService){
        NSLog(@"creat error = %@",_connectionToService);
    }
    _connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ZMHelperProtocol)];

    __weak typeof(self) myself = self;
    _connectionToService.interruptionHandler = ^(){
        NSLog(@"interruptionHandler");
        myself.connectionToService = nil;
    };
    _connectionToService.invalidationHandler = ^(){
        NSLog(@"invalidationHandler");
//        [self blessHelperWithLabel:kSMJobHelperBunldeID error:nil];
    };
    [_connectionToService remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    
    [_connectionToService resume];
    
    [[_connectionToService remoteObjectProxy] upperCaseString:@"hello" withReply:^(NSString *aString) {
        // We have received a response. Update our text field, but do it on the main thread.
        NSLog(@"Result string was: %@", aString);
//        [_connectionToService invalidate];
    }];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (BOOL)blessHelperWithLabel:(NSString *)label
                       error:(NSError **)error {
    
    BOOL result = NO;
    /* This does all the work of verifying the helper tool against the application
     * and vice-versa. Once verification has passed, the embedded launchd.plist
     * is extracted and placed in /Library/LaunchDaemons and then loaded. The
     * executable is placed in /Library/PrivilegedHelperTools.
     */
    CFErrorRef theError = nil;
    result = SMJobBless(kSMDomainSystemLaunchd, (__bridge CFStringRef)label, self.authRef, &theError);
    if(!result)
        NSLog(@"theError = %@",theError);
    
    return result;
}
- (IBAction)onButtonClick:(id)sender{
//    [_connectionToService resume];
    [[_connectionToService remoteObjectProxy] upperCaseString:@"hahahahha" withReply:^(NSString *aString) {
        NSLog(@"Result string was: %@", aString);
//        [_connectionToService invalidate];
    }];
}
- (IBAction)onRemoveClick:(id)sender{
    CFErrorRef theError = nil;
    Boolean result;
    result = SMJobRemove(kSMDomainSystemLaunchd, (__bridge CFStringRef)kSMJobHelperBunldeID, self.authRef, true, &theError);
    NSLog(@"%d %@",result,theError);
}
- (AuthorizationRef) authRef{
    if(!_authRef){
        AuthorizationItem authItem        = { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
        AuthorizationRights authRights    = { 1, &authItem };
        AuthorizationFlags flags        =    kAuthorizationFlagDefaults                |
        kAuthorizationFlagInteractionAllowed    |
        kAuthorizationFlagPreAuthorize            |
        kAuthorizationFlagExtendRights;
        OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &_authRef);
        if (status != errAuthorizationSuccess) {
            NSLog(@"Failed to create AuthorizationRef. Error code: %d", (int)status);
        }
    }
    return _authRef;
}
@end
