//
//  Pcap.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/7/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

let PCAP_FILE_MAGIC: bpf_u_int32 = 0xa1b2c3d4

class Pcap {
    var packets: [Packet] = []
    
    func encode() -> NSData {
        var hdr = pcap_file_header()
        hdr.magic = PCAP_FILE_MAGIC
        hdr.version_major = 2
        hdr.version_minor = 4
        hdr.thiszone = 0
        hdr.snaplen = 65536
        hdr.linktype = 0
        return NSData(bytes: &hdr, length: sizeof(pcap_file_header))
    }

    class func readFile(data: NSData) -> Pcap? {
        if (data.length < sizeof(pcap_file_header)) {
            print("File too short (size=\(data.length))")
            return nil
        }
        
        let hdr = UnsafePointer<pcap_file_header>(data.bytes).memory
        if (hdr.magic != PCAP_FILE_MAGIC) {
            print("bad magic: \(hdr.magic)")
            return nil
        }
        
        return Pcap()
    }
}
