//
//  dummy.m
//  Prism
//
//  Created by Tomoyuki Sahara on 9/7/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Darwin.POSIX.net;
@import Darwin.POSIX.ioctl;

#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/bpf.h>
#include <ifaddrs.h>

// The reason why this file is written by C is:
//
// 1. constant values like BIOCSBLEN are not exported to Swift.
// 2. ioctl(2) cannot be called in Swift because of varargs.

int c_bpf_setup(int fd, const char *ifname, unsigned int bufsize)
{
    struct ifreq ifr;
    unsigned int k;

    k = bufsize;
    if (ioctl(fd, BIOCSBLEN, &k) == -1)
        return -1;
    
    memset(&ifr, 0, sizeof(ifr));
    strncpy(ifr.ifr_name, ifname, sizeof(ifr.ifr_name));
    if (ioctl(fd, BIOCSETIF, &ifr) == -1)
        return -2;
    
    k = 1;
    if (ioctl(fd, BIOCIMMEDIATE, &k) == -1)
        return -3;
    
    k = 1;
    if (ioctl(fd, BIOCSHDRCMPLT, &k) == -1)
        return -4;
    
    if (ioctl(fd, BIOCPROMISC) == -1)
        return -5;

    return fd;
}
