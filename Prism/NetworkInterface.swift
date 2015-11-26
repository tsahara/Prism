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
    var filehandle: NSFileHandle?
    
    init(name: String) {
        ifname = name
    }
    
    func start() {
        for i in 0..<8 {
            filehandle = NSFileHandle(forReadingAtPath: "/dev/bpf\(i)")
            if (filehandle != nil) { break }
        }
        self.fd = c_open_bpf(filehandle!.fileDescriptor, ifname)
        if (self.fd < 0) {
            print("Error: BPF fd=\(self.fd)")
            return
        }
        filehandle!.readabilityHandler = {
            fh in
            print("readability")
        }
        print("started")
    }
}
