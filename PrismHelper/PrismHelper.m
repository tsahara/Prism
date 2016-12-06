//
//  PrismHelper.m
//  Prism
//
//  Created by Tomoyuki Sahara on 2016/12/07.
//  Copyright © 2016 Tomoyuki Sahara. All rights reserved.
//

#import "PrismHelper.h"

#include <sys/types.h>
#include <sys/time.h>
#include <sys/ioctl.h>
#include <net/bpf.h>

@interface PrismHelper () <NSXPCListenerDelegate, PrismHelperProtocol>

@property (atomic, strong, readwrite) NSXPCListener *listener;

@end

@implementation PrismHelper

- (id)init
{
    self = [super init];
    if (self != nil) {
        self->_listener = [[NSXPCListener alloc] initWithMachServiceName:@"net.caddr.PrismHelper"];
        self->_listener.delegate = self;
    }
    return self;
}

- (void)run
{
    [self.listener resume];
    [[NSRunLoop currentRunLoop] run];
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(PrismHelperProtocol)];
    newConnection.exportedObject = self;
    [newConnection resume];
    
    return YES;
}

- (void)getVersion:(void(^)(NSString * version))reply
{
    reply([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]);
}

- (void)openBPF:(void(^)(int))reply;
{
    reply(3);
}

@end
