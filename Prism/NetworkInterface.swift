//
//  NetworkInterface.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 11/24/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class NetworkInterface {
    let ifname: String
    var fd: Int32 = -1
    
    init(name: String) {
        ifname = name
    }
    
    func start() {
        self.fd = c_open_bpf(ifname)
        if (self.fd == -1) {
            print("Error: BPF fd=-1")
            return
        }
        var fh = NSFileHandle(fileDescriptor: self.fd, closeOnDealloc: true)
    }
}
