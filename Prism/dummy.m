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

int c_open_bpf(int fd, const char *ifname)
{
    struct ifreq ifr;
    unsigned int k;
    int i;
    char path[20];
    
//    fd = -1;
//    for (i = 0; i < 10; i++) {
//        snprintf(path, sizeof(path), "/dev/bpf%d", i);
//        fd = open(path, O_RDONLY);
//        if (fd != -1)
//            break;
//    }
//    if (fd == -1)
//        return -1;
    
    k = 2000;
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
    
    {
        char buf[2000];
        int n = read(fd, buf, sizeof(buf));
        printf("n=%d\n", n);
    }
    return fd;
}
