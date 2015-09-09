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
        var i = 0

        if (data.length < sizeof(pcap_file_header)) {
            print("File too short (size=\(data.length))")
            return nil
        }

        let filehdr = UnsafePointer<pcap_file_header>(data.bytes).memory
        if (filehdr.magic != PCAP_FILE_MAGIC) {
            print("bad magic: \(filehdr.magic)")
            return nil
        }
        i += sizeof(pcap_file_header)

        var pcap = Pcap()
        
        while (i < data.length) {
            if (i + 16 > data.length) {
                return nil
            }
            let ts_sec  = UnsafePointer<UInt32>(data.bytes + i).memory
            let ts_usec = UnsafePointer<UInt32>(data.bytes + i + 4).memory
            let caplen  = UnsafePointer<UInt32>(data.bytes + i + 8).memory
            let origlen = UnsafePointer<UInt32>(data.bytes + i + 12).memory
            i += 16
            
            if (i + Int(caplen) > data.length) {
                return nil
            }

            let sec = Double(ts_sec) + 1.0e-6 * Double(ts_usec)
            let date = NSDate(timeIntervalSinceReferenceDate: sec)

            let pkt = Packet(timestamp: date, original_length: Int(origlen), captured_length: Int(caplen), data: NSData(bytes: data.bytes + i, length: Int(caplen)))
            pcap.packets.append(pkt)
            i += Int(caplen)
        }
        return pcap
    }
}
