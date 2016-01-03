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
    var buffer = [UInt8](count: 2000, repeatedValue: 0)
    
    init(name: String) {
        ifname = name
    }
    
    func on_receive(callback: ((NSData) -> Void)) {
        for i in 0..<8 {
            filehandle = NSFileHandle(forReadingAtPath: "/dev/bpf\(i)")
            if (filehandle != nil) { break }
        }

        guard filehandle != nil else {
            return
        }
        
        c_bpf_setup(filehandle!.fileDescriptor, "en0", UInt32(buffer.count))

        filehandle!.readabilityHandler = {
            fh in
            let len = read(fh.fileDescriptor, &self.buffer, 2000)
//            print("read \(len) bytes")
            callback(NSData(bytes: &self.buffer, length: len))
        }
        print("started")
    }
    
    func stop() {
        filehandle?.closeFile()
        fd = -1
    }
}
