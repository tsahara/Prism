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
    var filehandle: FileHandle?
    var buffer = [UInt8](repeating: 0, count: 2000)
    
    init(name: String) {
        ifname = name
    }
    
    func on_receive(_ callback: @escaping ((Data) -> Void)) {
        for i in 0..<8 {
            filehandle = FileHandle(forReadingAtPath: "/dev/bpf\(i)")
            if (filehandle != nil) { break }
        }

        guard filehandle != nil else {
            return
        }
        
        c_bpf_setup(filehandle!.fileDescriptor, "en0", UInt32(buffer.count))

        filehandle!.readabilityHandler = {
            fh in
            var buffer = Data(capacity: 2000)
            buffer.withUnsafeMutableBytes {
                (ptr: UnsafeMutablePointer<UInt8>) in
                let len = read(fh.fileDescriptor, ptr, 2000)
                buffer.count = len
                callback(buffer)
            }
        }
        print("started")
    }
    
    func stop() {
        filehandle?.closeFile()
    }
}
